require_relative '../controller'
require_relative '../parser'
require_relative '../conversion'

module OBD

  module Mode_01

    class Controller < OBD::Controller

      public
      def initialize(settings)
        super(
            OBD::Mode::new("01", ["00", "20", "40", "60", "80", "A0", "C0"]),
            settings
        )
        @parser = OBD::Mode_01::Parser::new
      end

      public
      def get_status_since_dtcc(override = false)
        @parser.parse_status_since_dtcc(request('01', override))
      end

      public
      def get_fuel_system_status(override = false)
        @parser.parse_fuel_system_status(request('03', override))
      end

      public
      def get_engine_load(override = false)
        @parser.parse_engine_load(request('04', override))
      end

      public
      def get_engine_coolant_temp(override = false)
        @parser.parser_engine_coolant_temp(request('05', override))
      end

      public
      def get_fuel_trim(override = false)
        {
            :STFT_B1 => @parser.parse_fuel_trim(request('06', override)),
            :LTFT_B1 => @parser.parse_fuel_trim(request('07', override)),
            :STFT_B2 => @parser.parse_fuel_trim(request('08', override)),
            :LTFT_B2 => @parser.parse_fuel_trim(request('09', override))
        }
      end

      public
      def get_fuel_pressure(override = false)
        @parser.parse_fuel_pressure(request('0A', override))
      end

      public
      def get_intake_manifold_pressure(override = false)
        @parser.parse_intake_manifold_pressure(request('0B', override))
      end

      public
      def get_engine_rpm(override = false)
        @parser.parse_engine_rpm(request('0C', override))
      end

      public
      def get_vehicle_speed(override = false)
        @parser.parse_vehicle_speed(request('0D', override))
      end

      public
      def get_timing_advance(override = false)
        @parser.parse_timing_advance(request('0E', override))
      end

      public
      def get_intake_air_temperature(override = false)
        @parser.parse_intake_air_temperature(request('0F', override))
      end

      public
      def get_maf_airflow_rate(override = false)
        @parser.parse_maf_airflow_rate(request('10', override))
      end

    end




    class Parser < OBD::Parser

      public
      def parse_status_since_dtcc(input)
        ctb = Proc::new {|i| Conversion.hex_to_bin_rjust(i).reverse} # Convert To Binary
        a, b, c, d = input.value[0..1], input.value[2..3], input.value[4..5], input.value[6..7]
        a_binary, b_binary, c_binary, d_binary = ctb.call(a), ctb.call(b), ctb.call(c), ctb.call(d)
        {
            :MIL            => (a_binary[7].to_i),
            :DTC_CNT        => Conversion.hex_to_dec(a[0..6]),
            :RESERVED       => (b_binary[7].to_i),
            :IGNITION       => (b_binary[3].to_i),
            :COMPONENTS     => {:AVAILABLE => b_binary[2].to_i, :INCOMPLETE => b_binary[6].to_i},
            :FUEL_SYSTEM    => {:AVAILABLE => b_binary[1].to_i, :INCOMPLETE => b_binary[5].to_i},
            :MISFIRE        => {:AVAILABLE => b_binary[0].to_i, :INCOMPLETE => b_binary[4].to_i},
            :ENGINE_SYSTEMS => [
                {:AVAILABLE => c_binary[7].to_i, :INCOMPLETE => d_binary[7].to_i},
                {:AVAILABLE => c_binary[6].to_i, :INCOMPLETE => d_binary[6].to_i},
                {:AVAILABLE => c_binary[5].to_i, :INCOMPLETE => d_binary[5].to_i},
                {:AVAILABLE => c_binary[4].to_i, :INCOMPLETE => d_binary[4].to_i},
                {:AVAILABLE => c_binary[3].to_i, :INCOMPLETE => d_binary[3].to_i},
                {:AVAILABLE => c_binary[2].to_i, :INCOMPLETE => d_binary[2].to_i},
                {:AVAILABLE => c_binary[1].to_i, :INCOMPLETE => d_binary[1].to_i},
                {:AVAILABLE => c_binary[0].to_i, :INCOMPLETE => d_binary[0].to_i}]
        }
      end

      public
      def parse_fuel_system_status(input)
        statuses = [
            'Open loop due to insufficient engine temperature',
            'Closed loop, using oxygen sensor feedback to determine fuel mix',
            'Open loop due to engine load OR fuel cut due to deacceleration',
            'Open loop due to system failure',
            'Closed loop, using at least one oxygen sensor but there is a fault in the feedback system'
        ]
        #FixMe: For some reason this gives 4 bytes instead of 2, which one are the correct ones?
        a = Conversion.hex_to_bin_rjust(input.value[0..1]).reverse
        b = Conversion.hex_to_bin_rjust(input.value[2..3]).reverse
        detect = Proc::new do |x|
          if x.size != 8 || x.count('1') != 1 || x.index('1') > 4
            "Invalid Status"
          else
            statuses[x.index('1')]
          end
        end

        {:FUEL_SYSTEM_1 => detect.call(a), :FUEL_SYSTEM_2 => detect.call(b)}
      end

      public
      def parse_engine_load(input)
        #FixMe: [0..1] OR [2..3]???
        a = Conversion.hex_to_dec(input.value[0..1])
        (a / 2.55).round(2)
      end

      public
      def parser_engine_coolant_temp(input)
        a = Conversion.hex_to_dec(input.value)
        a - 40
      end

      public
      def parse_fuel_trim(input)
        a = Conversion.hex_to_dec(input.value)
        (a / 1.28 - 100).round(1)
      end

      public
      def parse_fuel_pressure(input)
        a = Conversion.hex_to_dec(input.value)
        a * 3
      end

      public
      def parse_intake_manifold_pressure(input)
        Conversion.hex_to_dec(input.value)
      end

      public
      def parse_engine_rpm(input)
        a = Conversion.hex_to_dec(input.value[0..1])
        b = Conversion.hex_to_dec(input.value[2..3])
        ((256.00 * a + b) / 4.00).round(2)
      end

      public
      def parse_vehicle_speed(input)
        Conversion.hex_to_dec(input.value)
      end

      public
      def parse_timing_advance(input)
        a = Conversion.hex_to_dec(input.value)
        ((a / 2.00) - 64.00).round(2)
      end

      public
      def parse_intake_air_temperature(input)
        a = Conversion.hex_to_dec(input.value)
        a - 40
      end

      public
      def parse_maf_airflow_rate(input)
        a = Conversion.hex_to_dec(input.value[0..1])
        b = Conversion.hex_to_dec(input.value[2..3])
        ((256.00 * a + b) / 100.00).round(2)
      end

    end

  end

end