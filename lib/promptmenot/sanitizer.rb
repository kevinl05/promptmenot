# frozen_string_literal: true

module Promptmenot
  class Sanitizer
    SanitizeResult = Struct.new(:original, :sanitized, :matches, :changed?, keyword_init: true)

    attr_reader :sensitivity, :categories, :replacement

    def initialize(sensitivity: nil, categories: nil, replacement: nil)
      @sensitivity = sensitivity || Promptmenot.configuration.sensitivity
      @categories = categories
      @replacement = replacement || Promptmenot.configuration.replacement_text
    end

    def sanitize(text)
      return SanitizeResult.new(original: text.to_s, sanitized: text.to_s, matches: [], changed?: false) if text.nil?

      detector = Detector.new(sensitivity: @sensitivity, categories: @categories)
      result = detector.detect(text)

      return SanitizeResult.new(original: text.to_s, sanitized: text.to_s, matches: [], changed?: false) if result.safe?

      cleaned = remove_matches(text.to_s, result.matches)

      SanitizeResult.new(
        original: text.to_s,
        sanitized: cleaned,
        matches: result.matches,
        changed?: true
      )
    end

    private

    def remove_matches(text, matches)
      result = text.dup
      sorted = matches.sort_by { |m| -m.position.begin }

      sorted.each do |match|
        result[match.position] = @replacement
      end

      normalize_whitespace(result)
    end

    def normalize_whitespace(text)
      text.gsub(/[[:blank:]]{2,}/, " ").gsub(/(\n\s*){3,}/, "\n\n").strip
    end
  end
end
