# -------------------------------------------------------
# MessageCell.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class MessageCell < NSView

  FOREGROUND = NSColor.colorWithDeviceRed(0.94, green: 0.94, blue: 0.94, alpha: 1.0)
  BORDER = NSColor.colorWithDeviceRed(0.6, green: 0.6, blue: 0.6, alpha: 1.0)

  def drawRect(rect)
    wholeCell = self.bounds
    padded = NSInsetRect(wholeCell, 10, 5)
    rounded = NSBezierPath.bezierPathWithRoundedRect(padded, xRadius: 5, yRadius: 5)

    FOREGROUND.set
    rounded.fill
    BORDER.set
    rounded.stroke

    super(padded)
  end

end
