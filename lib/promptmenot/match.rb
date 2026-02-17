# frozen_string_literal: true

module Promptmenot
  class Match
    attr_reader :pattern, :matched_text, :position

    def initialize(pattern:, matched_text:, position:)
      @pattern = pattern
      @matched_text = matched_text
      @position = position
    end

    def category
      pattern.category
    end

    def pattern_name
      pattern.name
    end

    def confidence
      pattern.confidence
    end

    def sensitivity
      pattern.sensitivity
    end

    def overlaps?(other)
      position.cover?(other.position.begin) || other.position.cover?(position.begin)
    end

    def ==(other)
      other.is_a?(Match) &&
        pattern_name == other.pattern_name &&
        matched_text == other.matched_text &&
        position == other.position
    end
  end
end
