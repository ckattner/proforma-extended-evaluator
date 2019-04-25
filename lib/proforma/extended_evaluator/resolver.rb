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

      attr_reader :separator

      def initialize(separator: DEFAULT_SEPARATOR)
        @separator = separator.to_s
      end

      def resolve(value, input)
        traverse(input, key_path(value))
      end

      private

      def key_path(value)
        return Array(value.to_s) if separator.empty?

        value.to_s.split(separator)
      end

      def traverse(object, through)
        pointer = object

        through.each do |t|
          next unless pointer

          pointer = get(pointer, t)
        end

        pointer
      end

      def get(object, key)
        if object.is_a?(Hash)
          indifferent_hash_get(object, key)
        elsif object.respond_to?(key)
          object.public_send(key)
        end
      end

      def indifferent_hash_get(hash, key)
        if hash.key?(key.to_s)
          hash[key.to_s]
        elsif hash.key?(key.to_s.to_sym)
          hash[key.to_s.to_sym]
        end
      end
    end
  end
end
