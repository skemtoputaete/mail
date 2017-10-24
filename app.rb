require './lib/mailer.rb'

s = Mailer::SettingsWindow.new do
  e = Mailer::EmailWindow.new
  user_settings = s.get_user_settings
  e.sender_settings user_settings, user_settings.first[:sender]
end
Gtk.main
