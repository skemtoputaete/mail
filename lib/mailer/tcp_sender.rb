require 'openssl'
require 'socket'

module Mailer
  class TCPSender
    def initialize(host, port)
      @tcp_socket = TCPSocket.new(host, port)
      @ssl_context = OpenSSL::SSL::SSLContext.new
      @ssl_socket = OpenSSL::SSL::SSLSocket.new(@tcp_socket, @ssl_context)
      @ssl_socket.connect
    end

    def set_params(params)
      @email = params[:email]
      @password = params[:password]
      @login = params[:login]
    end

    def send_email(message_params)

    end

    def authorize

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
  end
end
