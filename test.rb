require 'net/smtp'
require 'openssl'
msgstr = <<END_OF_MESSAGE
From: Maxim Golikov <mak.goli@yandex.ru>
To: Maxim Golikov <blikylia@gmail.com>, Someone <one@example.com>
Subject: Just something
Date: #{Time.now.strftime("%a, %d %b %Y %H:%M:%S %z")}

Message body.
END_OF_MESSAGE

smtp = Net::SMTP.new 'smtp.yandex.ru', 25
smtp.enable_starttls

smtp.start('127.0.0.1', 'mak.goli', 't1M3i$COm1N74ChAnG3$$', :login) do |smtp|
  smtp.send_message msgstr, 'mak.goli@yandex.ru', 'blikylia@gmail.com'
end
