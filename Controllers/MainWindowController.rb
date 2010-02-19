# -------------------------------------------------------
# MainWindowController.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class MainWindowController < NSWindowController

  attr_accessor :listView, :spinner, :loadingView, :newMessageButton, :dashboardButton

  def init
    initWithWindowNibName "MainWindow"
    self
  end

  def windowDidLoad
    @blip = OBConnector.sharedConnector
    mbObserve(@blip.dashboardMonitor, OBDashboardUpdatedNotification, :dashboardUpdated)
    mbObserve(@blip.dashboardMonitor, OBDashboardWillUpdateNotification, :dashboardWillUpdate)
    window.setContentBorderThickness 32, forEdge: NSMinYEdge
    @listView.bind "content", toObject: OBMessage, withKeyPath: "list", options: nil
    @spinner.startAnimation(self)
  end

  def dashboardWillUpdate
    @spinner.startAnimation(self)
  end

  def dashboardUpdated
    @loadingView.mbHide
    @newMessageButton.mbEnable
    @dashboardButton.mbEnable
    @spinner.stopAnimation(self)
  end

  def newMessagePressed(sender)
    puts "new message ..."
  end

  def dashboardPressed(sender)
    NSWorkspace.sharedWorkspace.openURL(NSURL.URLWithString("http://blip.pl/dashboard"))
  end

  def displayLoadingError(error)
    puts "error: #{error}"
  end

end
