# -------------------------------------------------------
# MessageCellController.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class MessageCellController < SDListViewItem

  attr_accessor :dateLabel

  def self.dateFormatter
    @dateFormatter ||= HumanReadableDateFormatter.new
  end

  def loadView
    super
    dateLabel.formatter = self.class.dateFormatter
  end

  def heightForGivenWidth(width)
    self.view.frame.size.height
  end

  def nameLabelClicked(sender)
    BrowserController.openUsersDashboard(sender.stringValue)
  end

end
