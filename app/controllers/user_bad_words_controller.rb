class UserBadWordsController < ApplicationController
  def create
    words_array = user_bad_word_params[:bad_words].downcase.split(",").map do |word|
      BadWord.find_or_create_by!(word: word.strip)
    end
    words_array.each do |word|
      binding.pry
      UserBadWord.create(user: current_user, bad_word: word)
    end
    redirect_to bad_words_path
  end

  def destroy
    @user_bad_word = UserBadWord.find(params[:id])
    @user_bad_word.destroy
    redirect_to bad_words_path
  end

  protected

  def user_bad_word_params
    params.require(:user_bad_word).permit(:bad_words)
  end

end
