require 'OBD/abstract/mode'
require 'OBD/abstract/parser'
require 'OBD/io/requester'
require 'OBD/io/connection'

module OBD

  class Controller

    def initialize(mode, settings)
      @mode = mode
      @connection = OBD::Connection::new(settings)
      @requester = OBD::Requester::new(@connection)
      @parser = OBD::Parser::new
      __marshall_mode
    end

    def request(pid, override = false)
      supported = is_pid_supported?(pid)
      if supported[0]
        @requester.request(@mode.code, pid)
      else
        if override
          @requester.request(@mode.code, pid)
        else
          raise OBD::PidError.missing(pid, @mode.code) if supported[1] == OBD::Mode::MISSING
          raise OBD::PidError.unsupported(pid, @mode.code) if supported[1] == OBD::Mode::NOT_SUPPORTED
        end
      end
    end

    def is_pid_supported?(pid)
      @mode.is_pid_supported?(pid)
    end

    def get_settings
      @connection.settings
    end

    private
    def __marshall_mode
      @mode.supported_pids =
          @parser.parse_supported_pids(
              @requester.request_supported_pids(
                  @mode
              )
          )
    end

  end

end