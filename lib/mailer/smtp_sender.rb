require 'net/smtp'
require 'openssl'

module Mailer
  class SMPTSender
    def initialize(required = {}, optional = {})
      @smtp_host = required[:smtp_host]
      @email = required[:email]
      @password = required[:password]
      @port = optional[:port].nil? ? 25 : optional[:port].to_i
      @login = optional[:login].nil? ? email : optional[:login]
      @auth_type = optional[:auth].nil? ? :login : optional[:auth].to_sym
    end

    def send_email(message_parts)
      emails_arr = get_only_emails(message_parts[:emails])
      message = create_message(message_parts)

      smtp = Net::SMTP.new @smtp_host, @port
      smtp.enable_starttls_auto
      begin
        smtp.start('localhost', @email, @password, @auth_type) do |smtp|
          smtp.send_message message, @login, emails_arr
        end
      rescue => error
        puts "Error occured: #{error.message}"
      end
    end

    private

    def create_message(message_parts)
      emails = modify_emails message_parts[:emails]
message = <<END_OF_MESSAGE
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
