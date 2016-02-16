module PuppetX
  module CenturyLink
    module Property
      class Hash < Puppet::Property
        validate do |value|
          fail 'must be a hash' unless value.is_a?(::Hash)
        end
      end
    end
  end
end
