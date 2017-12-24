require_relative '../lib/OBD/modes/mode_01'
require_relative '../lib/OBD/connection'
require 'pp'

controller = OBD::Mode_01::Controller.new({:device => '/dev/pts/6'})
pp controller.get_settings