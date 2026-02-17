# frozen_string_literal: true

module Promptmenot
  class Detector
    attr_reader :sensitivity, :categories

    def initialize(sensitivity: nil, categories: nil)
      @sensitivity = sensitivity || Promptmenot.configuration.sensitivity
      @categories = categories
    end

    def detect(text)
      return Result.new(text: text.to_s) if text.nil? || text.to_s.strip.empty?

      patterns = Promptmenot.registry.for_sensitivity_and_categories(
        @sensitivity,
        categories: @categories
      )

      all_matches = patterns.flat_map { |pattern| pattern.match(text.to_s) }
      deduped = deduplicate(all_matches)

      result = Result.new(text: text.to_s, matches: deduped)
      fire_callback(result) if result.unsafe?
      result
    end

    private

    def deduplicate(matches)
      return matches if matches.size <= 1

      sorted = matches.sort_by { |m| [m.position.begin, -m.position.size] }
      kept = []

      sorted.each do |match|
        next if kept.any? { |existing| contains?(existing, match) }

        kept.reject! { |existing| contains?(match, existing) }
        kept << match
      end

      kept
    end

    def contains?(outer, inner)
      outer.position.begin <= inner.position.begin && outer.position.end >= inner.position.end
    end

    def fire_callback(result)
      callback = Promptmenot.configuration.on_detect
      callback&.call(result)
    end
  end
end
