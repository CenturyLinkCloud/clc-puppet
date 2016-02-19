module PuppetX
  module CenturyLink
    class PrefetchError < Exception
      def initialize(type, exception=nil)
        @type = type
        @exception = exception
      end

      def to_s
        """Puppet detected a problem with the information returned from CenturyLink Cloud when accessing #{@type}. The specific error was:
#{@exception.message}
#{@exception.backtrace.join("\n")}
"""
      end
    end
  end
end
