class StaticPagesController < ApplicationController
  skip_before_filter :signed_in_user
  
  def letsencrypt
    render text: "y38eP6vVEkliINf_hYy68vuTFeYwhCyIKjuRU8LjX70.ElwIer_jaW8HCKuGoiS_jg9BQ-vXBrFsbbKFYlXCG78"
  end
end
