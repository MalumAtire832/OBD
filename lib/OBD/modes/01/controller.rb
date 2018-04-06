require 'OBD/abstract/controller'

module OBD
  module M01
    class Controller < OBD::Controller

      def initialize(settings)
        super(OBD::Mode::new('01', %w(00 20 40 60 80 A0 C0)), settings)
        @parser = OBD::M01::Parser::new
      end

      def get_status_since_dtcc(override = false)
        @parser.parse_status_since_dtcc(request('01', override))
      end

      def get_fuel_system_status(override = false)
        @parser.parse_fuel_system_status(request('03', override))
      end

      def get_engine_load(override = false)
        @parser.parse_engine_load(request('04', override))
      end

      def get_engine_coolant_temp(override = false)
        @parser.parser_engine_coolant_temp(request('05', override))
      end

      def get_fuel_trim(override = false)
        {
            :STFT_B1 => @parser.parse_fuel_trim(request('06', override)),
            :LTFT_B1 => @parser.parse_fuel_trim(request('07', override)),
            :STFT_B2 => @parser.parse_fuel_trim(request('08', override)),
            :LTFT_B2 => @parser.parse_fuel_trim(request('09', override))
        }
      end

      def get_fuel_pressure(override = false)
        @parser.parse_fuel_pressure(request('0A', override))
      end

      def get_intake_manifold_pressure(override = false)
        @parser.parse_intake_manifold_pressure(request('0B', override))
      end

      def get_engine_rpm(override = false)
        @parser.parse_engine_rpm(request('0C', override))
      end

      def get_vehicle_speed(override = false)
        @parser.parse_vehicle_speed(request('0D', override))
      end

      def get_timing_advance(override = false)
        @parser.parse_timing_advance(request('0E', override))
      end

      def get_intake_air_temperature(override = false)
        @parser.parse_intake_air_temperature(request('0F', override))
      end

      def get_maf_airflow_rate(override = false)
        @parser.parse_maf_airflow_rate(request('10', override))
      end

      def get_throttle_position(override = false)
        @parser.parse_throttle_position(request('11', override))
      end

      def get_commanded_secondary_air_status(override = false)
        @parser.parse_commanded_secondary_air_status(request('12', override))
      end

      def get_oxygen_sensors_present_2banks(override = false)
        @parser.parse_oxygen_sensors_present_2banks(request('13', override))
      end

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

      def get_conformed_obd_standard(override = false)
        @parser.parse_conformed_obd_standard(request('1C', override))
      end

      def get_oxygen_sensors_present_4banks(override = false)
        @parser.parse_oxygen_sensors_present_4banks(request('1D', override))
      end

      def get_auxiliary_input_status(override = false)
        @parser.parse_auxiliary_input_status(request('1E', override))
      end

      def get_time_since_engine_start(override = false)
        @parser.parse_time_since_engine_start(request('1F', override))
      end

      def get_distance_traveled_with_MIL_on(override = false)
        @parser.parse_distance_traveled_with_MIL_on(request('21', override))
      end

      def get_fuel_rail_pressure(override = false)
        @parser.parse_fuel_rail_pressure(request('22', override))
      end

      def get_fuel_rail_gauge_pressure(override = false)
        @parser.parse_fuel_rail_gauge_pressure(request('23', override))
      end

      def get_oxygen_sensors_status_2(override = false)
        pids, result = %w(24 25 26 27 28 29 2A 2B), {}
        (1..8).map do |i|
          begin
            result["SENSOR_#{i}".to_sym] = @parser.parse_oxygen_sensor_status_2(request(pids[i-1], override))
          rescue OBD::PidError
            result["SENSOR_#{i}".to_sym] = {:FUEL_AIR_RATIO => "Unsupported", :VOLTAGE => "Unsupported"}
          end
        end
      end

      def get_commanded_EGR(override = false)
        @parser.parse_commanded_EGR(request('2C', override))
      end

    end
  end
end