require 'OBD/abstract/parser'
require 'OBD/conversion'

module OBD
  module M01
    include Conversion
    class Parser < OBD::Parser

      def parse_status_since_dtcc(input)
        raise_if_no_data(input.value, 'input.value')
        ctb = Proc::new {|i| hex_to_bin_rjust(i).reverse} # Convert To Binary
        a, b, c, d = input.value[0..1], input.value[2..3], input.value[4..5], input.value[6..7]
        a_binary, b_binary, c_binary, d_binary = ctb.call(a), ctb.call(b), ctb.call(c), ctb.call(d)
        {
            :MIL            => (a_binary[7].to_i),
            :DTC_CNT        => hex_to_dec(a[0..6]),
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
        a = hex_to_bin_rjust(input.value[0..1]).reverse
        b = hex_to_bin_rjust(input.value[2..3]).reverse
        detect = Proc::new do |x|
          if x.size != 8 || x.count('1') != 1 || x.index('1') > 4
            "Invalid Status"
          else
            statuses[x.index('1')]
          end
        end

        {:FUEL_SYSTEM_1 => detect.call(a), :FUEL_SYSTEM_2 => detect.call(b)}
      end

      def parse_engine_load(input)
        raise_if_no_data(input.value, 'input.value')
        #FixMe: [0..1] OR [2..3]???
        a = hex_to_dec(input.value[0..1])
        (a / 2.55).round(2)
      end

      def parser_engine_coolant_temp(input)
        raise_if_no_data(input.value, 'input.value')
        a = hex_to_dec(input.value)
        a - 40
      end

      def parse_fuel_trim(input)
        raise_if_no_data(input.value, 'input.value')
        a = hex_to_dec(input.value)
        (a / 1.28 - 100).round(1)
      end

      def parse_fuel_pressure(input)
        raise_if_no_data(input.value, 'input.value')
        a = hex_to_dec(input.value)
        a * 3
      end

      def parse_intake_manifold_pressure(input)
        raise_if_no_data(input.value, 'input.value')
        hex_to_dec(input.value)
      end

      def parse_engine_rpm(input)
        raise_if_no_data(input.value, 'input.value')
        a = hex_to_dec(input.value[0..1])
        b = hex_to_dec(input.value[2..3])
        ((256.00 * a + b) / 4.00).round(2)
      end

      def parse_vehicle_speed(input)
        raise_if_no_data(input.value, 'input.value')
        hex_to_dec(input.value)
      end

      def parse_timing_advance(input)
        raise_if_no_data(input.value, 'input.value')
        a = hex_to_dec(input.value)
        ((a / 2.00) - 64.00).round(2)
      end

      def parse_intake_air_temperature(input)
        raise_if_no_data(input.value, 'input.value')
        a = hex_to_dec(input.value)
        a - 40
      end

      def parse_maf_airflow_rate(input)
        raise_if_no_data(input.value, 'input.value')
        a = hex_to_dec(input.value[0..1])
        b = hex_to_dec(input.value[2..3])
        ((256.00 * a + b) / 100.00).round(2)
      end

      def parse_throttle_position(input)
        raise_if_no_data(input.value, 'input.value')
        a = hex_to_dec(input.value)
        (a / 2.55).round(2)
      end

      def parse_commanded_secondary_air_status(input)
        raise_if_no_data(input.value, 'input.value')
        statuses = [
            'Upstream',
            'Downstream of catalytic converter',
            'From the outside atmosphere or off',
            'Pump commanded on for diagnostics'
        ]
        a = hex_to_bin_rjust(input.value).reverse
        (a.size != 4 || a.count('1') != 1) ? 'Invalid Status' : statuses[a.index('1')]
      end

      def parse_oxygen_sensors_present_2banks(input)
        raise_if_no_data(input.value, 'input.value')
        #ToDo: Should this raise an error when the binary string is shorter or longer than 8 bits?
        a = hex_to_bin_rjust(input.value).reverse
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

      def parse_oxygen_sensor_status(input)
        raise_if_no_data(input.value, 'input.value')
        a = hex_to_dec(input.value[0..1])
        b = hex_to_dec(input.value[2..3])
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
        a = hex_to_dec(input.value)

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

      def parse_oxygen_sensors_present_4banks(input)
        raise_if_no_data(input.value, 'input.value')
        #ToDo: Should this raise an error when the binary string is shorter or longer than 8 bits?
        a = hex_to_bin_rjust(input.value).reverse
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

      def parse_auxiliary_input_status(input)
        raise_if_no_data(input.value, 'input.value')
        a = hex_to_bin_rjust(input.value).reverse
        { :PTO => (a[0] == '1') }
      end

      def parse_time_since_engine_start(input)
        raise_if_no_data(input.value, 'input.value')
        a = hex_to_dec(input.value[0..1])
        b = hex_to_dec(input.value[2..3])
        (256 * a + b)
      end

      def parse_distance_traveled_with_MIL_on(input)
        raise_if_no_data(input.value, 'input.value')
        a = hex_to_dec(input.value[0..1])
        b = hex_to_dec(input.value[2..3])
        (256 * a + b)
      end

      def parse_fuel_rail_pressure(input)
        raise_if_no_data(input.value, 'input.value')
        a = hex_to_dec(input.value[0..1])
        b = hex_to_dec(input.value[2..3])
        (256.00 * a + b) * 0.079
      end

      def parse_fuel_rail_gauge_pressure(input)
        raise_if_no_data(input.value, 'input.value')
        a = hex_to_dec(input.value[0..1])
        b = hex_to_dec(input.value[2..3])
        (256 * a + b) * 10
      end

      def parse_oxygen_sensor_status_2(input) # ToDo: Needs a better name.
        raise_if_no_data(input.value, 'input.value')
        a = hex_to_dec(input.value[0..1])
        b = hex_to_dec(input.value[2..3])
        c = hex_to_dec(input.value[4..5])
        d = hex_to_dec(input.value[6..7])
        {
            :FUEL_AIR_RATIO => (0.000030517578125 * (256 * a + b)).round(6), # (2/65536) * (256 * a + b)
            :VOLTAGE        => (0.0001220703125 * (256 * c + d)).round(6)    # (8/65536) * (256 * c + d)
        }
      end

      def parse_commanded_EGR(input)
        raise_if_no_data(input.value, 'input.value')
        a = hex_to_dec(input.value)
        ((100.00 / 255.00) * a).round(2)
      end

    end
  end
end