# frozen_string_literal: true

module Promptmenot
  class Result
    attr_reader :text, :matches

    def initialize(text:, matches: [])
      @text = text
      @matches = matches.freeze
    end

    def safe?
      matches.empty?
    end

    def unsafe?
      !safe?
    end

    def categories_detected
      matches.map(&:category).uniq
    end

    def patterns_detected
      matches.map(&:pattern_name).uniq
    end

    def high_confidence_matches
      matches.select { |m| m.confidence == :high }
    end

    def summary
      return "No prompt injection detected." if safe?

      count = matches.size
      cats = categories_detected.map { |c| c.to_s.tr("_", " ") }.join(", ")
      "Detected #{count} potential prompt injection pattern#{"s" if count > 1} " \
        "in categories: #{cats}."
    end
  end
end
