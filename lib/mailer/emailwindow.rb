require 'gtk3'

module Mailer
  class EmailWindow < Gtk::Window
    def initialize
      super
      settings
      elements
      show_all
    end

    def sender_settings(user_settings = nil)
      unless user_settings.nil?
        @required = user_settings.first
        @optionally = user_settings.last
        @sender = Mailer::Sender.new(@required, @optionally)
      end
    end

    private

    def settings
      set_title 'Email app'
      set_window_position Gtk::WindowPosition::CENTER
      set_default_size 600, 600
      signal_connect('destroy') do
        Gtk.main_quit
      end
    end

    def elements
      grid = Gtk::Grid.new
      name = Gtk::Entry.new
      subject = Gtk::Entry.new
      email = Gtk::TextView.new
      receivers = Gtk::Entry.new
      receivers_l = Gtk::Label.new('To:')
      name_l = Gtk::Label.new('Your name:')
      btn_box = Gtk::ButtonBox.new :horizontal
      vbox = Gtk::Box.new :vertical, 3
      subject_l = Gtk::Label.new('Subject:')
      send_btn = Gtk::Button.new label: 'Send'
      scroller = Gtk::ScrolledWindow.new

      send_btn.set_size_request 80, 20

      email.wrap_mode = :word

      buffer = email.buffer
      buffer.create_tag('notice', font: 'Times Bold Italic 12', foreground: 'white')

      scroller.set_policy(:automatic, :automatic)
      scroller.add(email)

      send_btn.signal_connect 'clicked' do
        message_parts = {}
        message_parts[:name] = name.text
        message_parts[:body] = buffer.text
        message_parts[:subject] = subject.text
        message_parts[:emails] = receivers.text
        # send_email_msg message_parts
        name.text = ''
        buffer.text = ''
        subject.text = ''
        receivers.text = ''
      end

      grid.attach subject_l,   0, 0, 1, 1
      grid.attach subject,     2, 0, 1, 1
      grid.attach receivers_l, 0, 1, 1, 1
      grid.attach receivers,   2, 1, 1, 1
      grid.attach name_l,      0, 2, 1, 1
      grid.attach name,        2, 2, 1, 1

      btn_box.pack_start send_btn, expand: false, fill: true, padding: 5
      btn_box.set_layout Gtk::ButtonBoxStyle::END

      vbox.set_border_width 5
      vbox.set_spacing 5

      vbox.pack_start grid, expand: false, fill: true, padding: 0
      vbox.pack_start scroller, expand: true, fill: true, padding: 3
      vbox.pack_start btn_box, expand: false, fill: true, padding: 3
      add vbox
    end

    def send_email_msg(message_parts)
      @sender.send_email message_parts
    end
  end
end
