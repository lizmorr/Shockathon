class BadWord < ActiveRecord::Base
  validates :word, presence: true, uniqueness: true
  has_many :users, through: :user_bad_words
  has_many :user_bad_words
end
