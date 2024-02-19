module Stomp
  module Model
    module Initialization
      def initialize(*args)
        deserialize_and_set_data(args.first&.fetch(:serialized_steps_data, nil))
        super
        update_attributes_from_step_data
        set_default_values
      end

      private

      def set_default_values
        self.current_step ||= steps.first
        self.completed_steps ||= []
      end
    end
  end
end