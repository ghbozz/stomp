# frozen_string_literal: true

require_relative "stomp/version"
require 'active_support/concern'

module Stomp
  module Model
    extend ActiveSupport::Concern

    include Initialization
    include StepsManagement
    include Validations
    include Serialization

    STOMP_ATTRIBUTES = [:current_step, :previous_step, :completed_steps, :completed, :steps_data, :create_attempt, :serialized_steps_data]
    attr_accessor *STOMP_ATTRIBUTES

    included do
      extend ClassMethods
      class_attribute :steps, :steps_attributes, :steps_data, :stomp_validation

      after_initialize :set_default_values
    end

    def current_step=(step)
      @previous_step = @current_step.presence
      @current_step = step&.to_sym
    end

    def previous_step=(step)
      @previous_step = step&.to_sym
    end
  end
end
