module PuppetX
  module CenturyLink
    module Property
      class CustomField < Puppet::Property
        validate do |value|
          fields = value.is_a?(Array) ? value : [value]
          fields.each do |field|
            fail 'custom field must be a hash' unless field.is_a?(Hash)

            field_id = field['id'] || field[:id]
            if field_id.nil? || field_id.strip == ''
              fail 'custom field must have an id'
            end

            field_value = field['value'] || field[:value]
            if field_value.nil? || field_value.strip == ''
              fail 'custom field must have a value'
            end
          end
        end
      end
    end
  end
end
