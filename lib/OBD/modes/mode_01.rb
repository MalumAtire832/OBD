require_relative '../controller'
require_relative '../parser'
require_relative '../conversion'

module OBD

  module Mode_01

    # noinspection RubyInstanceMethodNamingConvention
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

      public
      def get_throttle_position(override = false)
        @parser.parse_throttle_position(request('11', override))
      end

      public
      def get_commanded_secondary_air_status(override = false)
        @parser.parse_commanded_secondary_air_status(request('12', override))
      end

      public
      def get_oxygen_sensors_present_2banks(override = false)
        @parser.parse_oxygen_sensors_present_2banks(request('13', override))
      end

      public
      def get_oxygen_sensors_status(override = false)
        #ToDo: Incorperate the present sensors into this with a check?
        {
            :SENSOR_1 => @parser.parse_oxygen_sensor_status(request('14', override)),
            :SENSOR_2 => @parser.parse_oxygen_sensor_status(request('15', override)),
            :SENSOR_3 => @parser.parse_oxygen_sensor_status(request('16', override)),
            :SENSOR_4 => @parser.parse_oxygen_sensor_status(request('17', override)),
            :SENSOR_5 => @parser.parse_oxygen_sensor_status(request('18', override)),
            :SENSOR_6 => @parser.parse_oxygen_sensor_status(request('19', override)),
            :SENSOR_7 => @parser.parse_oxygen_sensor_status(request('1A', override)),
            :SENSOR_8 => @parser.parse_oxygen_sensor_status(request('1B', override)),
        }
      end

      public
      def get_conformed_obd_standard(override = false)
        @parser.parse_conformed_obd_standard(request('1C', override))
      end

      public
      def get_oxygen_sensors_present_4banks(override = false)
        @parser.parse_oxygen_sensors_present_4banks(request('1D', override))
      end

      public
      def get_auxiliary_input_status(override = false)
        @parser.parse_auxiliary_input_status(request('1E', override))
      end

      public
      def get_time_since_engine_start(override = false)
        @parser.parse_time_since_engine_start(request('1F', override))
      end

      public
      def get_distance_traveled_with_MIL_on(override = false)
        @parser.parse_distance_traveled_with_MIL_on(request('21', override))
      end

      public
      def get_fuel_rail_pressure(override = false)
        @parser.parse_fuel_rail_pressure(request('22', override))
      end

      public
      def get_fuel_rail_gauge_pressure(override = false)
        @parser.parse_fuel_rail_gauge_pressure(request('23', override))
      end

    end










    # noinspection RubyInstanceMethodNamingConvention
    class Parser < OBD::Parser

      public
      def parse_status_since_dtcc(input)
        raise_if_no_data(input.value, 'input.value')
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
        raise_if_no_data(input.value, 'input.value')
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
        raise_if_no_data(input.value, 'input.value')
        #FixMe: [0..1] OR [2..3]???
        a = Conversion.hex_to_dec(input.value[0..1])
        (a / 2.55).round(2)
      end

      public
      def parser_engine_coolant_temp(input)
        raise_if_no_data(input.value, 'input.value')
        a = Conversion.hex_to_dec(input.value)
        a - 40
      end

      public
      def parse_fuel_trim(input)
        raise_if_no_data(input.value, 'input.value')
        a = Conversion.hex_to_dec(input.value)
        (a / 1.28 - 100).round(1)
      end

      public
      def parse_fuel_pressure(input)
        raise_if_no_data(input.value, 'input.value')
        a = Conversion.hex_to_dec(input.value)
        a * 3
      end

      public
      def parse_intake_manifold_pressure(input)
        raise_if_no_data(input.value, 'input.value')
        Conversion.hex_to_dec(input.value)
      end

      public
      def parse_engine_rpm(input)
        raise_if_no_data(input.value, 'input.value')
        a = Conversion.hex_to_dec(input.value[0..1])
        b = Conversion.hex_to_dec(input.value[2..3])
        ((256.00 * a + b) / 4.00).round(2)
      end

      public
      def parse_vehicle_speed(input)
        raise_if_no_data(input.value, 'input.value')
        Conversion.hex_to_dec(input.value)
      end

      public
      def parse_timing_advance(input)
        raise_if_no_data(input.value, 'input.value')
        a = Conversion.hex_to_dec(input.value)
        ((a / 2.00) - 64.00).round(2)
      end

      public
      def parse_intake_air_temperature(input)
        raise_if_no_data(input.value, 'input.value')
        a = Conversion.hex_to_dec(input.value)
        a - 40
      end

      public
      def parse_maf_airflow_rate(input)
        raise_if_no_data(input.value, 'input.value')
        a = Conversion.hex_to_dec(input.value[0..1])
        b = Conversion.hex_to_dec(input.value[2..3])
        ((256.00 * a + b) / 100.00).round(2)
      end

      public
      def parse_throttle_position(input)
        raise_if_no_data(input.value, 'input.value')
        a = Conversion.hex_to_dec(input.value)
        (a / 2.55).round(2)
      end

      public
      def parse_commanded_secondary_air_status(input)
        raise_if_no_data(input.value, 'input.value')
        statuses = [
            'Upstream',
            'Downstream of catalytic converter',
            'From the outside atmosphere or off',
            'Pump commanded on for diagnostics'
        ]
        a = Conversion.hex_to_bin_rjust(input.value).reverse
        (a.size != 4 || a.count('1') != 1) ? 'Invalid Status' : statuses[a.index('1')]
      end

      public
      def parse_oxygen_sensors_present_2banks(input)
        raise_if_no_data(input.value, 'input.value')
        #ToDo: Should this raise an error when the binary string is shorter or longer than 8 bits?
        a = Conversion.hex_to_bin_rjust(input.value).reverse
        {
            :BANK_1 => {
                :SENSOR_1 => (a[0] == '1'),
                :SENSOR_2 => (a[1] == '1'),
                :SENSOR_3 => (a[2] == '1'),
                :SENSOR_4 => (a[3] == '1')
            },
            :BANK_2 => {
                :SENSOR_5 => (a[4] == '1'),
                :SENSOR_6 => (a[5] == '1'),
                :SENSOR_7 => (a[6] == '1'),
                :SENSOR_8 => (a[7] == '1')
            }
        }
      end

      public
      def parse_oxygen_sensor_status(input)
        raise_if_no_data(input.value, 'input.value')
        a = Conversion.hex_to_dec(input.value[0..1])
        b = Conversion.hex_to_dec(input.value[2..3])
        detect = Proc::new do |x|
          if x == 'FF'
            #ToDo does: "(if B==$FF, sensor is not used in trim calculation)" mean that STFT should be this? Or should B not be used in the equation.
            'Not used in trim calculation.'
          else
            (((100.0/128.0) * b) - 100.0).round(1)
          end
        end

        { :VOLTAGE => (a / 200.000).round(3), :STFT => detect.call(input.value[2..3])}
      end

      public
      def parse_conformed_obd_standard(input)
        raise_if_no_data(input.value, 'input.value')
        # <editor-fold desc="OBD Standards descriptions.">
        statuses = [
            'OBD-II as defined by the CARB',
            'OBD as defined by the EPA',
            'OBD and OBD-II',
            'OBD-I',
            'Not OBD compliant',
            'EOBD (Europe)',
            'EOBD and OBD-II',
            'EOBD and OBD',
            'EOBD, OBD and OBD II',
            'JOBD (Japan)',
            'JOBD and OBD II',
            'JOBD and EOBD',
            'JOBD, EOBD, and OBD II',
            'Reserved',
            'Reserved',
            'Reserved',
            'Engine Manufacturer Diagnostics (EMD)',
            'Engine Manufacturer Diagnostics Enhanced (EMD+)',
            'Heavy Duty On-Board Diagnostics (Child/Partial) (HD OBD-C)',
            'Heavy Duty On-Board Diagnostics (HD OBD)',
            'World Wide Harmonized OBD (WWH OBD)',
            'Reserved',
            'Heavy Duty Euro OBD Stage I without NOx control (HD EOBD-I)',
            'Heavy Duty Euro OBD Stage I with NOx control (HD EOBD-I N)',
            'Heavy Duty Euro OBD Stage II without NOx control (HD EOBD-II)',
            'Heavy Duty Euro OBD Stage II with NOx control (HD EOBD-II N)',
            'Reserved',
            'Brazil OBD Phase 1 (OBDBr-1)',
            'Brazil OBD Phase 2 (OBDBr-2)',
            'Korean OBD (KOBD)',
            'India OBD I (IOBD I)',
            'India OBD II (IOBD II)',
            'Heavy Duty Euro OBD Stage VI (HD EOBD-IV)'
        ]
        # </editor-fold>
        a = Conversion.hex_to_dec(input.value)

        case a
          when a == 0 || a > 255 # Not in the range of valid statuses.
            'Invalid Status'
          when 34..250 # Reserved range.
            'Reserved'
          when 251..255 # Special meaning for SAE J1939 standard.
            'Not available for assignment'
          else # Is in the valid range.
            statuses[(a - 1)]
        end
      end

      public
      def parse_oxygen_sensors_present_4banks(input)
        raise_if_no_data(input.value, 'input.value')
        #ToDo: Should this raise an error when the binary string is shorter or longer than 8 bits?
        a = Conversion.hex_to_bin_rjust(input.value).reverse
        {
            :BANK_1 => {
                :SENSOR_1 => (a[0] == '1'),
                :SENSOR_2 => (a[1] == '1')
            },
            :BANK_2 => {
                :SENSOR_5 => (a[2] == '1'),
                :SENSOR_6 => (a[3] == '1')
            },
            :BANK_3 => {
                :SENSOR_5 => (a[4] == '1'),
                :SENSOR_6 => (a[5] == '1')
            },
            :BANK_4 => {
                :SENSOR_5 => (a[6] == '1'),
                :SENSOR_6 => (a[7] == '1')
            }
        }
      end

      public
      def parse_auxiliary_input_status(input)
        raise_if_no_data(input.value, 'input.value')
        a = Conversion.hex_to_bin_rjust(input.value).reverse
        { :PTO => (a[0] == '1') }
      end

      public
      def parse_time_since_engine_start(input)
        raise_if_no_data(input.value, 'input.value')
        a = Conversion.hex_to_dec(input.value[0..1])
        b = Conversion.hex_to_dec(input.value[2..3])
        (256 * a + b)
      end

      public
      def parse_distance_traveled_with_MIL_on(input)
        raise_if_no_data(input.value, 'input.value')
        a = Conversion.hex_to_dec(input.value[0..1])
        b = Conversion.hex_to_dec(input.value[2..3])
        (256 * a + b)
      end

      public
      def parse_fuel_rail_pressure(input)
        raise_if_no_data(input.value, 'input.value')
        a = Conversion.hex_to_dec(input.value[0..1])
        b = Conversion.hex_to_dec(input.value[2..3])
        (256.00 * a + b) * 0.079
      end

      public
      def parse_fuel_rail_gauge_pressure(input)
        raise_if_no_data(input.value, 'input.value')
        a = Conversion.hex_to_dec(input.value[0..1])
        b = Conversion.hex_to_dec(input.value[2..3])
        (256 * a + b) * 10
      end

    end

  end

end