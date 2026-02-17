# frozen_string_literal: true

require "rails/generators"

module Promptmenot
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates a Promptmenot initializer in your application."

      def copy_initializer
        template "promptmenot.rb", "config/initializers/promptmenot.rb"
      end
    end
  end
end
