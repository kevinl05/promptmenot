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

    it "has default max_length" do
      expect(config.max_length).to eq(50_000)
    end

    it "has no callback" do
      expect(config.on_detect).to be_nil
    end

    it "has no custom patterns" do
      expect(config.custom_patterns).to be_empty
    end
  end

  describe "#sensitivity=" do
    it "accepts valid sensitivity levels" do
      %i[low medium high paranoid].each do |level|
        config.sensitivity = level
        expect(config.sensitivity).to eq(level)
      end
    end

    it "accepts string sensitivity levels" do
      config.sensitivity = "high"
      expect(config.sensitivity).to eq(:high)
    end

    it "raises ConfigurationError for invalid sensitivity" do
      expect { config.sensitivity = :banana }.to raise_error(
        Promptmenot::ConfigurationError, /Invalid sensitivity: banana/
      )
    end
  end

  describe "#mode=" do
    it "accepts valid modes" do
      %i[reject sanitize].each do |mode|
        config.mode = mode
        expect(config.mode).to eq(mode)
      end
    end

    it "accepts string modes" do
      config.mode = "sanitize"
      expect(config.mode).to eq(:sanitize)
    end

    it "raises ConfigurationError for invalid mode" do
      expect { config.mode = :invalid }.to raise_error(
        Promptmenot::ConfigurationError, /Invalid mode: invalid/
      )
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

    it "invalidates custom_patterns cache" do
      _ = config.custom_patterns # warm cache
      config.add_pattern(name: :test, regex: /test/i)
      expect(config.custom_patterns.size).to eq(1)
    end
  end

  describe "#custom_patterns" do
    it "returns a frozen copy" do
      patterns = config.custom_patterns
      expect(patterns).to be_frozen
    end

    it "returns consistent results on repeated calls" do
      config.add_pattern(name: :test, regex: /test/i)
      expect(config.custom_patterns.size).to eq(config.custom_patterns.size)
    end
  end
end
