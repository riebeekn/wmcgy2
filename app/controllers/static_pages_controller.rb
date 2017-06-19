class StaticPagesController < ApplicationController
  skip_before_filter :signed_in_user
  
  def letsencrypt
    render text: "5QqieZKurbO8CTRFbWFToEJNzQbfIVcd0Yl1GMQ0g1I.ElwIer_jaW8HCKuGoiS_jg9BQ-vXBrFsbbKFYlXCG78"
  end
end
