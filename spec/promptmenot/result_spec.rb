# frozen_string_literal: true

RSpec.describe Promptmenot::Result do
  let(:pattern_high) do
    Promptmenot::Pattern.new(name: :test_high, category: :cat_a, regex: /test/, confidence: :high)
  end
  let(:pattern_low) do
    Promptmenot::Pattern.new(name: :test_low, category: :cat_b, regex: /other/, confidence: :low)
  end
  let(:match_high) do
    Promptmenot::Match.new(pattern: pattern_high, matched_text: "test", position: 0...4)
  end
  let(:match_low) do
    Promptmenot::Match.new(pattern: pattern_low, matched_text: "other", position: 10...15)
  end

  describe "#safe?" do
    it "returns true when no matches" do
      result = described_class.new(text: "clean", matches: [])
      expect(result).to be_safe
    end

    it "returns false when matches exist" do
      result = described_class.new(text: "dirty", matches: [match_high])
      expect(result).not_to be_safe
    end
  end

  describe "#unsafe?" do
    it "returns false when safe" do
      result = described_class.new(text: "clean")
      expect(result).not_to be_unsafe
    end

    it "returns true when matches exist" do
      result = described_class.new(text: "dirty", matches: [match_high])
      expect(result).to be_unsafe
    end
  end

  describe "#categories_detected" do
    it "returns unique categories from matches" do
      result = described_class.new(text: "text", matches: [match_high, match_low])
      expect(result.categories_detected).to contain_exactly(:cat_a, :cat_b)
    end

    it "returns empty array when safe" do
      result = described_class.new(text: "clean")
      expect(result.categories_detected).to be_empty
    end
  end

  describe "#patterns_detected" do
    it "returns unique pattern names from matches" do
      result = described_class.new(text: "text", matches: [match_high, match_low])
      expect(result.patterns_detected).to contain_exactly(:test_high, :test_low)
    end

    it "returns empty array when safe" do
      result = described_class.new(text: "clean")
      expect(result.patterns_detected).to be_empty
    end
  end

  describe "#high_confidence_matches" do
    it "returns only high confidence matches" do
      result = described_class.new(text: "text", matches: [match_high, match_low])
      expect(result.high_confidence_matches).to contain_exactly(match_high)
    end

    it "returns empty array when no high confidence matches" do
      result = described_class.new(text: "text", matches: [match_low])
      expect(result.high_confidence_matches).to be_empty
    end
  end

  describe "#summary" do
    it "returns safe message when no matches" do
      result = described_class.new(text: "clean")
      expect(result.summary).to eq("No prompt injection detected.")
    end

    it "returns singular pattern for one match" do
      result = described_class.new(text: "text", matches: [match_high])
      expect(result.summary).to include("1 potential prompt injection pattern ")
      expect(result.summary).to include("cat a")
    end

    it "returns plural patterns for multiple matches" do
      result = described_class.new(text: "text", matches: [match_high, match_low])
      expect(result.summary).to include("2 potential prompt injection patterns ")
      expect(result.summary).to include("cat a")
      expect(result.summary).to include("cat b")
    end
  end

  describe "#matches" do
    it "returns a frozen array" do
      result = described_class.new(text: "text", matches: [match_high])
      expect(result.matches).to be_frozen
    end
  end
end
