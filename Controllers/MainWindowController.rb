# -------------------------------------------------------
# MainWindowController.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class MainWindowController < NSWindowController

  attr_accessor :listView, :spinner

  def init
    initWithWindowNibName "MainWindow"
    self
  end

  def windowDidLoad
    window.setContentBorderThickness 32, forEdge: NSMinYEdge
    listView.bind "content", toObject: OBMessage, withKeyPath: "list", options: nil
  end

  def newMessagePressed(sender)
    puts "new message ..."
  end

  def refreshPressed(sender)
    puts "refresh..."
  end

end
