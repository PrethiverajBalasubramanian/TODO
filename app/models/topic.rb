class Topic < ApplicationRecord
  has_many :items, dependent: :destroy
  validates :name, presence: true, length: 1..20, uniqueness: true
end
