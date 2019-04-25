# Proforma Extended Evaluator

[![Gem Version](https://badge.fury.io/rb/proforma-extended-evaluator.svg)](https://badge.fury.io/rb/proforma-extended-evaluator) [![Build Status](https://travis-ci.org/bluemarblepayroll/proforma-extended-evaluator.svg?branch=master)](https://travis-ci.org/bluemarblepayroll/proforma-extended-evaluator) [![Maintainability](https://api.codeclimate.com/v1/badges/79e66b596906f633bc95/maintainability)](https://codeclimate.com/github/bluemarblepayroll/proforma-extended-evaluator/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/79e66b596906f633bc95/test_coverage)](https://codeclimate.com/github/bluemarblepayroll/proforma-extended-evaluator/test_coverage) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

The core [Proforma](https://github.com/bluemarblepayroll/proforma) library intentionally ships with a very weak evaluator.  Custom text templating and value resolution is not part of the core library's domain.  This library fills that void.  The goals of this library are to provide:

1. Nested value resolution using dot-notation: `demographics.contact.first_name`
2. Indifferent object types for value resolution: Hash, OpenStruct, any Object subclass, etc.
3. Rich text templating: `{demo.last}, {demo.first} {demo.middle}`
4. Customizable formatting:
  * `{amount::currency}` -> `$12,345.67 USD`
  * `{dob::date}` -> `2/4/1976`
  * `{user_count::number::0}` -> `12,400,569`
  * `{logins_per_day::number::2}` -> `76,004.45`
  * `{smoker::boolean}` -> `Yes` or `No`
  * `{smoker::boolean::nullable}` -> `Yes` or `No` or `Unknown`
  * `{social_security_number::left_mask}` -> `XXXXXXX1234`

## Installation

To install through Rubygems:

````
gem install install proforma-extended-evaluator
````

You can also add this to your Gemfile:

````
bundle add proforma-extended-evaluator
````

## Examples

### Connecting to Proforma Rendering Pipeline

To use this plugin within [Proforma](https://github.com/bluemarblepayroll/proforma):

1. Install [Proforma](https://github.com/bluemarblepayroll/proforma)
2. Install this library
3. Require both libraries
4. Pass in an instance of Proforma::ExtendedEvaluator into the Proforma#render method

````ruby
require 'proforma'
require 'proforma/extended_evaluator'

data = [
  {
    id: 1,
    person: {
      first: 'James',
      last: 'Bond',
      dob: '1960-05-14',
      smoker: false,
      ssn: '123-45-6789'
    },
    balance: '123.445388'
  }
]

template = {
  children: [
    {
      type: 'Grouping',
      children: [
        {
          type: 'Header',
          value: 'Details For: {person.last}, {person.first} ({id})'
        },
        {
          type: 'Pane',
          columns: [
            {
              lines: [
                { label: 'ID #', value: '{id::number::0}' },
                { label: 'First Name', value: '{person.first}' },
                { label: 'Last Name', value: '{person.last}' },
                { label: 'Social Security #', value: '{person.ssn::left_mask}' }
              ]
            },
            {
              lines: [
                { label: 'Birthdate', value: '{person.dob::date}' },
                { label: 'Smoker', value: '{person.smoker::boolean}' },
                { label: 'Balance', value: '{balance::currency}' }
              ]
            }
          ]
        }
      ]
    }
  ]
}

documents = Proforma.render(data, template, evaluator: Proforma::ExtendedEvaluator.new)
````

The `documents` attribute will now be an array with one object:

```ruby
expected_documents = [
  {
    contents: "DETAILS FOR: BOND, JAMES (1)\nID #: 1\nFirst Name: James\nLast Name:"\
              " Bond\nSocial Security #: XXXXXXX6789\nBirthdate: 05/14/1960\nSmoker:"\
              " No\nBalance: $123.45 USD\n",
    extension: '.txt',
    title: ''
  }
]
```

Notice how all strings are properly formatted as prescribed in the template.

### Advanced Formatting (Customization/Options)

Formatter options are biased towards USA localization.  You can override any of the options of the Formatter class, here are the options and their defaults:

Option           | Default
---------------- | -------
currency_code    | 'USD'
currency_round   | 2
currency_symbol  | '$'
date_format      | '%m/%d/%Y'
mask_char        | 'X'
false_value      | 'No'
null_value       | 'Unknown'
true_value       | 'Yes'

## Contributing

### Development Environment Configuration

Basic steps to take to get this repository compiling:

1. Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/) (check proforma-extended-evaluator.gemspec for versions supported)
2. Install bundler (gem install bundler)
3. Clone the repository (git clone git@github.com:bluemarblepayroll/proforma-extended-evaluator.git)
4. Navigate to the root folder (cd proforma)
5. Install dependencies (bundle)

### Running Tests

To execute the test suite run:

````
bundle exec rspec spec --format documentation
````

Alternatively, you can have Guard watch for changes:

````
bundle exec guard
````

Also, do not forget to run Rubocop:

````
bundle exec rubocop
````

### Publishing

Note: ensure you have proper authorization before trying to publish new versions.

After code changes have successfully gone through the Pull Request review process then the following steps should be followed for publishing new versions:

1. Merge Pull Request into master
2. Update `lib/proforma/extended_evaluator/version.rb` using [semantic versioning](https://semver.org/)
3. Install dependencies: `bundle`
4. Update `CHANGELOG.md` with release notes
5. Commit & push master to remote and ensure CI builds master successfully
6. Build the project locally: `gem build proforma-extended-evaluator`
7. Publish package to RubyGems: `gem push proforma-extended-evaluator-X.gem` where X is the version to push
8. Tag master with new version: `git tag <version>`
9. Push tags remotely: `git push origin --tags`

## License

This project is MIT Licensed.
