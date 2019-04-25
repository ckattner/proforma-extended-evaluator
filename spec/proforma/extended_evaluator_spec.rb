# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Proforma::ExtendedEvaluator do
  describe '#initialize' do
    it 'should raise ArgumentError if formatter is null' do
      expect { described_class.new(formatter: nil) }.to raise_error(ArgumentError)
    end

    it 'should raise ArgumentError if resolver is null' do
      expect { described_class.new(resolver: nil) }.to raise_error(ArgumentError)
    end

    it 'should assign formatter and resolver' do
      formatter = Proforma::ExtendedEvaluator::Formatter.new
      resolver = Proforma::ExtendedEvaluator::Resolver.new

      instance = described_class.new(formatter: formatter, resolver: resolver)

      expect(instance.formatter).to equal(formatter)
      expect(instance.resolver).to equal(resolver)
    end
  end

  specify '#value is delegated to resolver#resolve' do
    resolver    = Proforma::ExtendedEvaluator::Resolver.new
    object      = { id: 1 }
    expression  = 'id'

    instance = described_class.new(resolver: resolver)

    expect(resolver).to receive(:resolve).with(expression, object)

    instance.value(object, expression)
  end

  specify '#text will use blank object if an array is passed in' do
    object      = [{ id: 1 }]
    expression  = '{id}'

    instance = described_class.new

    actual_text = instance.text(object, expression)

    expect(actual_text).to eq('')
  end

  specify '#text will use object if an object is passed in' do
    object      = { id: 1 }
    expression  = '{id}'

    instance = described_class.new

    actual_text = instance.text(object, expression)

    expect(actual_text).to eq('1')
  end

  specify 'Proforma Rendering Example' do
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

    actual_documents = Proforma.render(data, template, evaluator: Proforma::ExtendedEvaluator.new)

    expected_contents = <<~CONTENTS
      DETAILS FOR: BOND, JAMES (1)
      ID #: 1
      First Name: James
      Last Name: Bond
      Social Security #: XXXXXXX6789
      Birthdate: 05/14/1960
      Smoker: No
      Balance: $123.45 USD
    CONTENTS

    expected_documents = [
      Proforma::Document.new(
        contents: expected_contents,
        extension: '.txt',
        title: ''
      )
    ]

    expect(actual_documents).to eq(expected_documents)
  end
end
