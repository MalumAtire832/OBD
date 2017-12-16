require 'OBD'
require 'awesome_print'
require 'pp'
require 'spec_helper'

RSpec.describe OBD::Mode_01::Controller do



  before do
    @settings = OBD::Connection::Settings::new($device, 9600, 8, 1, 0)
    @controller = OBD::Mode_01::Controller::new(@settings)
  end



  describe ".get_fuel_system_status" do

    before do
      @statuses = [
          'Open loop due to insufficient engine temperature',
          'Closed loop, using oxygen sensor feedback to determine fuel mix',
          'Open loop due to engine load OR fuel cut due to deacceleration',
          'Open loop due to system failure',
          'Closed loop, using at least one oxygen sensor but there is a fault in the feedback system',
          'Invalid Status'
      ]
      @result = @controller.get_fuel_system_status
    end

    it "should contain 2 keys" do
      expect(@result.keys.count).to equal 2
    end

    it "should have keys which are named :FUEL_SYSTEM_1 and FUEL_SYSTEM_2" do
      expect(@result.key? :FUEL_SYSTEM_1).to be true
      expect(@result.key? :FUEL_SYSTEM_2).to be true
    end

    it "should have values that are in a predetermined list." do
      @result.values.each {|v| expect(@statuses).to include(v)}
    end

  end



  describe ".get_engine_load" do

    before do
      @result = test_single_value(100) {@controller.get_engine_load}
      debug("LOW: #{@result[:LOW]}", 4)
      debug("HIGH: #{@result[:HIGH]}", 4)
    end

    it "should range from 0-100%" do
      expect(@result[:LOW]).to be >= 0
      expect(@result[:HIGH]).to be <= 100
    end

  end



  describe ".get_engine_coolant_temp" do

    before do
      @result = test_single_value(100) {@controller.get_engine_coolant_temp}
      debug("LOW: #{@result[:LOW]}", 4)
      debug("HIGH: #{@result[:HIGH]}", 4)
    end

    it "should range from -40 to 215 degrees celsius." do
      expect(@result[:LOW]).to be >= -40
      expect(@result[:HIGH]).to be <= 215
    end

  end



  describe ".get_fuel_trim" do

    before do
      @result = test_multiple_values(100) {@controller.get_fuel_trim}
      @result.each_key {|key| debug("#{key}: #{@result[key]}", 4)}
    end

    it "should range from -100 to 99.2%" do
      @result.each_key do |key|
        expect(@result[key][:LOW]).to be >= -100
        expect(@result[key][:HIGH]).to be <= 99.2
      end
    end

  end



  describe ".get_fuel_pressure" do

    before do
      @result = test_single_value(250) {@controller.get_fuel_pressure}
      debug("LOW: #{@result[:LOW]}", 4)
      debug("HIGH: #{@result[:HIGH]}", 4)
    end

    it "should range from 0 to 765 kPa." do
      expect(@result[:LOW]).to be >= 0
      expect(@result[:HIGH]).to be <= 765
    end

  end



  describe ".get_intake_manifold_pressure" do

    before do
      @result = test_single_value(100) {@controller.get_intake_manifold_pressure}
      debug("LOW: #{@result[:LOW]}", 4)
      debug("HIGH: #{@result[:HIGH]}", 4)
    end

    it "should range from 0 to 255 kPa." do
      expect(@result[:LOW]).to be >= 0
      expect(@result[:HIGH]).to be <= 255
    end

  end



  describe ".get_engine_rpm" do

    before do
      @result = test_single_value(100) {@controller.get_engine_rpm}
      debug("LOW: #{@result[:LOW]}", 4)
      debug("HIGH: #{@result[:HIGH]}", 4)
    end

    it "should range from 0 to 16,383.75 RPM." do
      expect(@result[:LOW]).to be >= 0
      expect(@result[:HIGH]).to be <= 16383.75
    end

  end



  describe ".get_vehicle_speed" do

    before do
      @result = test_single_value(100) {@controller.get_vehicle_speed}
      debug("LOW: #{@result[:LOW]}", 4)
      debug("HIGH: #{@result[:HIGH]}", 4)
    end

    it "should range from 0 to 255 km/h." do
      expect(@result[:LOW]).to be >= 0
      expect(@result[:HIGH]).to be <= 255
    end

  end



  describe ".get_timing_advance" do

    before do
      @result = test_single_value(50) {@controller.get_timing_advance}
      debug("LOW: #{@result[:LOW]}", 4)
      debug("HIGH: #{@result[:HIGH]}", 4)
    end

    it "should range from -64 to 63.5 degrees before TDC." do
      expect(@result[:LOW]).to be >= -64
      expect(@result[:HIGH]).to be <= 63.5
    end

  end



  describe ".get_intake_air_temperature" do

    before do
      @result = test_single_value(100) {@controller.get_intake_air_temperature}
      debug("LOW: #{@result[:LOW]}", 4)
      debug("HIGH: #{@result[:HIGH]}", 4)
    end

    it "should range from -40 to 215 degrees celsius." do
      expect(@result[:LOW]).to be >= -40
      expect(@result[:HIGH]).to be <= 215
    end

  end



  describe ".get_maf_airflow_rate" do

    before do
      @result = test_single_value(150) {@controller.get_maf_airflow_rate}
      debug("LOW: #{@result[:LOW]}", 4)
      debug("HIGH: #{@result[:HIGH]}", 4)
    end

    it "should range from 0 to 655.35 grams/sec." do
      expect(@result[:LOW]).to be >= 0
      expect(@result[:HIGH]).to be <= 655.35
    end

  end



  describe ".get_throttle_position" do

    before do
      @result = test_single_value(50) {@controller.get_throttle_position}
      debug("LOW: #{@result[:LOW]}", 4)
      debug("HIGH: #{@result[:HIGH]}", 4)
    end

    it "should range from 0 to 100%" do
      expect(@result[:LOW]).to be >= 0
      expect(@result[:HIGH]).to be <= 100
    end

  end



  describe ".get_commanded_secondary_air_status" do

    before do
      @statuses = [
          'Upstream',
          'Downstream of catalytic converter',
          'From the outside atmosphere or off',
          'Pump commanded on for diagnostics',
          'Invalid Status'
      ]
      @result = test_array_value(50) {@controller.get_commanded_secondary_air_status}
    end

    it "should only contain values from a predetermined list." do
      @result.each {|v| expect(@statuses).to include(v)}
    end

  end



  describe ".get_oxygen_sensors_present_2banks" do

    before do
      #ToDo: This should test more than one return value.
      @result = @controller.get_oxygen_sensors_present_2banks
    end

    context "the method returns a hash with banks, which contain sensors." do

      it "the hash should have 2 'banks'." do
        expect(@result.keys.count).to eq 2
      end

      it "each bank should have 4 'sensors'." do
        @result.keys.each do |bank|
          expect(@result[bank].keys.count).to eq 4
        end
      end

      it "each sensor should be either 'true' or 'false'." do
        @result.keys.each do |bank|
          @result[bank].keys.each do |sensor|
            expect(@result[bank][sensor]).to be(true).or be(false)
          end
        end
      end

    end

  end



  describe ".get_oxygen_sensors_status" do

    before do
      #ToDo: This should test more than one return value.
      @result = @controller.get_oxygen_sensors_status
    end

    context "the method returns a hash with 'sensors'." do

      it "the hash should have 8 'sensors'." do
        expect(@result.keys.count).to eq 8
      end

      it "each 'sensor' should have 2 values." do
        @result.keys.each do |sensor|
          expect(@result[sensor].keys.count).to eq 2
        end
      end

      it "each sensors 'VOLTAGE' should be between 0 and 1.275 Volts." do
        @result.keys.each do |sensor|
          expect(@result[sensor][:VOLTAGE]).to be >= 0
          expect(@result[sensor][:VOLTAGE]).to be <= 1.275
        end
      end

      it "each sensors 'Short Term Fuel Trim' should be between -100 and 99.2%, or 'Not used in trim calculation'." do
        @result.keys.each do |sensor|
          if sensor.is_a? String
            expect(@result[sensor][:STFT]).to eq 'Not used in trim calculation'
          else
            expect(@result[sensor][:STFT]).to be >= -100
            expect(@result[sensor][:STFT]).to be <= 99.2
          end
        end
      end
    end

  end



  describe ".get_conformed_obd_standard" do

    before do
      #ToDo: This should test more than one return value.
      @result = test_array_value(100) {@controller.get_conformed_obd_standard}
      @statuses = # <editor-fold desc="OBD Standards descriptions.">
          [
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
              'Heavy Duty Euro OBD Stage VI (HD EOBD-IV)',

              # Other values
              'Invalid Status',
              'Reserved',
              'Not available for assignment'
          ]
      # </editor-fold>
    end

    it "should only have values from a predetermined list," do
      @result.each {|x| expect(@statuses).to include(x)}
    end

  end



  describe ".get_oxygen_sensors_present_4banks" do

    before do
      #ToDo: This should test more than one return value.
      @result = @controller.get_oxygen_sensors_present_4banks
    end

    context "the method returns a hash with 'banks', which contain sensors." do

      it "the hash should have 4 'banks'." do
        expect(@result.keys.count).to eq 4
      end

      it "each 'bank' should have 2 'sensors'." do
        @result.keys.each do |bank|
          expect(@result[bank].keys.count).to eq 2
        end
      end

      it "each 'sensor' should be either 'true' or 'false'." do
        @result.keys.each do |bank|
          @result[bank].keys.each do |sensor|
            expect(@result[bank][sensor]).to be(true).or be(false)
          end
        end
      end
    end

  end



  describe ".get_auxiliary_input_status" do

    before do
      @result = test_array_value(10) {@controller.get_auxiliary_input_status[:PTO]}
    end

    it "should be either 'true' or 'false'" do
      @result.each {|x| expect(x).to be(true).or be(false)}
    end

  end



  describe ".get_time_since_engine_start" do

    before do
      @result = test_single_value(250) {@controller.get_time_since_engine_start}
      debug("LOW: #{@result[:LOW]}", 4)
      debug("HIGH: #{@result[:HIGH]}", 4)
    end

    it "should range from 0 to 65535" do
      expect(@result[:LOW]).to be >= 0
      expect(@result[:HIGH]).to be <= 65535
    end

  end

end
