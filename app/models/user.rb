class User < ActiveRecord::Base
  has_many :identities

  has_many :user_bad_words
  has_many :bad_words, through: :user_bad_words

  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  validates_format_of :email, :without => TEMP_EMAIL_REGEX, on: :update

  def self.find_for_oauth(auth, signed_in_resource = nil)

    # Get the identity and user if they exist
    identity = Identity.find_for_oauth(auth)

    # If a signed_in_resource is provided it always overrides the existing user
    # to prevent the identity being locked with accidentally created accounts.
    # Note that this may leave zombie accounts (with no associated identity) which
    # can be cleaned up at a later date.
    user = signed_in_resource ? signed_in_resource : identity.user

    # Create the user if needed
    if user.nil?

      # Get the existing user by email if the provider gives us a verified email.
      # If no verified email was provided we assign a temporary email and ask the
      # user to verify it on the next step via UsersController.finish_signup
      # verify the email -  return email   --    facebook hash       linked in(not used here)      google oauth verified

      email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email || auth.extra.raw_info.email_verified)
      email = auth.info.email if email_is_verified
      user = User.where(:email => email).first if email

      # Create the user if it's a new registration
      if user.nil?
        user = User.new(
          name: auth.extra.raw_info.name,
          email: email ? email : "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com",
          password: Devise.friendly_token[0,20],
          facebook_id: auth.uid,
          token: auth.credentials.token
        )
        user.skip_confirmation!
        user.save!
      end
    end

    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
      identity.save!
    end
    user
  end

  def fetch_bad_words
    bad_words = []

    self.bad_words.each do |word|
      bad_words << word.word
    end

    bad_words
  end

  def should_shock?
    statuses = []

    self.pull_statuses.each do |s|
      unless s.message.nil?
        statuses << s.message.downcase
      end
    end
    status_words = []

    statuses.each do |status|
      status.split.each do |word|
        status_words << word
      end
    end

    bad_words = fetch_bad_words
    status_words.each do |word|
      bad_words.each do |bad_word|
        if word == bad_word
          self.shock
          break
        end
      end
    end
  end

  def shock
    # beep = "https://pavlok.herokuapp.com/api/#{self.bracelet_id}/beep/4"
    light = "https://pavlok.herokuapp.com/api/#{self.bracelet_id}/led/4"
    # shock = "https://pavlok.herokuapp.com/api/#{self.bracelet_id}/shock/150"

    # open(beep)
    open(light)
    # open(shock)
  end

  def pull_statuses
    status_feed = FbGraph2::User.new(self.facebook_id).authenticate(self.token)
    posts = []
    status_feed.statuses.each do |post|
      posts << post
    end
    posts
  end

  def email_verified?
    self.email && self.email !~ TEMP_EMAIL_REGEX
  end
end
