class Item < ApplicationRecord
  belongs_to :topic
  validates :description, presence: true, length: 1..50
end
