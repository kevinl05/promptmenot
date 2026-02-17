# frozen_string_literal: true

module Promptmenot
  class Pattern
    SENSITIVITY_LEVELS = %i[low medium high paranoid].freeze
    CONFIDENCE_LEVELS = %i[high medium low].freeze

    attr_reader :name, :category, :regex, :sensitivity, :confidence

    def initialize(name:, category:, regex:, sensitivity: :medium, confidence: :medium)
      validate_sensitivity!(sensitivity)
      validate_confidence!(confidence)

      @name = name.to_sym
      @category = category.to_sym
      @regex = regex
      @sensitivity = sensitivity.to_sym
      @confidence = confidence.to_sym
    end

    def active_at?(level)
      level_index = SENSITIVITY_LEVELS.index(level.to_sym)
      pattern_index = SENSITIVITY_LEVELS.index(@sensitivity)
      return false unless level_index && pattern_index

      level_index >= pattern_index
    end

    def match(text)
      matches = []
      text.to_s.scan(regex) do
        match_data = Regexp.last_match
        matches << Match.new(
          pattern: self,
          matched_text: match_data[0],
          position: match_data.begin(0)...match_data.end(0)
        )
      end
      matches
    end

    def ==(other)
      other.is_a?(Pattern) && name == other.name && category == other.category
    end

    alias eql? ==

    def hash
      [name, category].hash
    end

    private

    def validate_sensitivity!(level)
      return if SENSITIVITY_LEVELS.include?(level.to_sym)

      raise PatternError, "Invalid sensitivity: #{level}. Must be one of: #{SENSITIVITY_LEVELS.join(", ")}"
    end

    def validate_confidence!(level)
      return if CONFIDENCE_LEVELS.include?(level.to_sym)

      raise PatternError, "Invalid confidence: #{level}. Must be one of: #{CONFIDENCE_LEVELS.join(", ")}"
    end
  end
end
