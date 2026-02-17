# frozen_string_literal: true

require "set"

module Promptmenot
  class PatternRegistry
    include Enumerable

    def initialize
      @patterns = Set.new
    end

    def register(pattern)
      @patterns.add(pattern)
    end

    def register_all(patterns)
      patterns.each { |p| register(p) }
    end

    def each(&block)
      @patterns.each(&block)
    end

    def size
      @patterns.size
    end

    def for_sensitivity(level)
      @patterns.select { |p| p.active_at?(level) }
    end

    def for_category(category)
      @patterns.select { |p| p.category == category.to_sym }
    end

    def for_sensitivity_and_categories(sensitivity, categories: nil)
      filtered = for_sensitivity(sensitivity)
      return filtered unless categories

      category_syms = Array(categories).map(&:to_sym)
      filtered.select { |p| category_syms.include?(p.category) }
    end

    def categories
      @patterns.map(&:category).uniq
    end

    def clear
      @patterns.clear
    end
  end
end
