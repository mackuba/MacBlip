# -------------------------------------------------------
# MainWindowController.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class MainWindowController < NSWindowController

  attr_accessor :listView, :spinner, :loadingView, :newMessageButton, :refreshButton

  def init
    initWithWindowNibName "MainWindow"
    self
  end

  def windowDidLoad
    @blip = OBConnector.sharedConnector
    mbObserve(@blip.dashboardMonitor, OBDashboardUpdatedNotification, :dashboardUpdated)
    window.setContentBorderThickness 32, forEdge: NSMinYEdge
    @listView.bind "content", toObject: OBMessage, withKeyPath: "list", options: nil
    @spinner.startAnimation(self)
  end

  def dashboardUpdating
    @spinner.startAnimation(self)
  end

  def dashboardUpdated
    @loadingView.mbHide
    @newMessageButton.mbEnable
    @refreshButton.mbEnable
    @spinner.stopAnimation(self)
  end

  def newMessagePressed(sender)
    puts "new message ..."
  end

  def refreshPressed(sender)
    puts "refresh..."
  end

  def displayLoadingError(error)
    puts "error: #{error}"
  end

end
