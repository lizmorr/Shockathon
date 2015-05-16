class BadWordsController < ApplicationController
  def index
    @user_bad_word = UserBadWord.new
    @bad_words = BadWord.new
    @user_bad_words = UserBadWord.where(user: current_user)
  end
end
