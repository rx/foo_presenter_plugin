# Presenter Plugins

Presenter plugins allows extension and modification of the DSL and WebClient.
It is designed for adding additional components to the system, or to change the behavior/look feel/capabilities of existing components.

## Global Plugins

Presenters have global plugins that are configured in the system. They are defined as a setting like the following:
  
    Voom::Presenters::Settings.configure do |config|
      config.presenters.plugins.push(:foo)
    end 

A global plugin is available to all presenters.

## Local Plugins

A presenters can define that it uses a plugin like so: 

    Voom::Presenters.define(:index, namespace: :plugins) do
      plugin :foo
    end

A local plugin is available only to the presenter that it is defined in.


## Creating Plugins

The skeleton for a plugin starts with an empty module in a file stored in `voom/presenters/plugins` somewhere in ruby's load path 
(typically in a gemfile or in the lib directory of an framework app, like Rails):

    module Voom
      module Presenters
        module Plugins
          module Foo
          end
        end
      end
    end

## Extending the presenter DSL and POM

If you want to add additional components to the presenters DSL, provide a DSLMethods module under the plugin module:

     module Voom
       module Presenters
         module Plugins      
           module DSLMethods
              def foo(**attributes, &block)
                self << Foo::Component.new(parent: self, **attributes, &block)
              end
           end
         end
       end
     end

The above example will extend the dsl by adding the foo method that will add the Foo component to the 
presenter object model tree.

A presenter component derives from `DSL::Components::Base`

      require 'voom/presenters/dsl/components/base'
      
      module Voom
        module Presenters
          module Plugins
            module Foo
              class Component < DSL::Components::Base
                def initialize(**attribs_, &block)
                  super(type: :foo, **attribs_, &block)
                end      
              end
            end
          end
        end
      end


## Adding a WebClient implementation

A plugin that extends the DSL will give you a new custom POM (Presenter Object Model), but that alone won't get you very far.
The POM describes the user interface, a client must implement each of the components.
For the WebClient this means adding a template and often CSS and Javascript. 

### Adding a render method
To render your component you need to add the following to your plugin:
  
    module Voom
      module Presenters
        module Plugins      
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
