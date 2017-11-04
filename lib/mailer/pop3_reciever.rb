require 'openssl'
require 'socket'
require 'base64'

module Mailer
  class Pop3
    def initialize(settings, options)
      @email = settings[:email]
      @password = settings[:password]
      @login = settings[:email]
      @tcp_socket = TCPSocket.new(options[:host], options[:port])
      @ssl_context = OpenSSL::SSL::SSLContext.new
      @ssl_context.ca_file = 'ca_cert.pem'
      @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @ssl_context.ssl_version = :SSLv23
      @ssl_socket = OpenSSL::SSL::SSLSocket.new(@tcp_socket, @ssl_context)
      @ssl_socket.connect
    end

    def authorize
      @ssl_socket.puts "USER #{@login}"
      answer = get_answer
      return answer if has_error? answer
      @ssl_socket.puts "PASS #{@password}"
      get_answer
    end

    def get_count_emails
      return @count_emails if @count_emails
      @ssl_socket.puts 'LIST'
      @count_emails = get_answer.last(2).first.split.first.to_i
    end

    def get_one_email(identifier, separate = true)
      @ssl_socket.puts "RETR #{identifier}"
      get_answer(separate)
    end

    def get_email_themes(page, per_page)
      result = []
      upper_bound = get_count_emails - ((page - 1) * per_page)
      lower_bound = get_count_emails - (page * per_page)
      (lower_bound..upper_bound).each do |email_number|
        email = get_one_email(email_number, false)
        subject = email.detect { |e| e =~ /^subject/i }
                       .gsub(/^subject:\s/i, '')
                       .split(/\n|\r|\n\r/)
                       .first
                       .encode('UTF-8')
        from = email.detect { |e| e =~ /^from/i }
                    .scan(/\S+@\S+/i)
                    .first
        result << "#{subject} (#{from})"
      end
      result
    end

    def end_session
      @ssl_socket.puts 'QUIT'
      get_answer(true)
    end

    def has_error?(answer)
      temp = answer.is_a?(String) ? answer.split("\n") : answer
      temp.each do |a|
        return true if a[0,4] == '-ERR'
      end
      false
    end

    private
    def get_answer(separate = false)
      result = []
      while next_line_readable? @ssl_socket
        line = @ssl_socket.gets
        break if line.nil?
        result << line.encode('UTF-8')
      end
      separate ? result.join("\n") : result
    end

    def next_line_readable?(socket)
      readfds, _, _ = select([socket], nil, nil, 0.1) # IO.select
      readfds
    end
  end
end
