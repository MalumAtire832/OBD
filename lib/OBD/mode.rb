module OBD

  class Mode

    attr_reader :code, :indexes
    attr_accessor :supported_pids

    SUPPORTED = 10
    NOT_SUPPORTED = 00
    MISSING = 01

    public
    def initialize(code, indexes)
      @code = code
      @indexes = indexes
      @supported_pids = {}
    end

    public
    # noinspection RubyNestedTernaryOperatorsInspection
    def is_pid_supported?(code)
      supported = @supported_pids[code]
      supported.nil? ? [false, MISSING] : supported ? [true, SUPPORTED] : [false, NOT_SUPPORTED]
    end




    class Pid

      attr_reader :code

      public
      def initialize(code, supported)
        @code = code
        @supported = supported
      end

      public
      def is_supported?
        @supported
      end

    end

  end

end