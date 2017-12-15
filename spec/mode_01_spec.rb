require 'OBD'
require 'awesome_print'
require 'pp'
require 'spec_helper'

RSpec.describe OBD::Mode_01::Controller do

  before do
    # system("./obdsim -g Random")
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

end
