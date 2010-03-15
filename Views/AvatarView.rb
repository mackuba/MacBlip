# -------------------------------------------------------
# AvatarView.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class AvatarView < NSImageView

  def drawRect(rect)
    wholeImage = self.bounds
    super(wholeImage)

    borderRect = NSInsetRect(wholeImage, -2.0, -2.0)
    MessageCell::BACKGROUND.set
    rounded = NSBezierPath.bezierPathWithRoundedRect(borderRect, xRadius: 7, yRadius: 7)
    rounded.lineWidth = 5
    rounded.stroke
  end

  def mouseDown(event)
    NSApp.sendAction(self.action, to: self.target, from: self) if self.target
  end

end
