# frozen_string_literal: true

require "rails/railtie"

module Promptmenot
  class Railtie < Rails::Railtie
    initializer "promptmenot.i18n" do
      ActiveSupport.on_load(:i18n) do
        I18n.load_path += Dir[File.join(Promptmenot.root, "config", "locales", "**", "*.yml")]
      end
    end
  end
end
