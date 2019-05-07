# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Proforma
  class ExtendedEvaluator
    # This class is also meant to be plugged into Stringento to provide value resolution.
    class Resolver
      DEFAULT_SEPARATOR = '.'

      attr_reader :objectable_resolver

      def initialize(separator: DEFAULT_SEPARATOR)
        @objectable_resolver = Objectable.resolver(separator: separator)
      end

      def resolve(value, input)
        objectable_resolver.get(input, value)
      end
    end
  end
end
