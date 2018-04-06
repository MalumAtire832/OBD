require 'OBD'
require 'pp'

controller = OBD::M01::Controller.new({:device => '/dev/ttys2'})
pp controller.get_vehicle_speed