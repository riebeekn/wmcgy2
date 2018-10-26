class StaticPagesController < ApplicationController
  skip_before_filter :signed_in_user

  def letsencrypt
    render text: "zS4XHNerAToLya6-IVOxam9raASQ6GXPLLO0upPbMOI.ElwIer_jaW8HCKuGoiS_jg9BQ-vXBrFsbbKFYlXCG78"
  end
end
