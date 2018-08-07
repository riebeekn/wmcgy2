class StaticPagesController < ApplicationController
  skip_before_filter :signed_in_user

  def letsencrypt
    render text: "LDBbulJ3Q4jDvY9j47Ab3rV8Cg3Yc06Kmdx9OT7HDig.ElwIer_jaW8HCKuGoiS_jg9BQ-vXBrFsbbKFYlXCG78"
  end
end
