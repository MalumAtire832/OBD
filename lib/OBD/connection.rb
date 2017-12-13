require_relative 'error'

require 'serialport'

module OBD

  class Connection

    attr_reader :settings, :port

    public
    def initialize(settings)
      sh = settings.to_hash
      sh.each_key {|k| raise OBD::ParameterError.mismatch("Settings:#{k}", "not nil", "#{sh[k]}") if sh[k].to_s.empty?}
      @settings = settings
      @port = SerialPort::new(
          settings.device,
          settings.baudrate,
          settings.data_bits,
          settings.stop_bits,
          settings.parity_bits,
      )
    end

    public
    def read
      @port.readline.chomp
    end

    public
    def write(command)
      @port.write(command)
    end




    class Settings

      attr_reader :device, :baudrate, :data_bits, :stop_bits, :parity_bits

      public
      def initialize(device, baudrate, data_bits, stop_bits, parity_bits)
        @device = device
        @baudrate = baudrate
        @data_bits = data_bits
        @stop_bits = stop_bits
        @parity_bits = parity_bits
      end

      public
      def to_hash
        {
            :device => @device,
            :baudrate => @baudrate,
            :data_bits => @data_bits,
            :stop_bits => @stop_bits,
            :parity_bits => @parity_bits,
        }
      end

    end

  end

end