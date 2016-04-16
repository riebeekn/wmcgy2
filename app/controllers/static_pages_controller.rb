class StaticPagesController < ApplicationController
  skip_before_filter :signed_in_user
  
  def letsencrypt
    # use your code here, not mine
    render text: "WXdnfN4wJoZrq64RPcut9opMA_jGYDXhE-NBME5Hnd4.ElwIer_jaW8HCKuGoiS_jg9BQ-vXBrFsbbKFYlXCG78"
  end
end
