# OBD


<img src="https://i.imgur.com/7I4CzOt.png" alt="OBD Logo" height="200"><br><br>

OBD is a gem that can be used to connect to a car's OBD interface.  
The gem is currently in alpha, but some features are already working:
- Connecting to OBD via serialport.
    - Requesting commands and returning their responses.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'OBD'
```

And then execute:

    $ bundle install

Or install it yourself:

    $ gem install OBD

## Usage

The gem features build in functionality for requesting and parsing data from different [OBD modes](https://en.wikipedia.org/wiki/OBD-II_PIDs#Mode_1_PID_1C).
(Currently only mode '01', PID '01 through 1F')

```ruby
require 'OBD'

# A settings object that connect to a seriaport @/dev/ttys001, 
# with a baudrate of 9660,
# 8 data bits, 
# 1 stop bit, 
# and 0 parity bits.
settings = OBD::Connection::Settings::new("/dev/ttys001", 9600, 8, 1, 0)

# A Mode Controller for the mode with identifier '01'.
# This controller executes each request.
controller = OBD::Mode_01::Controller::new(settings)

# The following methods return their values in a parsed format.
standard = controller.get_conformed_obd_standard    # String identifier.
ox_stat = controller.get_oxygen_sensors_status      # Hash -> See sources or API documentation.
ox2 = controller.get_oxygen_sensors_present_2banks  # ^
ox4 = controller.get_oxygen_sensors_present_4banks  # ^
air_temp = controller.get_intake_air_temperature    # Degrees celsius
speed = controller.get_vehicle_speed                # Km/h
```

It is also possible to do these requests manually.

```ruby
require 'OBD'

# A settings object that connect to a seriaport @/dev/ttys001, 
# with a baudrate of 9660,
# 8 data bits, 
# 1 stop bit, 
# and 0 parity bits.
settings = OBD::Connection::Settings::new("/dev/ttys001", 9600, 8, 1, 0)

# A mode to operate on, the mode number is '01' 
# [followed by all the hex indexes where the supported pids are located](https://en.wikipedia.org/wiki/OBD-II_PIDs).
mode = OBD::Mode::new("01", ["00", "20", "40", "60", "80", "A0", "C0"])

# The controller which executes each request.
controller = OBD::Controller::new(mode, settings)

# The request we want to execute, we are requesting '010D'.
# Which returns a OBD::Requester::Result object with the raw Hexadecimal value.
result = controller.request("0D")
```

But you are of course not limited to these functions.
If you want to build your own set of commands you can do it like this:

```ruby
require 'OBD'

class MyController < OBD::Controller

    def initialize(settings)
       super(OBD::Mode::new('01', ['00', '20', '40']), settings)
       @parser = MyParser::new
    end
    
    def get_speed_in_mph(override = false)
      @parser.parse_speed_in_mph(request('0D', override))
    end

end

class MyParser < OBD::Parser

    def parse_speed_in_mph(input)
      raise_if_no_data(input.value, 'input.value')
      a = Conversion.hex_to_dec(input.value)
      (a * 1.609)
    end

end
```


## Testing

The tests are made using RSpec.  
You can run them like this: `DEVICE="/device/" rspec spec --format doc`  
The `DEVICE` parameter is required to run some of the tests, `/device/` is the port for your device.   
Which is a variant of `/dev/ttys00x` for MacOS and a `COM port` for Windows.  
It is recommended to use [OBD-sim](https://icculus.org/obdgpslogger/obdsim.html) to test the gem.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/MalumAtire832/OBD.


## License

The gem is available as open source under the terms of the [GNU GPLV3 License](https://www.gnu.org/licenses/gpl-3.0.nl.html).
