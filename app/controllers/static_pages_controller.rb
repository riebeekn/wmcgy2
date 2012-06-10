class StaticPagesController < ApplicationController
  skip_before_filter :signed_in_user
  
end
