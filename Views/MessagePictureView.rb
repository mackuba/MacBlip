# -------------------------------------------------------
# MessagePictureView.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class MessagePictureView < NSImageView

  def mouseDown(event)
    NSApp.sendAction(self.action, to: self.target, from: self) if self.target
  end

end
