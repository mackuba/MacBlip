# -------------------------------------------------------
# TweetieLikeScroller.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under Eclipse Public License v1.0
# -------------------------------------------------------

# "Borrowed" from Steven Degutis's TheGist

class TweetieLikeScroller < NSScroller

  SCROLLER_RADIUS = 6.0

  def self.gradient
    if @gradient.nil?
      baseGray = 0.45
      startColor = NSColor.colorWithCalibratedWhite(baseGray + 0.10, alpha: 1.0)
      endColor = NSColor.colorWithCalibratedWhite(baseGray + 0.01, alpha: 1.0)
      @gradient = NSGradient.alloc.initWithStartingColor(startColor, endingColor: endColor)
    end
    @gradient
  end

  def self.isCompatibleWithOverlayScrollers
    self == TweetieLikeScroller
  end

  def awakeFromNib
    # on Lion use the standard scrollers, because they have a similar style and look better
    @useDefaultScroller = self.respond_to?(:scrollerStyle)
  end

  def setKnobProportion(amount)
    if @useDefaultScroller
      super
    else
      super(amount / 2)
    end
  end

  def drawRect(rect)
    if @useDefaultScroller
      super
    else
      self.superview.backgroundColor.setFill
      NSBezierPath.fillRect(self.bounds)

      scrollerRect = self.rectForPart(NSScrollerKnob)
      scrollerRect.size.width *= 0.8

      unless scrollerRect.size == NSZeroSize
        path = NSBezierPath.bezierPathWithRoundedRect(scrollerRect, xRadius: SCROLLER_RADIUS, yRadius: SCROLLER_RADIUS)
        gradient = self.class.gradient
        gradient.drawInBezierPath(path, angle: 0.0)
      end
    end
  end

end
