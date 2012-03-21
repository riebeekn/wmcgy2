class StaticPagesController < ApplicationController
  before_filter :signed_in_user, only: [:home]
end
