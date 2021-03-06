module Moose
  module Hook
    class Collection
      def call_hooks_with_entity(entity:, on_error: nil, &block)
        error_to_raise = nil
        begin
          call_around_hook_set(entity) {
            call_hook_set(before_hooks, entity)
            block.call
          }
        rescue => e
          if on_error
            entity.send(on_error, e)
          end
          error_to_raise = e
        end
        begin
          call_hook_set(after_hooks, entity)
        rescue => e
          if on_error && !error_to_raise
            entity.send(on_error, e)
          end
          error_to_raise ||= e
        end

        raise error_to_raise if error_to_raise
      end

      def add_before_hook(block_entity)
        before_hooks << block_entity
      end

      def add_after_hook(block_entity)
        after_hooks << block_entity
      end

      def add_around_hook(block_entity)
        around_hooks << block_entity
      end

      private

      def call_hook_set(hook_set, entity)
        hook_set.each do |hook|
          hook.call_with_entity(entity)
        end
      end

      def call_around_hook_set(entity)
        around_collection.call_with_entity(entity) { yield }
      end

      def before_hooks
        @before_hooks ||= []
      end

      def after_hooks
        @after_hooks ||= []
      end

      def around_hooks
        @around_hooks ||= around_collection
      end

      def around_collection
        @around_collection ||= AroundCollection.new
      end
    end
  end
end
