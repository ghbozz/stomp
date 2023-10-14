# Stomp

Stomp is a Ruby gem designed to simplify and streamline the process of creating multi-step forms and workflows in Rails applications. It offers a clean and intuitive API for defining steps, handling validations, and managing state throughout the flow.


## Installation

```ruby
gem 'stomp', git: 'https://github.com/ghbozz/stomp'
```

then run

```bash
$ bundle install
```

## Model

### Including Stomp::Model
To start using the Stomp gem functionalities in your ActiveRecord model, include the `Stomp::Model` module:
```ruby
class Post < ApplicationRecord
  include Stomp::Model

  stomp! validate: :each_step
  # ... rest of the code
end
```
This includes a set of methods and functionalities specific to multi-step form management into your Post model.

### Model Configuration with `stomp!`

The `stomp! validate: :each_step` line in your model configures the validation behavior of the Stomp gem. 

- `validate: :each_step`: With this setting, validations for the current step are triggered each time the user navigates between steps. If the validations fail, the user cannot proceed to the next step until the errors are resolved.

- `validate: :once`: In contrast, using `validate: :once` will only run validations a single time at the end when the user attempts to commit the record. This allows the user to navigate through the form without being halted by validations, but it also means that all validations must pass at the end before the record can be saved.

The choice between `:each_step` and `:once` depends on the user experience you wish to provide. Using `:each_step` ensures data integrity at each stage but can make the form feel more restrictive. On the other hand, `:once` allows for greater freedom during form navigation but consolidates the validation process at the end.

### Defining Steps
Use the define_steps method to specify the steps involved and the attributes required for each step.
```ruby
define_steps step_1: [:title, :url, :author], 
             step_2: [:description], 
             step_3: [:content]
```
Here, we define three steps (step_1, step_2, step_3) and associate them with their respective attributes.

### Step Validations
The define_step_validations method allows you to set up validations specific to each step.
```ruby
define_step_validations step_1: { 
  title: { presence: true, length: { minimum: 5 } }, 
  author: { presence: true }
}
```
For more advanced validations, you can even specify a separate Validator class:
```ruby
define_step_validations step_2: PostDescriptionValidator
```
This will use the PostDescriptionValidator class to validate the description attribute during step_2

## Controller

### Including Stomp::Controller
Firstly, include the `Stomp::Controller` module in your controller class:

```ruby
class PostsController < ApplicationController
  include Stomp::Controller
  # ... rest of the code
end
```

### Data Serialization Between Actions

One of the key aspects of the Stomp gem is its ability to serialize data between the `new` and `create` actions in the controller. This is particularly useful in the context of multi-step forms where you might not want to persist data to the database until all steps are valid and the user is ready to commit the record.

### Helper Methods for Data Serialization

The Stomp gem provides some built-in helper methods to make this process seamless:

#### `build_record_for` Method
This method is used in the `new` action to initialize a new record and prepare it for the multi-step form process. It sets up the record based on the defined steps and their associated attributes. This allows the `new` action to pass along the required parameters to the view, ensuring that only relevant fields are displayed according to the step the user is currently on.
```ruby
def new
  @post = build_record_for(Post)
end
```

#### `next_step_path_for` Method
In the `create` action, the `next_step_path_for` method comes into play if the conditions for committing the record aren't met—i.e., either the "create" commit action hasn't been triggered or not all steps are valid. This method determines the path for redirecting the user to the next step in the multi-step form. It takes into account the current state of the record and directs the flow accordingly.
```ruby
def create
  @post = Post.new(post_params)

  if params[:commit] == "create" && @post.all_steps_valid?
    @post.save
    redirect_to post_path @post
  else
    @post.step!(params[:commit])
    redirect_to next_step_path_for(@post, path: :new_post_path)
  end
end
```

Both of these methods are essential for the functionality of the gem, working hand-in-hand to serialize the form data and guide the user through each step until the record can be committed.

### Handling Strong Parameters

In order to effectively work with the Stomp gem and its data serialization capabilities, it's essential to add the `serialized_steps_data` attribute to your strong parameters definition. This attribute is automatically utilized by the gem to hold serialized form data across multiple steps in your form flow. By including `serialized_steps_data` in your strong parameters, you ensure that this serialized data is permitted for mass-assignment, facilitating a smooth multi-step form experience.

```ruby
private

def post_params
  params.require(:post).permit(:title, :url, :author, :description, :content, :serialized_steps_data)
end
```

### View

### View Configuration for Serialized Data

In the view layer, specifically within your form, you will encounter the usage of an input field for `serialized_steps_data`. This is defined as a text input type:
```erb
<%= f.input :serialized_steps_data, as: :text %>
```

### Conditionally Rendering Input Fields Based on Steps

In the view, you may notice conditional blocks of code that render specific form inputs based on the current step. These blocks utilize the `current_step_is?` method provided by the Stomp gem to determine which step the user is currently on. This enables the form to display only the relevant input fields for that particular step.

For instance, if the user is on `step_1`, only the input fields for `:title`, `:author`, and `:url` will be displayed. Similarly, the `:description` field will be displayed during `step_2`, and the `:content` field will be displayed during `step_3`.
```erb
<% if f.object.current_step_is? :step_1 %>
  <%= f.input :title %>
  <%= f.input :author %>
  <%= f.input :url %>
<% end %>

<% if f.object.current_step_is? :step_2 %>
  <%= f.input :description %>
<% end %>

<% if f.object.current_step_is? :step_3 %>
  <%= f.input :content %>
<% end %>
```

### Navigating Between Steps with Form Buttons

In the view, a series of buttons facilitate navigation between the various steps of the form. The value attribute on each button is crucial as it determines the action that will be triggered in the controller when the button is pressed.

```erb
<% if f.object.has_previous_step? %>
  <%= f.submit "previous", value: "previous" %>
<% end %>

<%= f.submit "1", value: "step_1" %>
<%= f.submit "2", value: "step_2" %>
<%= f.submit "3", value: "step_3" %>

<% if f.object.has_next_step? %>
  <%= f.submit "next", value: "next" %>
<% end %>

<%= f.submit "create", value: "create" %>
```

- **Previous and Next Buttons**: The "previous" and "next" buttons appear if there are previous or next steps, thanks to the `has_previous_step?` and `has_next_step?` methods. These buttons have values of "previous" and "next," which the controller uses to navigate between steps.

- **Step-Specific Buttons**: Buttons labeled "1," "2," and "3" carry values of "step_1," "step_2," and "step_3," respectively. When pressed, these values instruct the controller to navigate directly to the respective step in the form. This feature is especially useful when the Stomp gem is configured with `stomp! validate: :once`, allowing for navigation between steps without validating each steps.

- **Create Button**: The "create" button has a value of "create." When pressed, this value signals to the controller to validate all steps and, if valid, to commit the record to the database


## Development

-

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ghbozz/stomp.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
