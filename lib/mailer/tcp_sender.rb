require 'socket'

module Mailer
  class TCPSender
    def initialize(host, ip)
      @socket = TCPSocket.open(host, ip)
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
  end
end
