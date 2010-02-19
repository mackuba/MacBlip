# -------------------------------------------------------
# MainWindowController.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class MainWindowController < NSWindowController

  attr_accessor :listView, :scrollView, :spinner, :loadingView, :newMessageButton, :dashboardButton

  def init
    initWithWindowNibName "MainWindow"
    self
  end

  def windowDidLoad
    @blip = OBConnector.sharedConnector
    mbObserve(@blip.dashboardMonitor, OBDashboardUpdatedNotification, 'dashboardUpdated:')
    mbObserve(@blip.dashboardMonitor, OBDashboardWillUpdateNotification, :dashboardWillUpdate)

    window.setContentBorderThickness 32, forEdge: NSMinYEdge
    window.movableByWindowBackground = true

    @listView.bind "content", toObject: OBMessage, withKeyPath: "list", options: nil
    @spinner.startAnimation(self)
  end

  def dashboardWillUpdate
    @spinner.startAnimation(self)
  end

  def scrollToTop
    scrollView.verticalScroller.floatValue = 0
    scrollView.contentView.scrollToPoint(NSZeroPoint)
  end

  def dashboardUpdated(notification)
    messages = notification.userInfo["messages"]
    scrollToTop if messages && messages.count > 0

    @loadingView.mbHide
    @newMessageButton.mbEnable
    @dashboardButton.mbEnable
    @spinner.stopAnimation(self)
  end

  def newMessagePressed(sender)
    puts "new message ..."
  end

  def dashboardPressed(sender)
    BrowserController.openDashboard
  end

  def displayLoadingError(error)
    puts "error: #{error}"
  end

end
