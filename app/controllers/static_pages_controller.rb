class StaticPagesController < ApplicationController
  skip_before_filter :signed_in_user
  
  def letsencrypt
    render text: "OkeBnoqeTJ63te5FrioJWtL_EFRcNA_deC7Qjl1ZBUY.ElwIer_jaW8HCKuGoiS_jg9BQ-vXBrFsbbKFYlXCG78"
  end
end
