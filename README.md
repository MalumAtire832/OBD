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

The gem features some build in functionality for parsing data from different OBD modes.

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
# Which is the current speed of the car.
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
    
    def request_01xx(override = false)
      @parser.parse_01xx(request('xx', override))
    end

end

class MyParser < OBD::Parser

    def parse_01xx(input)
      # Parse input.value.
    end

end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/MalumAtire832/OBD.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
