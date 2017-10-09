require './lib/mailer.rb'

s = Mailer::SettingsWindow.new do
  e = Mailer::EmailWindow.new
  e.sender_settings s.get_user_settings
end
Gtk.main
