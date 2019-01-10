require 'voom/presenters/dsl/components/actions/base'


module Voom
  module Presenters
    module Plugins
      module Foo
          class Action < DSL::Components::Actions::Base
            def initialize(**attribs_, &block)
              super(type: :bar, **attribs_, &block)
            end
        end
      end
    end
  end
end
