module Stomp
  module Model
    module ClassMethods
      def define_steps(steps)
        self.steps_attributes = steps.values.flatten + STOMP_ATTRIBUTES
        self.steps = steps.keys

        define_method :serialized_steps_data do
          attributes
            .select { |k, _| steps_attributes.include?(k.to_sym) }
            .merge(current_step: current_step, previous_step: previous_step, create_attempt: create_attempt, completed_steps: completed_steps)
            .to_json
        end

        steps.each do |step, attributes|
          define_method "#{step}_attributes" do
            attributes
          end

          define_method "#{step}?" do
            current_step == step
          end
        end
      end

      def define_step_validations(step_validations)
        step_validations.each do |step, validations|
          if validations.is_a? Hash
            validations.each do |attribute, validation|
              validates attribute, **validation, if: ->(record) { record.current_step == step }
            end
          else
            validates_with validations, if: ->(record) { record.current_step == step }
          end
        end
      end

      def stomp!(options)
        self.stomp_validation = options[:validate]
      end
    end
  end
end
