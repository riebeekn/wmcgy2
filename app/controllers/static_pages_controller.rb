class StaticPagesController < ApplicationController
  skip_before_filter :signed_in_user
  
  def letsencrypt
    render text: "h4DQnKnlyVhqIB3qleoWAPidq1qKZI89N12VygTAMoI.ElwIer_jaW8HCKuGoiS_jg9BQ-vXBrFsbbKFYlXCG78"
  end
end
