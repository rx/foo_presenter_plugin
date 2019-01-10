require 'voom/presenters/dsl/components/event_base'

module Voom
  module Presenters
    module Plugins
      module Foo
        class Component < DSL::Components::EventBase
          attr_reader :random_fact
          def initialize(random_fact, **attribs_, &block)
            @random_fact = random_fact
            super(type: :foo, **attribs_, &block)
            expand!
          end

        end
      end
    end
  end
end
