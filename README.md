# Errorio

Extend your models and classes with errors, warnings and other notices

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'errorio'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install errorio

## Usage

Extend ordinary AR model with special collection of +warnings+ and +notices+

```ruby
class Task < ApplicationRecord
  include Errorio
  errorionize :errors, :warnings, :notices # :errors is initialized by ActiveRecord, so it is redundant in this case

  validates :name, presence: { code: :E0230 }
  validate :special_characters_validation

  private

  def special_characters_validation
    return if name =~ /^[a-z0-9]*$/i
    exceptions = name.gsub(/[^a-z0-9]/i).map{ |a| "'#{a}'" }.join(','),
    warnings.add(:name, :special_characters, code: :E0231,
                                             chars: exceptions,
                                             message: 'Special characters are not recommended for name')
  end
end
```

```ruby
result = Task.create
result.errors.to_e
```

returns

```
[
  {
    :code=>:E0230,
    :key=>:name,
    :type=>:blank,
    :message=>"Task Name can't be blank"
  }
]
```

```ruby
result = Task.create name: 'Do * now!'
result.errors.to_e # => []
```

```ruby
result.warnings.to_e
```

returns

```
[
  {
    :code=>:E0231,
    :key=>:name,
    :type=>:special_characters,
    :message=>"Special characters ('*', '!') are not recommended for name"
  }
]
```

Message for code `E0231` should be described in en.yml file

```yaml
errorio:
  messages:
    E0231: "Special characters (%{chars}) are not recommended for name"
```

Implement errors and warnings to service class

```ruby
class Calculate
  include Errorio
  errorionize :errors, :warnings

  def initialize(a, b)
    @a = a
    @b = b
  end

  def sum
    return unless valid?
    a + b
  end

  def valid?
    return true if @a.is_a?(Numeric) && @b.is_a?(Numeric)
    errors.add :base, :not_a_numeric, Errorio.by_code(:E1000A)
  end
end

calc = Calculate.new(3, '1')
if (result = calc.sum)
  puts result
else
  puts calc.errors.to_e
end
```

returns

```
[
  {
    :code=>:E1000A,
    :key=>:base,
    :type=>:not_a_numeric,
    :message=>"Special characters are not recommended for name"
  }
]
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/p9436/errorio.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
