require 'errorio/version'
require 'errorio/details'
require 'errorio/errors'
require 'errorio/error'

# Errorio
#
# Extend your models and classes with errors, warnings and other notices
#
# Examples:
#
# Extend ordinary AR model with special collection of +warnings+ and +notices+
#
# class Task < ApplicationRecord
#   include Errorio
#   errorionize :errors, :warnings, :notices # :errors is initialized by ActiveRecord, so it is redundant in this case
#
#   validates :name, presence: { code: :E0230 }
#   validate :special_characters_validation
#
#   private
#
#   def special_characters_validation
#     return if name =~ /^[a-z0-9]*$/i
#     exceptions = name.gsub(/[^a-z0-9]/i).map{ |a| "'#{a}'" }.join(','),
#     warnings.add(:name, :special_characters, code: :E0231,
#                                              chars: exceptions,
#                                              message: 'Special characters are not recommended for name')
#   end
# end
#
# result = Task.create
# result.errors.to_e
# =>
# [
#   {
#     :code=>:E0230,
#     :key=>:name,
#     :type=>:blank,
#     :message=>"Task Name can't be blank"
#   }
# ]
#
# result = Task.create 'Do * now!'
# result.errors.to_e
# =>
# []
# result.warnings.to_e
# =>
# [
#   {
#     :code=>:E0231,
#     :key=>:name,
#     :type=>:special_characters,
#     :message=>"Special characters ('*', '!') are not recommended for name"
#   }
# ]
#
# Message should be described in en.yml file
#
# errorio:
#   messages:
#     E0231: "Special characters (%{chars}) are not recommended for name"
#
# Implement errors and warnings to service class
#
# class Calculate
#   include Errorio
#   errorionize :errors, :warnings
#
#   def initialize(a, b)
#     @a = a
#     @b = b
#   end
#
#   def sum
#     return unless valid?
#     a + b
#   end
#
#   def valid?
#     return true if @a.is_a?(Numeric) && @b.is_a?(Numeric)
#     errors.add :base, :not_a_numeric, Errorio.by_code(:E1000A)
#   end
# end
#
# calc = Calculate.new(3, '1')
# if (result = calc.sum)
#   puts result
# else
#   puts calc.errors.to_e
# end
#
# => # [
#   {
#     :code=>:E1000A,
#     :key=>:base,
#     :type=>:not_a_numeric,
#     :message=>"Special characters are not recommended for name"
#   }
# ]
#
module Errorio
  class << self
    # Error details with code
    #
    # errors.add :base, :invalid, Errorio.by_code(:E0001, user_id: 129)
    def by_code(*args)
      Details.by_code(*args)
    end
  end

  def self.included(base)
    base.extend ClassMethods
    base.send :prepend, InstanceMethods
  end

  # Class-level methods
  module ClassMethods
    def errorionize(*collection_types)
      raise unless collection_types.is_a?(Array)
      @errorio_collection_types = collection_types.map(&:to_sym)
    end

    def errorio_collection_types
      @errorio_collection_types
    end
  end

  # Methods for targeted objects
  module InstanceMethods
    def initialize(*args)
      errorio_initializer
      super(*args)
    end

    def errorio_initializer
      @errorio_repo = {}
      self.class.errorio_collection_types.each do |e|
        init_errors_variable(e)
        if send(e).nil?
          # Initialize
          init_errors(e)
        else
          # Already initialized for instance, import objects to errorio
          @errorio_repo[e] = send(e)
        end

        # Extend existing message handler
        @errorio_repo[e].class.send :include, ErrorObjectsMethods unless @errorio_repo[e].class.respond_to?(:to_e)
      end
    end

    # Add accessor if collection wasn't initialized
    def init_errors_variable(e)
      self.class.attr_accessor e unless respond_to?(e)
    end

    # Init errors class for errorio repo
    def init_errors(e)
      errors = Errors.new(self)
      @errorio_repo[e] = errors
      instance_variable_set("@#{e}", errors)
    end

    def errorio
      @errorio_repo
    end
  end

  # Methods for Error object
  module ErrorObjectsMethods
    def to_e
      result = []

      @errors.each do |err|
        err_obj = err.options.merge(key: err.attribute, type: err.type, message: err.message)
        result << err_obj
      end
      result
    end

    private

    def err_to_object(err)
      err.is_a?(Hash) ? err : { message: err.to_s }
    end
  end
end
