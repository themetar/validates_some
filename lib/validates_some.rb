# frozen_string_literal: true

require_relative "validates_some/version"
require "active_model"

# Included in `ActiveModel::Validations::ClassMethods` so that `validates_some` becomes avalilable
# in any class that descends from ActiveModel or includes `ActiveModel::API`.
module ValidatesSome

  # Adds "some/any" logic to previous validations regarding the referenced attributes.
  # At least one of them needs to pass its validations for the whole attribute group to pass.
  #
  # Resets any invalid attributes to the values passed in `resets:`.
  #
  # Example with ActiveRecord (Rails):
  #
  #   class Person < ActiveRecord::Base
  #     validates :name, presence: true
  #     validates :surname, presence: true
  #     validates_some :name, :surname
  #   end
  #
  #   # Person.new(surname: "Smith").valid? # => true
  #
  # `resets:` can take the following values:
  # - A single value - All invalid arguments are set to that value (default is `nil`).
  #     validates_some :name, :surname, resets: "n/a"
  # - An `Array` - Invalid attributes are set to the value attached to it by order of listing.
  #     validates_some :name, :surname, resets: ["n/a", "none"]
  # - A `Hash` - Invalid attributes are set to their associated value in the hash.
  #     validates_some :name, :surname, resets: { name: "n/a", surname: "none" }
  # - A `Proc` - Invalid attributes are set to the value returned by the proc when called for that argument.
  #     validates_some :name, :surname, resets: proc { |attr| "* No #{attr} *" }
  def validates_some(*attributes, resets: nil)
    reset_values = case resets
                   when Hash, Proc then resets
                   when Array then attributes.zip(resets).to_h
                   else Hash.new(resets)
                   end

    validate do |record|
      faulty = attributes.reject { |attribute| record.errors[attribute].empty? }

      next if faulty.empty? || faulty.length == attributes.length

      faulty.each do |faulty_attribute|
        record.errors.delete(faulty_attribute)
        record.send("#{faulty_attribute}=", reset_values[faulty_attribute])
      end
    end
  end

end

module ActiveModel # :nodoc: all
  module Validations
    module ClassMethods

      include ValidatesSome

    end
  end
end
