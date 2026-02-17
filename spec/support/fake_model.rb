# frozen_string_literal: true

require "active_model"

class FakeModel
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :bio, :about_me, :notes, :title

  validates :bio, prompt_safety: true
  validates :about_me, prompt_safety: { mode: :sanitize }
  validates :notes, prompt_safety: { sensitivity: :high, mode: :reject }
  validates :title, prompt_safety: { sensitivity: :low, mode: :reject }
end
