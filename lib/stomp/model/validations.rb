module Stomp
  module Model
    module Validations
      def all_steps_valid?(options = {})
        stored_step = options[:after] || current_step

        steps.each do |step|
          self.current_step = step
          return false unless valid?
        end

        self.current_step = stored_step
        true
      end

      def should_validate?
        return true if create_attempt
        return true if current_step == previous_step

        public_send("#{current_step}_attributes").any? { |attribute| public_send(attribute).present? }
      end
    end
  end
end