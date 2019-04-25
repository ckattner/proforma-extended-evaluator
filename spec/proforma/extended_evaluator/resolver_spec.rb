# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Proforma::ExtendedEvaluator::Resolver do
  subject { described_class.new }

  context 'when input is a hash' do
    let(:input) { { 'id' => 1, demographics: { 'first' => 'Matt' } } }

    specify '#resolve gets correct value' do
      expect(subject.resolve(:id, input)).to  eq(input['id'])
      expect(subject.resolve('id', input)).to eq(input['id'])

      expect(subject.resolve('demographics.first', input)).to eq(input.dig(:demographics, 'first'))
    end
  end

  context 'when input is an OpenStruct' do
    let(:input) do
      OpenStruct.new(
        id: 1,
        demographics: OpenStruct.new(
          first: 'Matt'
        )
      )
    end

    specify '#resolve gets correct value' do
      expect(subject.resolve(:id, input)).to  eq(input.id)
      expect(subject.resolve('id', input)).to eq(input.id)

      expect(subject.resolve('demographics.first', input)).to eq(input.demographics.first)
    end
  end
end
