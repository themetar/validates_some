# validates_some

Attribute grouping for `ActiveModel` validations.

`validates_some` is an extenstion to the ActiveModel validation API. The `validates_some` method filters declared validations for the referenced attributes. ActiveModel validations are by default all or nothing: the object is `valid?` if every and all attributes pass their validations. `validates_some` expects that just _some_ (at least one) of the listed attributes are valid for the whole group of attributes to be considered validated. If one of the attributes passes its validations without errors, the rest of the attributes' errors are suppressed and the attributes are reset to default values.

## Usage

Example when using with `ActiveRecord` in Rails:

The user record should have a name, surname, and a nickname; but it's enough to have at least one of them. After you've set up the presence validations, call `validates_some` with the attributes names to specify that they can cover for one another, and that only one of them needs be valid.

```ruby
class User < ActiveRecord::Base
  validates :name, presence: true
  validates :nickname, presence: true
  validates :surname, presence: true
  validates_some :name, :nickname, :surname

  # ...
end
```

You can add additional validations after `validates_some`, which are again independent of any other validations. (You can, of course, call `validates_some` again to set up another dependency.)

Here the email uniqueness check isn't suppressed when the phone number is valid. 

```ruby
  validates :phone_number, format: /\d{8}/
  validates :email, format: /\w+@\w+\.\w{3}/
  validates_some :phone_number, :email, resets: ["XXYYYZZZ", ""]
  validates :email, uniqueness: true, allow_blank: true # check uniqueness for non-blank emails
```

Invalid attributes are reset to the values passed in `resets:`.

`resets:` can take the following values:
  - A single value - All invalid arguments are set to that value (default is `nil`).
    ```ruby
      validates_some :name, :surname, resets: "n/a"
    ```
  - An `Array` - Invalid attributes are set to the value attached to it by order of listing.
    ```ruby
      validates_some :name, :surname, resets: ["n/a", "none"]
    ```
  - A `Hash` - Invalid attributes are set to their associated value in the hash.
    ```ruby
      validates_some :name, :surname, resets: { name: "n/a", surname: "none" }
    ```
  - A `Proc` - Invalid attributes are set to the value returned by the proc when called for that argument.
    ```ruby
      validates_some :name, :surname, resets: proc { |attr| "* No #{attr} *" }
    ```

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add validates_some
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install validates_some
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/themetar/validates_some.
