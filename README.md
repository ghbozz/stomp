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

## Usage

### Including Stomp::Model
To start using the Stomp gem functionalities in your ActiveRecord model, include the `Stomp::Model` module:
```ruby
class Post < ApplicationRecord
  include Stomp::Model
  # ... rest of the code
end
```
This includes a set of methods and functionalities specific to multi-step form management into your Post model.

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


### Defining Steps
Use the define_steps method to specify the steps involved and the attributes required for each step.

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/stomp.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
