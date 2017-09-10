class StaticPagesController < ApplicationController
  skip_before_filter :signed_in_user
  
  def letsencrypt
    render text: "SHxTcZIOvzyo4c0RdZFPcBBnB4MXNNOoIBx-QR5ghuw.ElwIer_jaW8HCKuGoiS_jg9BQ-vXBrFsbbKFYlXCG78"
  end
end
