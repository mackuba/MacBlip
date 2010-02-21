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

    window.setContentBorderThickness(32, forEdge: NSMinYEdge)
    window.movableByWindowBackground = true

    @listView.bind "content", toObject: OBMessage, withKeyPath: "list", options: nil
    @listView.sortDescriptors = [NSSortDescriptor.sortDescriptorWithKey('date', ascending: true)]
    # the order is actually descending, but listView is not flipped so it counts Y coordinate from bottom... o_O

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
    if messages && messages.count > 0
      scrollToTop
      messages.each do |msg|
        sendGrowlNotification(msg) unless msg.user.login == @blip.account.username
      end
    end

    @loadingView.mbHide
    @newMessageButton.mbEnable
    @dashboardButton.mbEnable
    @spinner.stopAnimation(self)
  end

  def newMessagePressed(sender)
    @newMessageDialog = NewMessageDialogController.alloc.initWithMainWindow(self) if @newMessageDialog.nil?
    @newMessageDialog.showWindow(self)
  end

  def newMessageDialogClosed
    @newMessageDialog = nil
  end

  def dashboardPressed(sender)
    BrowserController.openDashboard
  end

  def displayLoadingError(error)
    puts "error: #{error}"
  end

  def sendGrowlNotification(message)
    GrowlApplicationBridge.notifyWithTitle(
      message.user.login,
      description: message.body,
      notificationName: "Update received",
      iconData: message.user.avatarData,
      priority: 0,
      isSticky: false,
      clickContext: nil
    )
  end

end
