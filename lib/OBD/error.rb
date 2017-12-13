module OBD

  class Error < StandardError

    def initialize(msg)
      super(msg)
    end

  end

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