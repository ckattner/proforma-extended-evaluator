# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Proforma
  class ExtendedEvaluator
    # This library uses Stringento for its string-based formatting.  This class is meant to be
    # plugged into Stringento to provide formatting for data types, such as: strings, dates,
    # currency, numbers, etc.
    class Formatter < Stringento::Formatter
      extend Forwardable

      DEFAULTS = {
        currency_code: 'USD',
        currency_round: 2,
        currency_symbol: '$',
        date_format: '%m/%d/%Y',
        decimal_separator: '.',
        iso_date_format: '%Y-%m-%d',
        mask_char: 'X',
        false_value: 'No',
        null_value: 'Unknown',
        nullish_regex: /\A(nil|null)\z/i.freeze,
        thousands_regex: /[0-9](?=(?:[0-9]{3})+(?![0-9]))/.freeze,
        thousands_separator: ',',
        true_value: 'Yes',
        truthy_regex: /\A(true|t|yes|y|1)\z/i.freeze
      }.freeze

      attr_reader :options

      def_delegators  :options,
                      :currency_code,
                      :currency_round,
                      :currency_symbol,
                      :date_format,
                      :decimal_separator,
                      :iso_date_format,
                      :false_value,
                      :mask_char,
                      :null_value,
                      :nullish_regex,
                      :thousands_regex,
                      :thousands_separator,
                      :truthy_regex,
                      :true_value

      def initialize(opts = {})
        @options = OpenStruct.new(DEFAULTS.merge(opts))
      end

      def left_mask_formatter(value, keep_last)
        keep_last = keep_last.to_s.empty? ? 4 : keep_last.to_s.to_i

        raise ArgumentError, "keep_last cannot be negative (#{keep_last})" if keep_last.negative?

        string_value = value.to_s

        return ''     if null_or_empty?(string_value)
        return value  if string_value.length <= keep_last

        mask(string_value, keep_last)
      end

      def date_formatter(value, _arg)
        return '' if null_or_empty?(value)

        date = Date.strptime(value.to_s, iso_date_format)

        date.strftime(date_format)
      end

      def currency_formatter(value, _arg)
        return '' if null_or_empty?(value)

        prefix = null_or_empty?(currency_symbol) ? '' : currency_symbol
        suffix = null_or_empty?(currency_code) ? '' : " #{currency_code}"

        formatted_value = number_formatter(value, currency_round)

        "#{prefix}#{formatted_value}#{suffix}"
      end

      def number_formatter(value, decimal_places)
        decimal_places = decimal_places.to_s.empty? ? 6 : decimal_places.to_s.to_i

        format("%0.#{decimal_places}f", value || 0)
          .gsub(thousands_regex, "\\0#{thousands_separator}")
          .gsub('.', decimal_separator)
      end

      def boolean_formatter(value, nullable)
        nullable = nullable.to_s == 'nullable'

        if nullable && nully?(value)
          null_value
        elsif truthy?(value)
          true_value
        else
          false_value
        end
      end

      private

      def mask(string, keep_last)
        unmasked_part     = string[-keep_last..-1]
        masked_char_count = string.size - keep_last

        (mask_char * masked_char_count) + unmasked_part
      end

      def null_or_empty?(val)
        val.nil? || val.to_s.empty?
      end

      # rubocop:disable Style/DoubleNegation
      def nully?(val)
        null_or_empty?(val) || !!(val.to_s =~ nullish_regex)
      end

      def truthy?(val)
        !!(val.to_s =~ truthy_regex)
      end
      # rubocop:enable Style/DoubleNegation
    end
  end
end
