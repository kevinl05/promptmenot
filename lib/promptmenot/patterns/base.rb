# frozen_string_literal: true

module Promptmenot
  module Patterns
    class Base
      class << self
        def inherited(subclass)
          super
          subclass.instance_variable_set(:@patterns, [])
        end

        def patterns
          @patterns ||= []
        end

        def register(name:, regex:, sensitivity: :medium, confidence: :medium)
          patterns << Pattern.new(
            name: name,
            category: category_name,
            regex: regex,
            sensitivity: sensitivity,
            confidence: confidence
          )
        end

        def category_name
          name.split("::").last
              .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
              .gsub(/([a-z\d])([A-Z])/, '\1_\2')
              .downcase
              .to_sym
        end
      end
    end
  end
end
