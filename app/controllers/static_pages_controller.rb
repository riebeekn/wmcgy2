class StaticPagesController < ApplicationController
  skip_before_filter :signed_in_user
  
  def letsencrypt
    if request.protocol.include? "www."
    	render text: "p8dPCmmZZ1BxIN8ckXRgpmpBIdwPy6d3yVtFdn4XPNg.ElwIer_jaW8HCKuGoiS_jg9BQ-vXBrFsbbKFYlXCG78"
    else
    	render text: "06Z4rK6JkGYENkhInyhUpkWhew7V53gAWj6-rTSt3l4.ElwIer_jaW8HCKuGoiS_jg9BQ-vXBrFsbbKFYlXCG78"
	end
  end
end
