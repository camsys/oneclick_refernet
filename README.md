# OneclickRefernet
oneclick_refernet is a Ruby Engine that provides interaction with the ReferNET 211 API.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'oneclick_refernet', github: 'camsys/oneclick_refernet'
```

And then execute:
```bash
$ bundle install
```

## Sample Usage
Open a rails console in your project and then execute:
```
include OneclickRefernet::RefernetServices
rs = RefernetService.new('<YOUR REFERNET API KEY>')
response = rs.search_keyword('hospital')
```

## Contributing
To contribute to oneclick_refernet, create a pull request for review.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

