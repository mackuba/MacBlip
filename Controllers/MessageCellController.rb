# -------------------------------------------------------
# MessageCellController.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class MessageCellController < SDListViewItem

  attr_accessor :dateLabel, :textView

  def self.dateFormatter
    @dateFormatter ||= HumanReadableDateFormatter.new
  end

  def loadView
    super
    dateLabel.formatter = self.class.dateFormatter

    # pull text view out of its scroll view (we can't do that in IB, Bad Things happen then)
    scrollView = textView.enclosingScrollView
    frame = scrollView.frame
    scrollView.removeFromSuperview
    textView.frame = frame
    self.view.addSubview(textView)
  end

  def heightForGivenWidth(width)
    self.view.frame.size.height
  end

  def nameLabelClicked(sender)
    BrowserController.openUsersDashboard(sender.stringValue)
  end

end
