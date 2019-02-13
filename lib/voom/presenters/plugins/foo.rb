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
          # The string returned from this method will be added to the HTML header section of the page layout
          # It will be called once for the page.
          # The pom is passed along with the sinatra render method.
          def render_header_foo(_pom, render:)
            view_dir = File.join(__dir__, 'foo')
            render.call :erb, :foo_header, views: view_dir
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
