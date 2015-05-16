class HomesController < ApplicationController
  def index
    @statuses = []
    current_user.pull_statuses.each { |p| @statuses << p.message }

    current_user.should_shock?
  end
end
