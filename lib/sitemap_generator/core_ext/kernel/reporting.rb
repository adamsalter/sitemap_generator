require 'rbconfig'
unless Kernel.method_defined?(:silence_warnings)
  module Kernel
    # Sets $VERBOSE to nil for the duration of the block and back to its original value afterwards.
    #
    #   silence_warnings do
    #     value = noisy_call # no warning voiced
    #   end
    #
    #   noisy_call # warning voiced
    def silence_warnings
      with_warnings(nil) { yield }
    end

    # Sets $VERBOSE to true for the duration of the block and back to its original value afterwards.
    def enable_warnings
      with_warnings(true) { yield }
    end

    # Sets $VERBOSE for the duration of the block and back to its original value afterwards.
    def with_warnings(flag)
      old_verbose, $VERBOSE = $VERBOSE, flag
      yield
    ensure
      $VERBOSE = old_verbose
    end
  end
end
