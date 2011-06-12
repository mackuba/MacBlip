# -------------------------------------------------------
# HumanReadableDateFormatter.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under Eclipse Public License v1.0
# -------------------------------------------------------

class HumanReadableDateFormatter < NSFormatter

  def init
    @timeOnlyFormatter = NSDateFormatter.new
    @timeOnlyFormatter.dateStyle = NSDateFormatterNoStyle
    @timeOnlyFormatter.timeStyle = NSDateFormatterMediumStyle

    @timeAndDayFormatter = NSDateFormatter.new
    @timeAndDayFormatter.dateFormat = "EEEE, HH:mm:ss"

    @timeAndDateFormatter = NSDateFormatter.new
    @timeAndDateFormatter.dateFormat = "dd.MM.yyyy HH:mm"

    self
  end

  def stringForObjectValue(date)
    formatter = case
      when date.psMidnight == NSDate.date.psMidnight
        @timeOnlyFormatter
      when date.psMidnight >= NSDate.psDaysAgo(6).psMidnight
        @timeAndDayFormatter
      else
        @timeAndDateFormatter
    end

    formatter.stringFromDate(date)
  end

end
