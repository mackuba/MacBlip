# -------------------------------------------------------
# MainWindowController.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under Eclipse Public License v1.0
# -------------------------------------------------------

class MainWindowController < NSWindowController

  LAST_GROWLED_KEY = "growl.lastGrowledMessageId"
  GROWL_LIMIT = 5

  attr_accessor :listView, :scrollView, :spinner, :loadingView, :newMessageButton, :dashboardButton

  def init
    initWithWindowNibName "MainWindow"
    @lastGrowled = NSUserDefaults.standardUserDefaults.integerForKey(LAST_GROWLED_KEY) || 0
    @firstLoad = true
    self
  end

  def windowDidLoad
    @blip = OBConnector.sharedConnector
    mbObserve(@blip.dashboardMonitor, OBDashboardUpdatedNotification, 'dashboardUpdated:')
    mbObserve(@blip.dashboardMonitor, OBDashboardUpdateFailedNotification, 'dashboardUpdateFailed:')
    mbObserve(@blip.dashboardMonitor, OBDashboardAuthFailedNotification, 'dashboardAuthFailed')
    mbObserve(@blip.dashboardMonitor, OBDashboardWillUpdateNotification, :dashboardWillUpdate)

    window.setContentBorderThickness(32, forEdge: CGRectMinYEdge)
    window.movableByWindowBackground = true

    # sort descriptors have to be set *before* the content is bound to a list with items in it
    @listView.sortDescriptors = [NSSortDescriptor.sortDescriptorWithKey('date', ascending: true)]
    # the order is actually descending, but listView is not flipped so it counts Y coordinate from bottom... o_O
    @listView.bind "content", toObject: OBMessage, withKeyPath: "list", options: nil
    @listView.topPadding = 5
    @listView.bottomPadding = 5
  end

  def releaseWindow
    @listView.unbind "content"
    @listView.releaseResources
    mbStopObserving(@blip.dashboardMonitor, OBDashboardUpdatedNotification)
    mbStopObserving(@blip.dashboardMonitor, OBDashboardUpdateFailedNotification)
    mbStopObserving(@blip.dashboardMonitor, OBDashboardAuthFailedNotification)
    mbStopObserving(@blip.dashboardMonitor, OBDashboardWillUpdateNotification)
    self.window.close
    self.window = nil
  end

  def warningBar
    if @warningBar.nil?
      @warningBar = WarningBar.alloc.initWithType(:warning)
      @warningBar.text = tr("Blip server is currently overloaded.")
      window.contentView.addSubview(@warningBar)
    end
    @warningBar
  end

  def errorBar
    if @errorBar.nil?
      @errorBar = WarningBar.alloc.initWithType(:error)
      @errorBar.text = tr("No connection to Blip server.")
      window.contentView.addSubview(@errorBar)
    end
    @errorBar
  end

  def showWarningBar
    unless warningBar.displayed
      if errorBar.displayed
        warningBar.removeFromSuperview
        window.contentView.addSubview(warningBar)
        errorBar.slideOut
      end
      @scrollView.contentView.copiesOnScroll = false
      warningBar.slideIn
    end
  end

  def showErrorBar
    unless errorBar.displayed
      if warningBar.displayed
        errorBar.removeFromSuperview
        window.contentView.addSubview(errorBar)
        warningBar.slideOut
      end
      @scrollView.contentView.copiesOnScroll = false
      errorBar.slideIn
    end
  end

  def hideNoticeBars
    [@warningBar, @errorBar].compact.each { |b| b.slideOut if b.displayed }
    @scrollView.contentView.copiesOnScroll = true
  end

  def windowDidResize(notification)
    @listView.viewDidEndLiveResize unless window.inLiveResize
  end

  def dashboardWillUpdate
    @spinner.startAnimation(self) if @loadingView.isHidden
  end

  def scrollToTop
    scrollView.verticalScroller.floatValue = 0
    scrollView.contentView.scrollToPoint(NSZeroPoint)
  end

  def dashboardUpdated(notification)
    messages = notification.userInfo["messages"]

    if messages && messages.count > 0
      self.performSelector('scrollToTop', withObject: nil, afterDelay: 0.2) if @firstLoad

      messagesWithPictures = messages.find_all { |m| m.hasPicture }
      messagesWithPictures.each { |m| @blip.loadPictureRequest(m).send }

      messages.each do |message|
        message.body.scan(%r{http://rdir.pl/\w+}) do |link|
          expandLink(link, message)
        end
      end

      growlMessages(messages)
      @lastGrowled = [@lastGrowled, messages.first.recordIdValue].max
      NSUserDefaults.standardUserDefaults.setInteger(@lastGrowled, forKey: LAST_GROWLED_KEY)
    end

    @loadingView.performSelector(:psHide, withObject: nil, afterDelay: 0.1)
    @newMessageButton.psEnable
    @dashboardButton.psEnable
    @spinner.stopAnimation(self)
    @firstLoad = false
    hideNoticeBars
  end

  def dashboardUpdateFailed(notification)
    error = notification.userInfo["error"]
    if error.blipTimeoutError?
      if OBMessage.list.empty?
        @blip.log "MainWindowController: first dashboard update failed, retrying"
        @blip.dashboardMonitor.performSelector('forceUpdate',
          withObject: nil, afterDelay: ApplicationDelegate::BLIP_TIMEOUT_DELAY)
      else
        @blip.log "MainWindowController: dashboard update failed, ignoring"
        showWarningBar
        @spinner.stopAnimation(self)
      end
    else
      showErrorBar
      @spinner.stopAnimation(self) unless OBMessage.list.empty?
    end
  end

  def dashboardAuthFailed
    if OBMessage.list.empty?
      NSApp.delegate.authenticationFailedInRequest(nil)
    else
      @spinner.stopAnimation(self)
      @loadingView.psHide
      window.psShowAlertSheetWithTitle("Error",
        message: "Invalid username or password. Try to restart MacBlip and log in again…")
    end
  end

  def requestFailed(request, withError: error)
    # link expand request failed - ignore
  end

  def authenticationFailedInRequest(request)
    # link expand request failed - ignore
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

  def replyWithQuoteActionSelected(sender)
    message = sender.menu.delegate.representedObject
    symbol = (message.messageType == OBPrivateMessage) ? ">>" : ">"
    openNewMessageWindow("#{symbol}#{message.user.login}: #{message.url} ")
  end

  def showPictureActionSelected(sender)
    message = sender.menu.delegate.representedObject
    BrowserController.openAttachedPicture(message)
  end

  def openNewMessageWindow(text = nil)
    if @newMessageDialog.nil?
      @newMessageDialog = NewMessageDialogController.alloc.initWithMainWindowController(self, text: text)
    end
    @newMessageDialog.showWindow(self)
  end

  def newMessageDialogClosed
    @newMessageDialog = nil
  end

  def dashboardPressed(sender)
    BrowserController.openDashboard
  end

  def expandLink(link, message)
    unless LinkExpander.sharedLinkExpander.expand(link)
      shortLink = OBShortLink.shortLinkWithRdirUrl(link)
      @blip.expandLinkRequest(shortLink, inMessage: message).sendFor(self, callback: 'linkExpanded:') if shortLink
    end
  end

  def linkExpanded(data)
    shortlink = data['shortlink']
    message = data['message']
    LinkExpander.sharedLinkExpander.register(shortlink.url, shortlink.originalLink)
    message.refreshBody
  end

  def growlMessages(messages)
    myLogin = @blip.account.username

    # don't growl own messages, or those that have been growled before
    growlableMessages = messages.find_all { |m| m.user.login != myLogin && m.recordIdValue > @lastGrowled }

    if growlableMessages.count > GROWL_LIMIT + 1
      growlableMessages.first(GROWL_LIMIT).each { |m| sendGrowlNotification(m) }
      sendGroupedGrowlNotification(growlableMessages[GROWL_LIMIT..-1])
    else
      growlableMessages.each { |m| sendGrowlNotification(m) }
    end
  end

  def sendGroupedGrowlNotification(messages)
    users = messages.map(&:user).map(&:login).sort.uniq.join(", ")
    last_digit = messages.count % 10
    template = tr((last_digit >= 2 && last_digit <= 4) ? "AND_2_TO_4_OTHER_UPDATES" : "AND_5_OR_MORE_OTHER_UPDATES")
    GrowlApplicationBridge.notifyWithTitle(
      template % messages.count,
      description: "#{tr('From:')} #{users}",
      notificationName: "Status group received",
      iconData: nil,
      priority: 0,
      isSticky: false,
      clickContext: nil
    )
  end

  def sendGrowlNotification(message)
    growlType = case message.messageType
      when OBPrivateMessage, OBDirectedMessage then "Directed message received"
      else "Status received"
    end
    GrowlApplicationBridge.notifyWithTitle(
      message.senderAndRecipient,
      description: message.bodyForGrowl,
      notificationName: growlType,
      iconData: message.user.fixedAvatarData,
      priority: 0,
      isSticky: false,
      clickContext: nil
    )
  end

  def displayImageInQuickLook(message)
    return unless message.hasPictureData
    @messageInQuickLook = message
    panel = QLPreviewPanel.sharedPreviewPanel
    if panel.isVisible
      panel.orderOut(self)
      panel.reloadData
      panel.performSelector('makeKeyAndOrderFront:', withObject: self, afterDelay: 0.25)
    else
      panel.makeKeyAndOrderFront(self)
    end
  end

  def acceptsPreviewPanelControl(panel)
    true
  end

  def beginPreviewPanelControl(panel)
    panel.dataSource = self
  end

  def endPreviewPanelControl(panel)
  end

  def numberOfPreviewItemsInPreviewPanel(panel)
    1
  end

  def previewPanel(panel, previewItemAtIndex: index)
    QuickLookPicture.new(@messageInQuickLook.pictures.first)
  end

end
