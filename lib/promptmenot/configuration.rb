# frozen_string_literal: true

module Promptmenot
  class Configuration
    VALID_SENSITIVITIES = %i[low medium high paranoid].freeze
    VALID_MODES = %i[reject sanitize].freeze

    attr_reader :sensitivity, :mode
    attr_accessor :replacement_text, :on_detect, :max_length

    def initialize
      @sensitivity = :medium
      @mode = :reject
      @replacement_text = "[removed]"
      @max_length = 50_000
      @custom_patterns_list = []
      @custom_patterns = nil
      @on_detect = nil
    end

    def sensitivity=(value)
      sym = value.to_sym
      unless VALID_SENSITIVITIES.include?(sym)
        raise ConfigurationError, "Invalid sensitivity: #{value}. Must be one of: #{VALID_SENSITIVITIES.join(", ")}"
      end

      @sensitivity = sym
    end

    def mode=(value)
      sym = value.to_sym
      unless VALID_MODES.include?(sym)
        raise ConfigurationError, "Invalid mode: #{value}. Must be one of: #{VALID_MODES.join(", ")}"
      end

      @mode = sym
    end

    def custom_patterns
      @custom_patterns ||= @custom_patterns_list.dup.freeze
    end

    def add_pattern(name:, regex:, category: :custom, sensitivity: :medium, confidence: :medium)
      @custom_patterns_list << Pattern.new(
        name: name,
        category: category,
        regex: regex,
        sensitivity: sensitivity,
        confidence: confidence
      )
      @custom_patterns = nil
    end
  end
end
