module Errorio
  # Collection of error objects
  class Errors
    extend Forwardable
    def_delegators :@errors, :size, :clear, :blank?, :empty?, :uniq!, :any?

    attr_reader :errors
    alias objects errors

    def initialize(base = nil)
      @base = base
      @errors = []
    end

    def add(attribute, type = :invalid, **options)
      error = Error.new(@base, attribute, type, **options)

      @errors.append(error)

      error
    end

    # Returns all error attribute names
    #
    #   person.errors.messages        # => {:name=>["cannot be nil", "must be specified"]}
    #   person.errors.attribute_names # => [:name]
    def attribute_names
      @errors.map(&:attribute).uniq.freeze
    end
    alias keys attribute_names

    # Returns a full message for a given attribute.
    # person.errors.full_message(:name, 'is invalid') # => "Name is invalid"
    def full_message(attribute, message)
      attr_name = attribute.to_s.tr('.', '_').humanize
      return "#{attr_name} #{message}" if @base.nil?

      attr_name = @base.class.human_attribute_name(attribute, default: attr_name)
      I18n.t(:"errors.format", default: '%{attribute} %{message}', attribute: attr_name, message: message)
    end

    def each(&block)
      @errors.each(&block)
    end
  end
end
