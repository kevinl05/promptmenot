# frozen_string_literal: true

require "active_support/lazy_load_hooks"

require_relative "promptmenot/version"
require_relative "promptmenot/errors"
require_relative "promptmenot/pattern"
require_relative "promptmenot/match"
require_relative "promptmenot/result"
require_relative "promptmenot/configuration"
require_relative "promptmenot/pattern_registry"
require_relative "promptmenot/patterns/base"
require_relative "promptmenot/patterns/direct_instruction_override"
require_relative "promptmenot/patterns/role_manipulation"
require_relative "promptmenot/patterns/delimiter_injection"
require_relative "promptmenot/patterns/encoding_obfuscation"
require_relative "promptmenot/patterns/indirect_injection"
require_relative "promptmenot/patterns/context_manipulation"
require_relative "promptmenot/detector"
require_relative "promptmenot/sanitizer"
require_relative "promptmenot/validator"

module Promptmenot
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
      register_custom_patterns
    end

    def registry
      @registry ||= build_registry
    end

    def reset!
      @configuration = Configuration.new
      @registry = nil
    end

    def root
      File.expand_path("..", __dir__)
    end

    # Convenience API

    def safe?(text, sensitivity: nil)
      detect(text, sensitivity: sensitivity).safe?
    end

    def detect(text, sensitivity: nil)
      Detector.new(sensitivity: sensitivity).detect(text)
    end

    def sanitize(text, sensitivity: nil, replacement: nil)
      Sanitizer.new(sensitivity: sensitivity, replacement: replacement).sanitize(text)
    end

    private

    def build_registry
      reg = PatternRegistry.new
      pattern_classes.each { |klass| reg.register_all(klass.patterns) }
      register_custom_patterns(reg)
      reg
    end

    def pattern_classes
      [
        Patterns::DirectInstructionOverride,
        Patterns::RoleManipulation,
        Patterns::DelimiterInjection,
        Patterns::EncodingObfuscation,
        Patterns::IndirectInjection,
        Patterns::ContextManipulation
      ]
    end

    def register_custom_patterns(reg = @registry)
      return unless reg

      configuration.custom_patterns.each { |p| reg.register(p) }
    end
  end
end

require_relative "promptmenot/railtie" if defined?(Rails::Railtie)
