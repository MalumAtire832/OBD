require 'OBD/conversion'
require 'OBD/abstract/mode'

module OBD

  class Requester

    def initialize(connection)
      @connection = connection
    end

    def request(mode, pid)
      m, p = mode.empty?, pid.empty?
      raise OBD::ParameterError.missing(m ? 'mode' : 'pid') if m || p
      @connection.write("#{mode}#{pid}\r")
      __read_response
    end

    def request_direct(command)
      raise OBD::ParameterError.missing('command') if command.empty?
      @connection.write("#{command}\r")
      __read_response
    end

    def request_raw(command)
      raise OBD::ParameterError.missing('command') if command.empty?
      @connection.write("#{command}\r")
      __read_response(raw=true)
    end

    def request_supported_pids(mode)
      mode.indexes.map {|i| request(mode.code, i).value}
    end

    private
    def __read_response(raw = false)
      p, i = '',''
      0.upto(1) do |c|
        v = @connection.read
        c == 0 ? (p = v) : (i = v)
      end
      OBD::Requester::Result::new(p, i, raw)
    end




    class Result

      attr_reader :previous, :mode, :pid, :value

      def initialize(previous, input, raw = false) # FixMe: This is ugly, very, very ugly.
        p, i = previous.gsub("\r", '').gsub('>',''), input
        if ['NO DATA', '?', ''].include?(i)
          @previous = p
          @mode = p[0..1]
          @pid = p[2..3]
          @value = (i == '' ? 'NONE' : i)
        elsif raw
          if p =~ /0[0-9][0-9A-F]{2}/
            @previous = p
            @mode = p[0..1]
            @pid = p[2..4]
            @value = i[6..-1]
          else
            @previous = p
            @mode = 'NONE'
            @pid = 'NONE'
            @value = i
          end
        else
          i.delete!(' ')
          @previous = p
          @mode = p[0..1]
          @pid = p[2..3]
          @value = i[4..-1]
        end
      end

    end

  end

end