require 'OBD'
require 'pp'

controller = OBD::M01::Controller.new({:device => '/dev/pts/3'})
pp controller.get_settings