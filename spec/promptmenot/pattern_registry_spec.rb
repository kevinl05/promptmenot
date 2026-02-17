# frozen_string_literal: true

RSpec.describe Promptmenot::PatternRegistry do
  subject(:registry) { described_class.new }

  let(:low_pattern) do
    Promptmenot::Pattern.new(name: :p1, category: :cat_a, regex: /a/, sensitivity: :low)
  end
  let(:medium_pattern) do
    Promptmenot::Pattern.new(name: :p2, category: :cat_a, regex: /b/, sensitivity: :medium)
  end
  let(:high_pattern) do
    Promptmenot::Pattern.new(name: :p3, category: :cat_b, regex: /c/, sensitivity: :high)
  end

  before do
    registry.register(low_pattern)
    registry.register(medium_pattern)
    registry.register(high_pattern)
  end

  describe "#register" do
    it "adds patterns" do
      expect(registry.size).to eq(3)
    end

    it "prevents duplicates" do
      registry.register(low_pattern)
      expect(registry.size).to eq(3)
    end
  end

  describe "#for_sensitivity" do
    it "returns only patterns active at :low" do
      expect(registry.for_sensitivity(:low)).to contain_exactly(low_pattern)
    end

    it "returns patterns active at :medium" do
      expect(registry.for_sensitivity(:medium)).to contain_exactly(low_pattern, medium_pattern)
    end

    it "returns all patterns at :paranoid" do
      expect(registry.for_sensitivity(:paranoid)).to contain_exactly(low_pattern, medium_pattern, high_pattern)
    end
  end

  describe "#for_category" do
    it "filters by category" do
      expect(registry.for_category(:cat_a)).to contain_exactly(low_pattern, medium_pattern)
      expect(registry.for_category(:cat_b)).to contain_exactly(high_pattern)
    end
  end

  describe "#for_sensitivity_and_categories" do
    it "filters by both sensitivity and category" do
      results = registry.for_sensitivity_and_categories(:medium, categories: [:cat_a])
      expect(results).to contain_exactly(low_pattern, medium_pattern)
    end

    it "returns all categories when none specified" do
      results = registry.for_sensitivity_and_categories(:high)
      expect(results).to contain_exactly(low_pattern, medium_pattern, high_pattern)
    end
  end

  describe "#categories" do
    it "returns unique categories" do
      expect(registry.categories).to contain_exactly(:cat_a, :cat_b)
    end
  end

  describe "#clear" do
    it "removes all patterns" do
      registry.clear
      expect(registry.size).to eq(0)
    end
  end

  describe "#each" do
    it "is enumerable" do
      names = registry.map(&:name)
      expect(names).to contain_exactly(:p1, :p2, :p3)
    end
  end
end
