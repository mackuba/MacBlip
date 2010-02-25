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

    # fix for NSImage#size returning wrong size because of weird DPI
    self.image.size = NSSize.new(50, 50) if self.image

    borderRect = NSInsetRect(wholeImage, -2.0, -2.0)
    MessageCell::FOREGROUND.set
    rounded = NSBezierPath.bezierPathWithRoundedRect(borderRect, xRadius: 7, yRadius: 7)
    rounded.lineWidth = 5
    rounded.stroke
  end

end
