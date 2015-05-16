class UserBadWord < ActiveRecord::Base
  validates :bad_word_id, presence: true
  validates :user_id, presence: true
  belongs_to :user
  belongs_to :bad_word
  has_many :users
  has_many :bad_words
end
