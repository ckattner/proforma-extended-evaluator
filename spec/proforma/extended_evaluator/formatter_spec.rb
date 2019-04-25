# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Proforma::ExtendedEvaluator::Formatter do
  let(:usa_formatter) { described_class.new }

  let(:france_formatter) do
    described_class.new(
      currency_code: '€',
      currency_round: 2,
      currency_symbol: '',
      decimal_separator: ',',
      thousands_separator: ' '
    )
  end

  describe '#left_mask_formatter' do
    specify 'returns empty string if value is null' do
      expect(subject.left_mask_formatter(nil, '')).to eq('')
    end

    specify 'returns empty string if value is empty string' do
      expect(subject.left_mask_formatter('', '')).to eq('')
    end

    context 'when arg is blank' do
      let(:arg) { '' }

      specify 'returns value if length is less than or equal to mask length' do
        expect(subject.left_mask_formatter('a',       arg)).to eq('a')
        expect(subject.left_mask_formatter('ab',      arg)).to eq('ab')
        expect(subject.left_mask_formatter('abc',     arg)).to eq('abc')
        expect(subject.left_mask_formatter('abcd',    arg)).to eq('abcd')
        expect(subject.left_mask_formatter('abcde',   arg)).to eq('Xbcde')
        expect(subject.left_mask_formatter('abcdef',  arg)).to eq('XXcdef')
      end
    end

    context 'when arg is populated' do
      let(:arg) { '2' }

      specify 'returns value if length is less than or equal to mask length (arg)' do
        expect(subject.left_mask_formatter('a',       arg)).to eq('a')
        expect(subject.left_mask_formatter('ab',      arg)).to eq('ab')
        expect(subject.left_mask_formatter('abc',     arg)).to eq('Xbc')
        expect(subject.left_mask_formatter('abcd',    arg)).to eq('XXcd')
        expect(subject.left_mask_formatter('abcde',   arg)).to eq('XXXde')
        expect(subject.left_mask_formatter('abcdef',  arg)).to eq('XXXXef')
      end

      specify 'raises ArgumentError for negative arg' do
        expect { subject.left_mask_formatter(nil, -1) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#date_formatter' do
    subject do
      described_class.new(
        date_format: '%m/%d/%Y'
      )
    end

    let(:arg) { '' }

    specify 'returns empty string if value is null' do
      expect(subject.date_formatter(nil, '')).to eq('')
    end

    specify 'returns empty string if value is empty string' do
      expect(subject.date_formatter('', '')).to eq('')
    end

    specify 'returns formatted date' do
      expect(subject.date_formatter('2018-01-02', arg)).to eq('01/02/2018')
    end
  end

  describe '#number_formatter' do
    context 'localized for USA (default)' do
      subject { usa_formatter }

      let(:arg) { '3' }

      specify 'returns formatted number' do
        expect(subject.number_formatter('12345.67899', arg)).to eq('12,345.679')
        expect(subject.number_formatter('12345', arg)).to eq('12,345.000')
      end
    end

    context 'localized for France' do
      subject { france_formatter }

      let(:arg) { '3' }

      specify 'returns formatted number' do
        expect(subject.number_formatter('12345.67899', arg)).to eq('12 345,679')
        expect(subject.number_formatter('12345', arg)).to eq('12 345,000')
      end
    end
  end

  describe '#currency_formatter' do
    let(:arg) { '' }

    context 'localized for USA (default)' do
      subject { usa_formatter }

      specify 'returns empty string if value is null' do
        expect(subject.currency_formatter(nil, arg)).to eq('')
      end

      specify 'returns empty string if value is empty string' do
        expect(subject.currency_formatter('', arg)).to eq('')
      end

      specify 'returns formatted currency' do
        expect(subject.currency_formatter('12345.67', arg)).to eq('$12,345.67 USD')
      end
    end

    context 'localized for France' do
      subject { france_formatter }

      specify 'returns empty string if value is null' do
        expect(subject.currency_formatter(nil, arg)).to eq('')
      end

      specify 'returns empty string if value is empty string' do
        expect(subject.currency_formatter('', arg)).to eq('')
      end

      specify 'returns formatted currency' do
        expect(subject.currency_formatter('12345.67', arg)).to eq('12 345,67 €')
      end
    end
  end

  describe '#boolean_formatter' do
    context 'non-nullable' do
      let(:arg) { '' }

      it 'should format truthy' do
        expect(subject.boolean_formatter(true,    arg)).to eq('Yes')
        expect(subject.boolean_formatter('true',  arg)).to eq('Yes')
        expect(subject.boolean_formatter('True',  arg)).to eq('Yes')
        expect(subject.boolean_formatter('t',     arg)).to eq('Yes')
        expect(subject.boolean_formatter('1',     arg)).to eq('Yes')
        expect(subject.boolean_formatter(1,       arg)).to eq('Yes')
      end

      it 'should format falsy' do
        expect(subject.boolean_formatter(false,   arg)).to eq('No')
        expect(subject.boolean_formatter('false', arg)).to eq('No')
        expect(subject.boolean_formatter('False', arg)).to eq('No')
        expect(subject.boolean_formatter(0,       arg)).to eq('No')
        expect(subject.boolean_formatter('f',     arg)).to eq('No')
      end

      it 'should format nully' do
        expect(subject.boolean_formatter(nil,     arg)).to eq('No')
        expect(subject.boolean_formatter('nil',   arg)).to eq('No')
        expect(subject.boolean_formatter('null',  arg)).to eq('No')
      end
    end

    context 'nullable' do
      let(:arg) { 'nullable' }

      it 'should format nully' do
        expect(subject.boolean_formatter(nil,     arg)).to eq('Unknown')
        expect(subject.boolean_formatter('nil',   arg)).to eq('Unknown')
        expect(subject.boolean_formatter('null',  arg)).to eq('Unknown')
      end
    end
  end
end
