class StaticPagesController < ApplicationController
  skip_before_filter :signed_in_user

  def letsencrypt
    render text: "IqFDFYj-ITCyQNeUWOQyEN8KwhNfB6C0IOsxzsIgmxI.ElwIer_jaW8HCKuGoiS_jg9BQ-vXBrFsbbKFYlXCG78"
  end
end
