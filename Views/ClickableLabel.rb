# -------------------------------------------------------
# ClickableLabel.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class ClickableLabel < NSTextField

  def mouseDown(event)
    sendAction(self.action, to: self.target)
  end

end
