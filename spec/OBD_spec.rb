require 'OBD'

RSpec.describe OBD do

  context "setup the obdsim device" do

    it "should contain a device string." do
      $device = ENV["DEVICE"].to_s
      expect($device).not_to be_empty
    end

  end

end