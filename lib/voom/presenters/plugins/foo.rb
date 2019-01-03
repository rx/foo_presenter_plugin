require_relative 'foo/comp'
module Voom
  module Presenters
    module Plugins
      module Foo
        module DSLMethods
          # A component
          def foo(random_fact, **attributes, &block)
            self << Foo::Component.new(random_fact, parent: self, **attributes, &block)
          end
          # A helper
          def random_fact
            "http://en.wikipedia.org/wiki/Special:Randompage"
          end
        end
        module WebClient
          def render_foo(comp,
                         render:,
                         components:,
                         index:)
            view_dir = File.join(__dir__, 'foo')
            render.call :erb, :foo, views: view_dir,
                        locals: {comp: comp,
                                 components: components, index: index}
          end
        end
      end
    end
  end
end
