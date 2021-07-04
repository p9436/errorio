module Errorio
  # Error object for errors collection
  class Error
    def initialize(base, attribute, type, options)
      @base = base
      @attribute = attribute
      @type = type
      @options = options.symbolize_keys
    end

    attr_reader :base
    attr_reader :attribute
    attr_reader :type
    attr_reader :options

    def message
      options[:message]
    end

    # Returns a full message for a given attribute.
    # person.errors.full_message(:name, 'is invalid') # => "Name is invalid"
    def full_message(attribute, message)
      attr_name = attribute.to_s.tr('.', '_').humanize
      return "#{attr_name} #{message}" if @base.nil?

      attr_name = @base.class.human_attribute_name(attribute, default: attr_name)
      I18n.t(:"errors.format", default: '%{attribute} %{message}', attribute: attr_name, message: message)
    end
  end
end
