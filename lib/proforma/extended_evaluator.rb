# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'bigdecimal'
require 'forwardable'
require 'stringento'

require_relative 'extended_evaluator/formatter'
require_relative 'extended_evaluator/resolver'

module Proforma
  # This class provides robust functionality for value resolution and text templating.
  # For value resolution it uses its own dot-notation and
  # message-based object traversal algorithm.
  # For text templating it uses the Stringento library.
  class ExtendedEvaluator
    attr_reader :formatter, :resolver

    def initialize(formatter: Formatter.new, resolver: Resolver.new)
      raise ArgumentError, 'formatter is required'  unless formatter
      raise ArgumentError, 'resolver is required'   unless resolver

      @formatter  = formatter
      @resolver   = resolver

      freeze
    end

    def value(object, expression)
      resolver.resolve(expression, object)
    end

    def text(object, expression)
      record = object.is_a?(Array) || object.nil? ? {} : object

      Stringento.evaluate(
        expression.to_s,
        record,
        resolver: resolver,
        formatter: formatter
      )
    end
  end
end
