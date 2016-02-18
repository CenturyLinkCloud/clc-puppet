module PuppetX
  module CenturyLink
    module Property
      class ReadOnly < Puppet::Property
        validate do |value|
          fail "#{self.name.to_s} is read-only"
        end
      end
    end
  end
end
