class Topic < ApplicationRecord
  has_many :items, dependent: :destroy
  validates :name, presence: true, length: 3..20, uniqueness: true
end
