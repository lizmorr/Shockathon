class BadWord < ActiveRecord::Base
  validates :word, presence: true, uniqueness: true
  has_many :users, through: :user_bad_words
  has_many :user_bad_words



  # status = "lol, i don't know how to talk.."
  # status.downcase!
  # status_words = status.split(" ")
  #
  # user_bad_words = ["lol", "lmao"]
  #
  #
  # status_words.each do |word|
  #   user_bad_words.each do |bad_word|
  #     if word == bad_word
  #
  #       returns  1
  #       # place shock function here
  #       break
  #     end
  #   end
  #
  #   user.bad_words.include?(word)
  # end
end
