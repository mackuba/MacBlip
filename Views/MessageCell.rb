# -------------------------------------------------------
# MessageCell.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class MessageCell < NSView

  attr_reader :padding
  attr_accessor :textView

  BACKGROUND = NSColor.colorWithDeviceRed(0.94, green: 0.94, blue: 0.94, alpha: 1.0)
  FOLLOW_BACKGROUND = NSColor.colorWithDeviceRed(0.97, green: 0.97, blue: 0.84, alpha: 1.0)
  NOTICE_BACKGROUND = NSColor.colorWithDeviceRed(0.86, green: 0.92, blue: 0.98, alpha: 1.0)
  BORDER = NSColor.colorWithDeviceRed(0.6, green: 0.6, blue: 0.6, alpha: 1.0)
  LABEL_PADDING = 4

  def awakeFromNib
    @userLabel = self.viewWithTag(1)
    @dateLabel = self.viewWithTag(2)
    @colorWell = self.viewWithTag(3) # hidden control which is only used to store the appropriate background color
    @pictureView = self.viewWithTag(4)
    @userLabelFont = @userLabel.font
  end

  def initializeLayout(scrollViewFrame, withPicture: hasPicture)
    @textViewOrigin = scrollViewFrame.origin
    verticalPadding = self.frame.size.height - scrollViewFrame.size.height
    horizontalPadding = self.frame.size.width - scrollViewFrame.size.width
    horizontalPadding += @pictureView.frame.size.width if hasPicture
    @padding = NSSize.new(horizontalPadding, verticalPadding)
  end

  def messageBackgroundColor
    @colorWell.color
  end

  def drawRect(rect)
    wholeCell = self.bounds
    padded = NSInsetRect(wholeCell, 10, 5)
    rounded = NSBezierPath.bezierPathWithRoundedRect(padded, xRadius: 5, yRadius: 5)

    messageBackgroundColor.set
    rounded.fill
    BORDER.set
    rounded.stroke

    super(padded)
  end

  def resizeSubviewsWithOldSize(size)
    user = @userLabel.stringValue
    date = @dateLabel.stringValue
    oldDateWidth = @dateLabel.frame.size.width
    newDateWidth = date.sizeWithAttributes({ NSFontAttributeName => @dateLabel.font }).width + LABEL_PADDING
    space = @dateLabel.frame.origin.x + oldDateWidth - @userLabel.frame.origin.x

    frame = @dateLabel.frame
    frame.size.width = newDateWidth
    frame.origin.x += oldDateWidth - newDateWidth
    @dateLabel.frame = frame

    @userLabel.font = @userLabelFont
    newUserWidth = user.sizeWithAttributes({ NSFontAttributeName => @userLabelFont }).width + LABEL_PADDING
    while (space - newDateWidth < newUserWidth)
      @userLabel.font = NSFont.fontWithName(@userLabel.font.fontName, size: @userLabel.font.pointSize - 0.5)
      newUserWidth = user.sizeWithAttributes({ NSFontAttributeName => @userLabel.font }).width + LABEL_PADDING
    end

    frame = @userLabel.frame
    frame.size.width = space - newDateWidth
    @userLabel.frame = frame

    frame = textView.frame
    frame.origin = @textViewOrigin
    frame.size.width = self.frame.size.width - @padding.width
    frame.size.height = self.frame.size.height - @padding.height
    textView.frame = frame

    super
  end

end
