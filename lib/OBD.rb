
module OBD

  require 'OBD/conversion'
  require 'OBD/version'

  require 'OBD/abstract/controller'
  require 'OBD/abstract/mode'
  require 'OBD/abstract/parser'

  require 'OBD/io/connection'
  require 'OBD/io/requester'

  require 'OBD/modes/01/controller'
  require 'OBD/modes/01/parser'



  class Error < StandardError; end

  class ParameterError < OBD::Error

    public
    def self.missing(parameter)
      OBD::ParameterError::new(msg="Parameter '#{parameter}' is missing a value.")
    end

    public
    def self.mismatch(parameter, expected, actual)
      OBD::ParameterError::new(msg="Parameter '#{parameter}' expected a value of '#{expected}', actually is '#{actual}'")
    end

    public
    def self.format(parameter, contains)
      OBD::ParameterError::new(msg="Parameter '#{parameter}' should not contain '#{contains}'")
    end

    public
    def self.nodata(parameter, actual)
      OBD::ParameterError::new(msg="Parameter '#{parameter}' contains no data, value is: '#{actual}'")
    end

  end

  class PidError < OBD::Error

    public
    def self.unsupported(pid, mode='')
      message = (mode == '' ? "PID '#{pid}' is not supported." : "PID '#{pid}' is not supported for mode '#{mode}'")
      OBD::PidError::new(msg=message)
    end

    public
    def self.missing(pid, mode='')
      message = (mode == '' ? "PID '#{pid}' is missing." : "PID '#{pid}' is missing for mode '#{mode}'")
      OBD::PidError::new(msg=message)
    end

  end

end
