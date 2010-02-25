# -------------------------------------------------------
# MainWindowController.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class MainWindowController < NSWindowController

  LAST_GROWLED_KEY = "growl.lastGrowledMessageId"
  GROWL_LIMIT = 5

  attr_accessor :listView, :scrollView, :spinner, :loadingView, :newMessageButton, :dashboardButton

  def init
    initWithWindowNibName "MainWindow"
    @lastGrowled = NSUserDefaults.standardUserDefaults.integerForKey(LAST_GROWLED_KEY) || 0
    self
  end

  def windowDidLoad
    @blip = OBConnector.sharedConnector
    mbObserve(@blip.dashboardMonitor, OBDashboardUpdatedNotification, 'dashboardUpdated:')
    mbObserve(@blip.dashboardMonitor, OBDashboardUpdateFailedNotification, 'dashboardUpdateFailed:')
    mbObserve(@blip.dashboardMonitor, OBDashboardWillUpdateNotification, :dashboardWillUpdate)

    window.setContentBorderThickness(32, forEdge: NSMinYEdge)
    window.movableByWindowBackground = true

    @listView.bind "content", toObject: OBMessage, withKeyPath: "list", options: nil
    @listView.sortDescriptors = [NSSortDescriptor.sortDescriptorWithKey('date', ascending: true)]
    @listView.topPadding = 5
    @listView.bottomPadding = 5
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
      self.performSelector('scrollToTop', withObject: nil, afterDelay: 0.2)
      growlMessages(messages)
      @lastGrowled = [@lastGrowled, messages.first.recordId].max
      NSUserDefaults.standardUserDefaults.setInteger(@lastGrowled, forKey: LAST_GROWLED_KEY)
    end

    @loadingView.mbHide
    @newMessageButton.mbEnable
    @dashboardButton.mbEnable
    @spinner.stopAnimation(self)
  end

  def dashboardUpdateFailed(notification)
    error = notification.userInfo["error"]
    if error.blipTimeoutError?
      if OBMessage.list.empty?
        obprint "MainWindowController: first dashboard update failed, retrying"
        @blip.dashboardMonitor.performSelector('forceUpdate', withObject: nil, afterDelay: 10.0)
      else
        obprint "MainWindowController: dashboard update failed, ignoring"
        @spinner.stopAnimation(self)
      end
    else
      @loadingView.mbHide
      @spinner.stopAnimation(self)
      displayLoadingError(error)
    end
  end

  def newMessagePressed(sender)
    openNewMessageWindow
  end

  def quoteActionSelected(sender)
    message = sender.menu.delegate.representedObject
    openNewMessageWindow("#{message.url} ")
  end

  def replyActionSelected(sender)
    message = sender.menu.delegate.representedObject
    symbol = (message.messageType == OBPrivateMessage) ? ">>" : ">"
    openNewMessageWindow("#{symbol}#{message.user.login}: ")
  end

  def showPictureActionSelected(sender)
    message = sender.menu.delegate.representedObject
    BrowserController.openAttachedPicture(message)
  end

  def openNewMessageWindow(text = nil)
    if @newMessageDialog.nil?
      @newMessageDialog = NewMessageDialogController.alloc.initWithMainWindow(self, text: text)
    end
    @newMessageDialog.showWindow(self)
  end

  def newMessageDialogClosed
    @newMessageDialog = nil
  end

  def dashboardPressed(sender)
    BrowserController.openDashboard
  end

  def displayLoadingError(error)
    mbShowAlertSheet("Error", error.localizedDescription)
  end

  def growlMessages(messages)
    myLogin = @blip.account.username

    # don't growl own messages, or those that have been growled before
    growlableMessages = messages.find_all { |m| m.user.login != myLogin && m.recordId > @lastGrowled }

    if growlableMessages.count > GROWL_LIMIT + 1
      growlableMessages.first(GROWL_LIMIT).each { |m| sendGrowlNotification(m) }
      sendGroupedGrowlNotification(growlableMessages[GROWL_LIMIT..-1])
    else
      growlableMessages.each { |m| sendGrowlNotification(m) }
    end
  end

  def sendGroupedGrowlNotification(messages)
    users = messages.map(&:user).map(&:login).sort.uniq.join(", ")
    GrowlApplicationBridge.notifyWithTitle(
      "… and #{messages.count} other updates",
      description: "From: #{users}",
      notificationName: "Status group received",
      iconData: nil,
      priority: 0,
      isSticky: false,
      clickContext: nil
    )
  end

  def sendGrowlNotification(message)
    growlType = (message.messageType == OBStatusMessage) ? "Status received" : "Directed message received"
    GrowlApplicationBridge.notifyWithTitle(
      message.senderAndRecipient,
      description: message.processedBody,
      notificationName: growlType,
      iconData: message.user.avatarData,
      priority: 0,
      isSticky: false,
      clickContext: nil
    )
  end

end
