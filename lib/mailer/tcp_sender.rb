require 'openssl'
require 'socket'
require "base64"

module Mailer
  class TCPSender
    def initialize(host, port)
      @tcp_socket = TCPSocket.new(host, port)
      @ssl_context = OpenSSL::SSL::SSLContext.new
      @ssl_context.ca_file = 'ca_cert.pem'
      @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @ssl_context.ssl_version = :SSLv23
      @ssl_socket = OpenSSL::SSL::SSLSocket.new(@tcp_socket, @ssl_context)
      @ssl_socket.connect
    end

    def set_params(params)
      @email = params[:email]
      @login = params[:login]
      @password = params[:password]
      @encoded_pas = Base64.encode64(@password)
      @encoded_log = Base64.encode64(@login)
    end

    def send_email(message_params)
      commands = ["EHLO localhost\r\n",
                  "AUTH LOGIN\r\n",
                  "MAIL FROM: <#{@email}>\r\n",
                  "RCPT",
                  "DATA\r\n",
                  "MSG",
                  "QUIT\r\n"]

      commands.each do |command|
        case command[0,4]
        when 'RCPT'
          get_only_emails(message_params[:emails]).each do |email|
            @ssl_socket.puts "RCPT TO: <#{email}>\r\n"
          end
        when 'MSG'
          @ssl_socket.puts create_message(message_params)
        else
          @ssl_socket.puts command
        end

        result = read
        next if result == true
        if result =~ /username/i
          @ssl_socket.puts @encoded_log
          @ssl_socket.puts @encoded_pas if read =~ /password/i
          auth_res = read
          next if auth_res == true
          raise "Authentication problems. Message from server:\n#{auth_res}"
        end
        raise "An error occured. Message from server:\n#{result}"
      end
      read
    end

    private
    def create_message(message_parts)
      emails = modify_emails message_parts[:emails]
      <<END_OF_MESSAGE
From: #{message_parts[:name]} <#{@email}>
To: #{emails}
Subject: #{message_parts[:subject]}
Date: #{Time.now.strftime("%a, %d %b %Y %H:%M:%S %z")}

#{message_parts[:body]}
.
END_OF_MESSAGE
    end

    def modify_emails(emails)
      emails_arr = emails.split(',')
      emails_arr = emails_arr.map do |e|
        email = e.scan(/\S+@\S+/i)[0].delete(' ,')
        e.gsub!(email, "<#{email}>")
      end
      emails_arr.join(', ')
    end

    def get_only_emails(emails)
      emails_arr = emails.split(',')
      emails_arr = emails_arr.map { |e| e.scan(/\S+@\S+/i)[0].delete(' ,') }
    end

    def read
      buffer = ""
      while next_line_readable?(@ssl_socket)
        line = @ssl_socket.gets
        $stdout.puts "Message from server: #{line}"
        break if line.nil?
        buffer << line
      end
      analyze(buffer)
    end

    def next_line_readable?(socket)
      readfds, writefds, exceptfds = select([socket], nil, nil, 0.1) # IO.select
      readfds
    end

    def analyze(buffer)
      buffer.each_line do |line|
        case line[0,3]
          when "220"
          when "221"
          when "235"
          when "250"
          when "354"
            next
          when "334"
            return Base64.decode64(line.split.last)
          when "503"
            return line
          else
            next
        end
      end
      return true
    end
  end
end
