# -------------------------------------------------------
# WarningBar.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under Eclipse Public License v1.0
# -------------------------------------------------------

class WarningBar < NSView

  WIDTH = 100.0
  HEIGHT = 30.0
  PADDING = 5.0
  ICON_SIZE = 16.0

  attr_accessor :displayed

  def initWithType(type)
    initWithFrame(NSMakeRect(0, 0, WIDTH, HEIGHT))

    @displayed = false
    self.autoresizingMask = NSViewMinYMargin | NSViewWidthSizable

    @label = NSTextField.alloc.initWithFrame(NSMakeRect(
      PADDING + ICON_SIZE + PADDING, PADDING,
      WIDTH - PADDING * 2, HEIGHT - PADDING * 2
    ))
    @label.stringValue = ""
    @label.editable = false
    @label.bezeled = false
    @label.backgroundColor = NSColor.clearColor
    @label.textColor = NSColor.whiteColor
    @label.autoresizingMask = self.autoresizingMask
    @label.font = NSFont.boldSystemFontOfSize(14)
    @label.alignment = NSLeftTextAlignment
    self.addSubview(@label)

    @shadow = NSShadow.new
    @shadow.shadowOffset = NSMakeSize(1, -1)
    @shadow.shadowColor = NSColor.colorWithDeviceWhite(0.0, alpha: 0.9)
    @shadow.shadowBlurRadius = 2.0

    @image = NSImageView.alloc.initWithFrame(NSMakeRect(
      (HEIGHT - ICON_SIZE) / 2.0, (HEIGHT - ICON_SIZE) / 2.0,
      ICON_SIZE, ICON_SIZE
    ))
    @image.image = NSImage.imageNamed((type == :error) ? "error.png" : "warning.png")
    self.addSubview(@image)

    if type == :error
      color1 = NSColor.colorWithDeviceRed(0.8, green: 0.2, blue: 0.2, alpha: 0.9)
      color2 = NSColor.colorWithDeviceRed(0.2, green: 0.05, blue: 0.05, alpha: 0.9)
    else
      color1 = NSColor.colorWithDeviceRed(0.9, green: 0.7, blue: 0.2, alpha: 0.9)
      color2 = NSColor.colorWithDeviceRed(0.2, green: 0.18, blue: 0.05, alpha: 0.9)
    end
    @gradient = NSGradient.alloc.initWithStartingColor(color1, endingColor: color2)

    self
  end

  def viewDidMoveToSuperview
    if self.superview
      size = self.superview.frame.size
      self.frame = NSMakeRect(0, size.height, size.width, HEIGHT)
    end
  end

  def slideIn
    @displayed = true
    size = self.superview.frame.size
    self.animator.frame = NSMakeRect(0, size.height - HEIGHT, size.width, HEIGHT)
  end

  def slideOut
    @displayed = false
    size = self.superview.frame.size
    self.animator.frame = NSMakeRect(0, size.height, size.width, HEIGHT)
  end

  def text
    @label.stringValue.to_s
  end

  def text=(s)
    richText = NSMutableAttributedString.alloc.initWithString(s)
    richText.addAttribute(NSShadowAttributeName, value: @shadow, range: NSMakeRange(0, s.length))
    @label.stringValue = richText
  end

  def drawRect(rect)
    @gradient.drawInRect(self.bounds, angle: 270)
    super(self.bounds)
  end

end
