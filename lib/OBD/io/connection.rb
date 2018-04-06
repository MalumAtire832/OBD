require 'serialport'

module OBD

  class Connection

    DEFAULT_SETTINGS = {
        :baudrate => 9600,
        :data_bits => 8,
        :stop_bits => 1,
        :parity_bits => 0,
    }

    attr_reader :settings, :port

    # noinspection RubyControlFlowConversionInspection
    def initialize(settings = DEFAULT_SETTINGS)
      raise OBD::ParameterError.missing("settings[:device]") if !__has_device?(settings)
      @settings = __transform_settings(settings)
      @port = SerialPort::new(
          @settings[:device],
          @settings[:baudrate],
          @settings[:data_bits],
          @settings[:stop_bits],
          @settings[:parity_bits]
      )
    end

    def read
      @port.readline.chomp
    end

    def write(command)
      @port.write(command)
    end

    # noinspection RubyNestedTernaryOperatorsInspection
    private
    def __has_device?(settings)
      device = settings[:device]
      device.nil? ? false : (device.empty? ? false : true)
    end

    private
    def __transform_settings(settings)
      {
          :device      => settings[:device],
          :baud_rate   => settings[:baudrate]    || DEFAULT_SETTINGS[:baudrate],
          :data_bits   => settings[:data_bits]   || DEFAULT_SETTINGS[:data_bits],
          :stop_bits   => settings[:stop_bits]   || DEFAULT_SETTINGS[:stop_bits],
          :parity_bits => settings[:parity_bits] || DEFAULT_SETTINGS[:parity_bits]
      }
    end

  end

end