# frozen_string_literal: true

require_relative "stomp/version"
require 'active_support/concern'

module Stomp
  class Error < StandardError; end
  # Your code goes here...
  module Model
    extend ActiveSupport::Concern

    STOMP_ATTRIBUTES = [:current_step, :completed_steps, :completed, :steps_data, :serialized_steps_data]
    attr_accessor *STOMP_ATTRIBUTES

    included do
      class_attribute :steps, :steps_attributes, :steps_data
    end

    class_methods do
      def define_steps(steps)
        self.steps_attributes = steps.values.flatten + STOMP_ATTRIBUTES
        self.steps = steps.keys

        define_method :serialized_steps_data do
          attributes
            .select { |k, _| steps_attributes.include?(k.to_sym) }
            .merge(current_step: current_step, completed_steps: completed_steps)
            .to_json
        end
      end

      def define_step_validations(step_validations)
        step_validations.each do |step, validations|
          validates_with validations, if: ->(record) { record.current_step == step }
        end
      end
    end

    def initialize(*args)
      if args.first&.fetch(:serialized_steps_data, nil)
        JSON.parse(args.first[:serialized_steps_data]).tap do |data|
          self.steps_data = data
          self.current_step = data["current_step"]
          self.completed_steps = data["completed_steps"]&.map(&:to_sym) || []
        end
      end
      
      self.current_step ||= steps.first
      self.completed_steps ||= []

      super
      update_attributes_from_step_data
    end

    def step!(step)
      return next_step! if step.to_sym == :next
      return previous_step! if step.to_sym == :previous

      self.current_step = step
    end

    def next_step!
      return false unless valid?

      if current_step == steps.last
        self.completed = true
        return false
      end

      self.completed_steps << current_step if !completed_steps.include?(current_step)
      index = steps.index(current_step)
      self.current_step = steps[index + 1]
    end

    def previous_step! 
      index = steps.index(current_step)

      if index > 0
        self.completed_steps.delete(steps[index - 1])
        self.current_step = steps[index - 1]
      end
    end

    def current_step_is?(step)
      current_step == step
    end

    def current_step=(step)
      @current_step = step&.to_sym
    end

    def completed?
      completed
    end

    def all_steps_valid?
      stored_step = current_step

      steps.each do |step|
        self.current_step = step
        return false unless valid?
      end

      self.current_step = stored_step
      true
    end

    private

    def update_attributes_from_step_data
      return if steps_data.nil?

      steps_data.each { |k, v| send("#{k}=", v) if send(k).nil? }
    end
  end
end
