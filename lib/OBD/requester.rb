require_relative '../obd/error'
require_relative '../obd/conversion'
require_relative '../obd/mode'

module OBD

  class Requester

    public
    def initialize(connection)
      @connection = connection
    end

    public
    def request(mode, pid)
      m, p = mode.empty?, pid.empty?
      raise OBD::ParameterError.missing(m ? 'mode' : 'pid') if m || p
      @connection.write("#{mode}#{pid}\r")
      __read_response
    end

    public
    def request_direct(command)
      raise OBD::ParameterError.missing('command') if command.empty?
      @connection.write("#{command}\r")
      __read_response
    end

    public
    def request_raw(command)
      raise OBD::ParameterError.missing('command') if command.empty?
      @connection.write("#{command}\r")
      __read_response(raw=true)
    end

    public
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

      public
      def initialize(previous, input, raw = false)
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