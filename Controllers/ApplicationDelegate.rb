# -------------------------------------------------------
# ApplicationDelegate.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under Eclipse Public License v1.0
# -------------------------------------------------------

class ApplicationDelegate

  LOGGING_KEY = "objectiveblip.forceLogging"
  BLIP_TIMEOUT_DELAY = 5.0
  FAILED_CONNECTION_DELAY = 15.0
  TOOLTIP_DELAY = 1.1

  # initialization

  def awakeFromNib
    GrowlApplicationBridge.growlDelegate = ""
    FilesController.clearPicturesCache

    initConnector
    initMidnightTimer
    initTooltips

    if @blip.account.hasCredentials
      createMainWindow
      restoreMainWindow
      authenticate
    else
      showLoginWindow
    end
  end

  def initConnector
    @blip = OBConnector.sharedConnector = OBConnector.new
    @blip.userAgent = userAgentString
    @blip.autoLoadAvatars = true
    @blip.initialDashboardFetch = @blip.pageSize = 30
    @blip.account = OBAccount.accountFromSettings || OBAccount.new
    @blip.loggingEnabled = true if NSUserDefaults.standardUserDefaults.boolForKey(LOGGING_KEY)
    # enable logging with: defaults write net.psionides.MacBlip 'objectiveblip.forceLogging' -bool YES
  end

  def authenticate
    @blip.authenticateRequest.sendFor(self, callback: 'authenticationSuccessful')
  end

  def createMainWindow
    @mainWindowController ||= MainWindowController.new
  end

  def restoreMainWindow
    if @mainWindowController && !@mainWindowController.window.visible?
      @mainWindowController.showWindow(self)
      # TODO @mainWindowController.makeKeyWindow
    end
  end

  def showLoginWindow
    @loginDialog = LoginWindowController.new
    @loginDialog.showWindow(self)
    mbObserve(@loginDialog, :authenticationSuccessful, :firstLoginSuccessful)
  end

  def deleteMainWindow
    if @mainWindowController
    # TODO: recreating main window causes crashes, probably a bug in MacRuby related to KVO
    #   @mainWindowController.window.releasedWhenClosed = true
      @mainWindowController.window.close
    #   @mainWindowController = nil
    end
  end

  def userAgentString
    info = NSBundle.mainBundle.infoDictionary
    appName = info['CFBundleName']
    appVersion = info['CFBundleVersion']
    "#{appName}/#{appVersion}"
  end

  def applicationDockMenu(app)
    menu = NSMenu.alloc.initWithTitle ""
    menu.addItemWithTitle(tr("New message..."), action: 'newMessagePressed:', keyEquivalent: '')
    menu
  end

  def applicationShouldHandleReopen(app, hasVisibleWindows: hasWindows)
    restoreMainWindow
    false
  end

  def initTooltips
    # changing settings in a private class - Steve will probably send a hitman after me... :(
    if defined?(NSToolTipManager) && NSToolTipManager && NSToolTipManager.respond_to?('sharedToolTipManager')
      manager = NSToolTipManager.sharedToolTipManager
      if manager && manager.respond_to?('setInitialToolTipDelay:')
        manager.setInitialToolTipDelay(TOOLTIP_DELAY)
      end
    end
  end

  def initMidnightTimer
    nextMidnight = NSDate.psDaysFromNow(1).psMidnight
    @midnightTimer = NSTimer.alloc.initWithFireDate(nextMidnight,
      interval: 86400,
      target: self,
      selector: 'onMidnight',
      userInfo: nil,
      repeats: true
    )
    NSRunLoop.mainRunLoop.addTimer(@midnightTimer, forMode: NSDefaultRunLoopMode)
  end

  def onMidnight
    # refresh the dates in the list (those from tomorrow will have day name appended to them)
    @mainWindowController.listView.setNeedsDisplay(true)

    # force resizing of date labels
    @mainWindowController.listView.viewDidEndLiveResize
  end

  # authentication

  def firstLoginSuccessful
    mbStopObserving(@loginDialog, :authenticationSuccessful)
    @loginDialog.close
    @blip.account.save
    createMainWindow
    authenticationSuccessful
  end

  def authenticationSuccessful
    restoreMainWindow
    enableIncomingServices
    @mainWindowController.hideNoticeBars
    @blip.dashboardMonitor.interval = 60
    @blip.dashboardMonitor.startMonitoring
  end

  def enableIncomingServices
    NSApp.servicesProvider = self
  end

  def disableIncomingServices
    NSApp.servicesProvider = nil
  end

  def authenticationFailedInRequest(request)
    deleteMainWindow
    showLoginWindow
    @blip.account.clear
  end

  def requestFailed(request, withError: error)
    @blip.log "ApplicationDelegate: got error: #{error.domain}, #{error.code}, #{error.localizedDescription}"
    if error.blipTimeoutError?
      # retry until it works
      @blip.log "timeout problem, retrying"
      @mainWindowController.showWarningBar
      self.performSelector('authenticate', withObject: nil, afterDelay: BLIP_TIMEOUT_DELAY)
    else
      # retry until it works, but wait longer between requests
      @blip.log "connection problem, retrying"
      @mainWindowController.showErrorBar
      self.performSelector('authenticate', withObject: nil, afterDelay: FAILED_CONNECTION_DELAY)
    end
  end


  # menu actions

  def forceDashboardUpdate(sender)
    @blip.dashboardMonitor.requestManualUpdate if @blip.account.loggedIn?
  end

  def logoutPressed(sender)
    @blip.account.clear
    @blip.dashboardMonitor.stopMonitoring

    @mainWindowController.releaseWindow
    @mainWindowController = nil

    NSUserDefaults.standardUserDefaults.removeObjectForKey(MainWindowController::LAST_GROWLED_KEY)
    FilesController.clearPicturesCache
    OBMessage.reset
    disableIncomingServices
    initConnector

    showLoginWindow
  end

  def openDashboard(sender)
    BrowserController.openDashboard
  end

  def newMessagePressed(sender)
    NSApp.activateIgnoringOtherApps(true)
    createMainWindow
    @mainWindowController.performSelector('openNewMessageWindow', withObject: nil, afterDelay: 0.01)
  end

  # system service

  def newMessageWithTextFromService(pasteboard, userData: data, error: error)
    return unless pasteboard.canReadObjectForClasses([NSString], options: {})

    text = pasteboard.stringForType(NSPasteboardTypeString)
    unless text.blank?
      NSApp.activateIgnoringOtherApps(true)
      createMainWindow
      @mainWindowController.performSelector('openNewMessageWindow:', withObject: text, afterDelay: 0.01)
    end
  end

end
