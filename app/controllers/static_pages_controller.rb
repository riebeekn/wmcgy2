class StaticPagesController < ApplicationController
  skip_before_filter :signed_in_user
  
  def letsencrypt
    # use your code here, not mine
    render text: "aYGbqKexyaQ1RRCqbYkAu4F3U1H9TzfR4icmIlCDrtg.ElwIer_jaW8HCKuGoiS_jg9BQ-vXBrFsbbKFYlXCG78"
  end
end
