# frozen_string_literal: true

module Promptmenot
  class Configuration
    attr_accessor :sensitivity, :mode, :replacement_text, :on_detect

    def initialize
      @sensitivity = :medium
      @mode = :reject
      @replacement_text = "[removed]"
      @custom_patterns = []
      @on_detect = nil
    end

    def custom_patterns
      @custom_patterns.dup.freeze
    end

    def add_pattern(name:, regex:, category: :custom, sensitivity: :medium, confidence: :medium)
      @custom_patterns << Pattern.new(
        name: name,
        category: category,
        regex: regex,
        sensitivity: sensitivity,
        confidence: confidence
      )
    end
  end
end
