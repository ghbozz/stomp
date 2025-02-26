module Stomp
  module Model
    module Serialization

      private

      def deserialize_and_set_data(serialized_data)
        return unless serialized_data

        JSON.parse(serialized_data).tap do |data|
          self.steps_data = data
          self.previous_step = data["previous_step"]
          self.current_step = data["current_step"]
          self.create_attempt = data["create_attempt"]
          self.completed_steps = data["completed_steps"]&.map(&:to_sym) || []
        end
      end

      def update_attributes_from_step_data
        return if steps_data.nil?

        steps_data.each { |k, v| send("#{k}=", v) if send(k).nil? }
      end
    end
  end
end
