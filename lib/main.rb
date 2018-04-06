require_relative '../lib/OBD/modes/_01'
require_relative '../lib/OBD/ection'
require 'pp'

controller = OBD::Mode_01::Controller.new({:device => '/dev/pts/6'})
pp controller.get_settings