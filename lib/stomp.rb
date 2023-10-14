# frozen_string_literal: true

require_relative "stomp/version"
require_relative "stomp/initialization"
require_relative "stomp/steps_management"
require_relative "stomp/validations"
require_relative "stomp/serialization"
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

  module Controller
    def build_record_for(klass)
      record = klass.new(serialized_steps_data: params[:serialized_steps_data])
      record.valid? if record.should_validate?
      record
    end

    def next_step_path_for(record, options = {})
      public_send("#{options[:path]}", serialized_steps_data: record.serialized_steps_data)
    end
  end
end
