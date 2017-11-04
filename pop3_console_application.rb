require './lib/mailer.rb'

host = ''
port = ''
login = ''
email = ''
password = ''

print 'Enter your email address: '
gets email
print 'Enter your password: '
gets password
print 'Enter your login: '
gets login
print 'Enter your pop3 host: '
gets host
print 'Enter host\'s port: '
gets port

pop3 = Mailer::Pop3.new({ email: email, password: password, login: login }, { host: host, port: port.to_i })
answer = pop3.authorize
if pop3.has_error? answer
  puts "An error occured! More information is below:\n#{answer}"
  pop3.end_session
end

user_command = 0

begin
  puts "\nBelow you can see available commands:"
  puts "\t1 - get count of emails;"
  puts "\t2 - read email with specific number;"
  puts "\t0 - close program."
  gets user_command

  case user_command
    when '1'
      count = pop3.get_count_emails
      puts "In your email box #{count} emails."
    when '2'
      print 'Enter a number of email: '
      gets number
      email = pop3.get_one_email(number, true)
      puts "\n\tYour email is below:\n#{email}"
    when '0'
      puts 'Goodbye!'
      pop3.end_session
    else
      puts 'You entered a wrong command. Try again.'
  end
end while user_command != '0'