class StaticPagesController < ApplicationController
  skip_before_filter :signed_in_user
  
  def letsencrypt
    # use your code here, not mine
    render text: "06Z4rK6JkGYENkhInyhUpkWhew7V53gAWj6-rTSt3l4.ElwIer_jaW8HCKuGoiS_jg9BQ-vXBrFsbbKFYlXCG78"
  end
end
