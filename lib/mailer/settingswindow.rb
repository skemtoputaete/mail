require 'gtk3'

module Mailer
  class SettingsWindow < Gtk::Window
    def initialize(&block)
      super
      settings &block
      elements
      show_all
    end

    def get_user_settings
      [
        { smtp_host: @smtp_host, email: @email, password: @password, sender: @sender },
        { port: @port, login: @login, auth: @auth }
      ]
    end

    private
    def settings(&block)
      set_title 'Settings for email app'
      set_tooltip_text 'Application for sending an email'
      set_default_size 400, 250
      set_window_position Gtk::WindowPosition::CENTER
      set_border_width 10
      signal_connect('destroy') do
        if block_given?
          block.call
        else
          Gtk.main_quit
        end
      end
    end

    def elements
      grid = Gtk::Grid.new
      vbox = Gtk::Box.new :vertical, 2
      accept_btn = Gtk::Button.new label: 'Accept'

      # Text fields
      port = Gtk::Entry.new
      smtp = Gtk::Entry.new
      email = Gtk::Entry.new
      pswrd = Gtk::Entry.new
      login = Gtk::Entry.new
      auth = Gtk::ComboBoxText.new
      sender = Gtk::ComboBoxText.new

      # Labels
      port_l = Gtk::Label.new('Port:')
      login_l = Gtk::Label.new('Login:')
      email_l = Gtk::Label.new('Email:')
      pswrd_l = Gtk::Label.new('Password:')
      smtp_l = Gtk::Label.new('SMTP host:')
      auth_l = Gtk::Label.new('Authentication:')
      required_l = Gtk::Label.new('Required parametres area')
      optionally_l = Gtk::Label.new('Optional parametres area')

      # Element's settings
      email.max_length = 255
      email.placeholder_text = 'Enter your email'

      pswrd.visibility = false
      pswrd.placeholder_text = 'Enter your password'

      smtp.placeholder_text = 'SMTP host address'

      auth.append_text 'Login'
      auth.append_text 'Plain'
      auth.append_text 'Cram md5'

      sender.append_text 'SMTP class (Ruby)'
      sender.append_text 'Custom class'

      accept_btn.set_size_request 50, 15
      accept_btn.signal_connect 'clicked' do
        @email = email.text
        @smtp_host = smtp.text
        @password = pswrd.text
        @login = login.text
        @auth = auth.active_text
        @port = port.text
        @sender = sender.active_text
      end

      # Adding elemens to the grid's cells
      grid.attach required_l,   0, 0, 2, 1
      grid.attach email_l,      0, 1, 1, 1
      grid.attach email,        1, 1, 1, 1
      grid.attach pswrd_l,      0, 2, 1, 1
      grid.attach pswrd,        1, 2, 1, 1
      grid.attach smtp_l,       0, 3, 1, 1
      grid.attach smtp,         1, 3, 1, 1
      grid.attach optionally_l, 0, 4, 2, 1
      grid.attach port_l,       0, 5, 1, 1
      grid.attach port,         1, 5, 1, 1
      grid.attach login_l,      0, 6, 1, 1
      grid.attach login,        1, 6, 1, 1
      grid.attach auth_l,       0, 7, 1, 1
      grid.attach auth,         1, 7, 1, 1
      grid.attach sender,       1, 8, 1, 1
      grid.attach accept_btn,   1, 9, 1, 1

      vbox.pack_start grid, expand: true, fill: true, padding: 0
      add vbox
    end
  end
end
