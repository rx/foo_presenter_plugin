require 'voom/presenters/dsl/components/base'

module Voom
  module Presenters
    module Plugins
      module Foo
        class Component < DSL::Components::Base
          attr_reader :random_fact
          def initialize(random_fact, **attribs_, &block)
            @random_fact = random_fact
            super(type: :foo, **attribs_, &block)
          end

        end
      end
    end
  end
end
