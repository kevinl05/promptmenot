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

      input = text.to_s
      max = Promptmenot.configuration.max_length
      input = input[0, max] if max && input.length > max

      patterns = Promptmenot.registry.for_sensitivity_and_categories(
        @sensitivity,
        categories: @categories
      )

      all_matches = patterns.flat_map { |pattern| pattern.match(input) }
      deduped = deduplicate(all_matches)

      result = Result.new(text: input, matches: deduped)
      fire_callback(result) if result.unsafe?
      result
    end

    private

    def deduplicate(matches)
      return matches if matches.size <= 1

      sorted = matches.sort_by { |m| [m.position.begin, -m.position.size] }
      kept = []

      sorted.each do |match|
        existing = kept.find { |m| overlaps?(m, match) }
        if existing
          # Keep the larger match when overlapping
          if match.position.size > existing.position.size
            kept.delete(existing)
            kept << match
          end
        else
          kept << match
        end
      end

      kept
    end

    def overlaps?(first, second)
      first.position.begin < second.position.end && second.position.begin < first.position.end
    end

    def fire_callback(result)
      callback = Promptmenot.configuration.on_detect
      callback&.call(result)
    rescue StandardError => e
      warn "[Promptmenot] on_detect callback raised #{e.class}: #{e.message}"
    end
  end
end
