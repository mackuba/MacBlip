# -------------------------------------------------------
# HumanReadableDateFormatter.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under Eclipse Public License v1.0
# -------------------------------------------------------

class HumanReadableDateFormatter < NSFormatter

  def init
    @dateOnlyFormatter = NSDateFormatter.new
    @dateOnlyFormatter.dateStyle = NSDateFormatterShortStyle
    @dateOnlyFormatter.timeStyle = NSDateFormatterNoStyle

    @timeOnlyFormatter = NSDateFormatter.new
    @timeOnlyFormatter.dateStyle = NSDateFormatterNoStyle
    @timeOnlyFormatter.timeStyle = NSDateFormatterMediumStyle

    @timeAndDayFormatter = NSDateFormatter.new
    @timeAndDayFormatter.dateFormat = "EEEE, HH:mm:ss"

    self
  end

  def stringForObjectValue(date)
    thatDate = @dateOnlyFormatter.stringFromDate(date)
    today = @dateOnlyFormatter.stringFromDate(NSDate.date)
    if thatDate == today
      @timeOnlyFormatter.stringFromDate(date)
    else
      @timeAndDayFormatter.stringFromDate(date)
    end
  end

end
