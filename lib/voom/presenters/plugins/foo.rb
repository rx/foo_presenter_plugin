require_relative 'foo/component'
require_relative 'foo/action'
module Voom
  module Presenters
    module Plugins
      module Foo
        module DSLComponents
          def foo(random_fact, **attributes, &block)
            self << Foo::Component.new(random_fact, parent: self, **attributes, &block)
          end
        end
        module DSLHelpers
          def random_fact
            "http://en.wikipedia.org/wiki/Special:Randompage"
          end
        end
        module DSLEventActions
          def bar(text, **attributes, &block)
            self << Foo::Action.new(text: text, parent: self, **attributes, &block)
          end
        end
        module WebClientComponents
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
        module WebClientActions
          def action_data_bar(action, _parent_id, *)
            # Type, URL, Options, Params (passed into javascript event/action classes)
            [action.type, action.url, action.options.to_h, action.attributes.to_h]
          end
        end
      end
    end
  end
end
