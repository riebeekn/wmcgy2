class StaticPagesController < ApplicationController
  skip_before_filter :signed_in_user
  
  def letsencrypt
    render text: "ROeVUaUnmS7hrqAGjGO6V6rjW8-Mb5WN-V1FwhPj1uQ.ElwIer_jaW8HCKuGoiS_jg9BQ-vXBrFsbbKFYlXCG78"
  end
end
