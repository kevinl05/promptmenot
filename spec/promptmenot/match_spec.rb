# frozen_string_literal: true

RSpec.describe Promptmenot::Match do
  let(:pattern) do
    Promptmenot::Pattern.new(
      name: :test_pattern,
      category: :test_cat,
      regex: /test/,
      sensitivity: :medium,
      confidence: :high
    )
  end
  let(:match) do
    described_class.new(pattern: pattern, matched_text: "test", position: 5...9)
  end

  describe "delegate methods" do
    it "#category delegates to pattern" do
      expect(match.category).to eq(:test_cat)
    end

    it "#pattern_name delegates to pattern" do
      expect(match.pattern_name).to eq(:test_pattern)
    end

    it "#confidence delegates to pattern" do
      expect(match.confidence).to eq(:high)
    end

    it "#sensitivity delegates to pattern" do
      expect(match.sensitivity).to eq(:medium)
    end
  end

  describe "#==" do
    it "equals match with same pattern_name, text, and position" do
      other = described_class.new(pattern: pattern, matched_text: "test", position: 5...9)
      expect(match).to eq(other)
    end

    it "differs when matched_text differs" do
      other = described_class.new(pattern: pattern, matched_text: "other", position: 5...9)
      expect(match).not_to eq(other)
    end

    it "differs when position differs" do
      other = described_class.new(pattern: pattern, matched_text: "test", position: 0...4)
      expect(match).not_to eq(other)
    end

    it "differs from non-Match objects" do
      expect(match).not_to eq("not a match")
    end
  end

  describe "#matched_text" do
    it "returns the matched text" do
      expect(match.matched_text).to eq("test")
    end
  end

  describe "#position" do
    it "returns the range" do
      expect(match.position).to eq(5...9)
    end
  end
end
