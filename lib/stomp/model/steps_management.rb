module Stomp
  module Model
    module StepsManagement
      def step!(step)
        set_create_attempt!(step)
        set_direction!(step) if [:next, :previous].include?(step.to_sym)
        
        return next_step! if step.to_sym == :next
        return previous_step! if step.to_sym == :previous
        return false unless steps.include?(step.to_sym)
        
        update_completed_steps
        
        if self.stomp_validation == :each_step
          return all_steps_valid?(after: step) unless completed_steps.include?(step.to_sym)
        end
        
        set_direction!(step) unless [:next, :previous].include?(step.to_sym)
        self.current_step = step
      end

      def set_direction!(step)
        return self.direction = :forward if step.to_sym == :next
        return self.direction = :backward if step.to_sym == :previous
        
        if step_index_for(step.to_sym) > current_step_index
          self.direction = :forward
        else
          self.direction = :backward
        end
      end
  
      def next_step!
        update_completed_steps
      
        if self.stomp_validation == :each_step
          self.previous_step = current_step
          return false unless valid?
        end
      
        if current_step == steps.last
          self.completed = true
          return false
        end
      
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

      def has_previous_step?
        steps.index(current_step) > 0
      end
  
      def has_next_step?
        steps.index(current_step) < steps.length - 1
      end
  
      def current_step_is?(step)
        current_step == step
      end
  
      def completed?
        completed
      end
  
      def create_attempt?
        create_attempt
      end
  
      def first_step?
        current_step == steps.first
      end
  
      def last_step?
        current_step == steps.last
      end

      def current_step_index
        steps.index(current_step)
      end

      def step_index_for(step)
        steps.index(step)
      end

      private

      def set_create_attempt!(step)
        step.to_sym == :create ? self.create_attempt = true : self.create_attempt = false
      end

      def update_completed_steps
        return unless self.stomp_validation == :each_step
  
        valid? ? self.completed_steps |= [current_step] : self.completed_steps.delete(current_step)
      end
    end
  end
end