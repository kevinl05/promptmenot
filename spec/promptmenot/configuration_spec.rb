# frozen_string_literal: true

RSpec.describe Promptmenot::Configuration do
  subject(:config) { described_class.new }

  describe "defaults" do
    it "has medium sensitivity" do
      expect(config.sensitivity).to eq(:medium)
    end

    it "has reject mode" do
      expect(config.mode).to eq(:reject)
    end

    it "has default replacement text" do
      expect(config.replacement_text).to eq("[removed]")
    end

    it "has no callback" do
      expect(config.on_detect).to be_nil
    end

    it "has no custom patterns" do
      expect(config.custom_patterns).to be_empty
    end
  end

  describe "#add_pattern" do
    it "adds a custom pattern" do
      config.add_pattern(name: :test, regex: /test/i)
      expect(config.custom_patterns.size).to eq(1)
      expect(config.custom_patterns.first.name).to eq(:test)
    end

    it "defaults to custom category" do
      config.add_pattern(name: :test, regex: /test/i)
      expect(config.custom_patterns.first.category).to eq(:custom)
    end

    it "accepts custom category" do
      config.add_pattern(name: :test, regex: /test/i, category: :my_category)
      expect(config.custom_patterns.first.category).to eq(:my_category)
    end
  end

  describe "#custom_patterns" do
    it "returns a frozen copy" do
      patterns = config.custom_patterns
      expect(patterns).to be_frozen
    end
  end
end
