# -------------------------------------------------------
# MainWindowController.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class MainWindowController < NSWindowController

  attr_accessor :table

  def init
    initWithWindowNibName "MainWindow"
    self
  end

  def messages
    OBMessage.list
  end

  def refresh
    @table.reloadData
  end

  def tableView table, objectValueForTableColumn: column, row: row
    messages[row].send(column.identifier)
  end

  def numberOfRowsInTableView table
    messages.length
  end

end
