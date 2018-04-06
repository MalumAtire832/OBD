module OBD

  class Mode

    attr_reader :code, :indexes
    attr_accessor :supported_pids

    SUPPORTED ||= 10
    MISSING ||= 01
    NOT_SUPPORTED ||= 00

    def initialize(code, indexes)
      @code = code
      @indexes = indexes
      @supported_pids = {}
    end

    # noinspection RubyNestedTernaryOperatorsInspection
    def is_pid_supported?(code)
      supported = @supported_pids[code]
      supported.nil? ? [false, MISSING] : supported ? [true, SUPPORTED] : [false, NOT_SUPPORTED]
    end




    class Pid

      attr_reader :code

      def initialize(code, supported)
        @code = code
        @supported = supported
      end

      def is_supported?
        @supported
      end

    end

  end

end