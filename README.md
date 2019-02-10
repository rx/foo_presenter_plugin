# Presenter Plugins

Presenter plugins allows extension and modification of the DSL and WebClient.
It is powerfully designed for adding additional components to the system, or to change the behavior/look feel/capabilities of existing components.

## Global Plugins

Presenters have global plugins that are configured in the system. They are declared as a setting like so:
  
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

### Components
If you want to add additional components to the presenters DSL, provide a `DSLComponents` module under the plugin module:

     module DSLComponents
       def foo(random_fact, **attributes, &block)
         self << Foo::Component.new(random_fact, parent: self, **attributes, &block)
       end
     end

The above example will extend the dsl by adding the foo method that will add the Foo component to the 
presenter object model tree.

A presenter component derives from `DSL::Components::Base` or if it needs to handle events  `DSL::Components::EventBase`

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
      
### Helpers

To add helpers to the POM define the module `DSLHelpers`
    
    module DSLHelpers
      def random_fact
        "http://en.wikipedia.org/wiki/Special:Randompage"
      end
    end

### Event Actions
A plugin can extend the set of event actions that are available. 
When an event fires in the client, like mouse click, a set of actions are executed. A plugin can provide custom
actions. This examnple adds a bar action that can be bound to an event.

    module DSLEventActions
      def bar(text, **attributes, &block)
        self << Foo::Action.new(text: text, parent: self, **attributes, &block)
      end
    end
    
Example action class:

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

    
## Adding a WebClient implementation

A plugin that extends the DSL will give you a new custom POM (Presenter Object Model), but that alone won't get you very far.
The POM describes the user interface, a client must implement each of the components.
For the WebClient this means adding a template with HTML, CSS and Javascript. 

### Component Templates

To render your component you need to add the following to your plugin:
  
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
    
From you ERB you can call any of the other built in WebClient erb's. You can even replace built in component templates.
The render object supports all the template types supported by Tilt/Sinatra (http://sinatrarb.com/intro.html)

Example template:

    <iframe id="random_fact" src="<%= comp.random_fact %>" height=512 <%= erb :"components/event", :locals => {comp: comp, events: comp.events, parent_id: comp.id} %>></iframe>


### Event Action Data

An action from the Presenter Object Model (POM) is sent to a ruby method during template expansion. 
You are able to then setup any data that you want passed to your action javascript method.
It expects you will return an array with a type that matches your event action presenter type. The rest is up to you.


    module WebClientActions
      def action_data_bar(action, _parent_id, *)
        # Type, URL, Options, Params (passed into javascript event/action classes)
        [action.type, action.url, action.options.to_h, action.attributes.to_h]
      end
    end
    
Example Javascript method (typically rendered by a template triggered by the render_foo method above):

    <script>
      function bar(_options, params, _event) {
        // Reload iFrame: https://stackoverflow.com/questions/86428/what-s-the-best-way-to-reload-refresh-an-iframe
        document.getElementById('random_fact').src += '';
        return {action: 'bar', content: {data: params.text}, statusCode: 200};
      }
    </script>

Event action WebClient methods must return a Javascript Object with the properties `action`, `content` and `statusCode`.


## WebClient Javascript Interface

When developing a plugin for the WebClient you may want to have your data submitted as part of another component container.
The most familiar example is a Form.  This requires that you bind your component to the DOM with a few methods.
Not all plugins need to do this.
It is only needed in the case of those components that add their data to an http post.

The following components are Containers that will collect data from nested DOM elements using this lifecycle protocol.
cards.js
content.js
dialogs.js
file-inputs.js
forms.js
grid.js
steppers.js

Lifecycle Protocol:

We call it it a protocol, because it defines a small number of DOM relationships to participate as an integrated component.
Many frameworks require a common base class, this approach is very light by design.

Container data in the WebClient is collected and submitted using the following sequence:

In your element markup include the `vInput` class on an DOM element.
Define the vComponent attribute as an object that implements the following methods:


    // Called whenever a component is about to be submitted.
    // form may be null if the validation is occuring from a container that is not a form.
    // returns true on success
    // returns on failure return an error object that can be processed by VErrors:
    //    { email: ["email must be filled", "email must be from your domain"] }
    //    { page: ["must be filled"] }
    validate(form, params)

    // adds the key value pairs to be submitted/posted
    // Called after validate
    prepareSubmit(params)

    // Clears the component
    clear()

You can see the container calling code here:
https://github.com/rx/presenters/blob/master/views/mdc/assets/js/components/base-container.js

If the component responds to events then you need to bind the event to the correct element

    // idempotent event handling initialization
    initEventListener(eventName, eventHandler)

TODO: Provide sample POJS implementation
