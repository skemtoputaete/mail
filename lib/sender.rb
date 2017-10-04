require 'net/smtp'
require 'openssl'

module Mail
  class Sender
    def initialize(smtp_host, email, password, ssl_port)
      @smtp_host = smtp_host
      @email = email
      @login = email.split('@')[0]
      @password = password
      @ssl_port = ssl_port
    end

    def send_email(message_parts)
      emails_arr = get_only_emails(message_parts[:emails])
      message = create_message(message_parts)

      smtp = Net::SMTP.new @smtp_host, 25
      smtp.enable_starttls
      smtp.start('localhost', @login, @password, :login) do |smtp|
        smtp.send_message message, @email, emails_arr
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
