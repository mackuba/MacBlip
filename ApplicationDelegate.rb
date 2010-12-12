# -------------------------------------------------------
# ApplicationDelegate.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class ApplicationDelegate

  USERNAME_KEY = "account.username"
  LOGGING_KEY = "objectiveblip.forceLogging"
  BLIP_TIMEOUT_DELAY = 5.0
  FAILED_CONNECTION_DELAY = 15.0
  TOOLTIP_DELAY = 1.1

  # initialization

  def awakeFromNib
    GrowlApplicationBridge.growlDelegate = ""
    FilesController.clearPicturesCache
    @blip = OBConnector.sharedConnector
    @blip.userAgent = userAgentString
    @blip.autoLoadAvatars = true
    @blip.initialDashboardFetch = 30
    initMidnightTimer
    initTooltips

    # enable logging with: defaults write net.psionides.MacBlip 'objectiveblip.forceLogging' -bool YES
    OBConnector.loggingEnabled = true if NSUserDefaults.standardUserDefaults.boolForKey(LOGGING_KEY)

    loadLoginAndPassword

    if @blip.account.hasCredentials
      createMainWindow
      restoreMainWindow
      @blip.authenticateRequest.sendFor(self)
    else
      showLoginWindow
    end
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


  # settings

  def loadLoginAndPassword
    user = @blip.account
    user.username = NSUserDefaults.standardUserDefaults.objectForKey(USERNAME_KEY)
    user.password = SDKeychain.securePasswordForIdentifier(user.username) if user.username
  end

  def saveLoginAndPassword
    SDKeychain.setSecurePassword(@blip.account.password, forIdentifier: @blip.account.username)
    NSUserDefaults.standardUserDefaults.setObject(@blip.account.username, forKey: USERNAME_KEY)
  end

  def clearLoginAndPassword
    SDKeychain.setSecurePassword(nil, forIdentifier: @blip.account.username)
    NSUserDefaults.standardUserDefaults.removeObjectForKey(USERNAME_KEY)
    @blip.account.username = nil
    @blip.account.password = nil
  end


  # authentication

  def firstLoginSuccessful
    mbStopObserving(@loginDialog, :authenticationSuccessful)
    @loginDialog.close
    saveLoginAndPassword
    createMainWindow
    authenticationSuccessful
  end

  def authenticationSuccessful
    restoreMainWindow
    @mainWindowController.hideNoticeBars
    @blip.dashboardMonitor.interval = 60
    @blip.dashboardMonitor.startMonitoring
  end

  def authenticationFailed
    deleteMainWindow
    showLoginWindow
    clearLoginAndPassword
  end

  def requestFailedWithError(error)
    obprint "ApplicationDelegate: got error: #{error.domain}, #{error.code}, #{error.localizedDescription}"
    if error.blipTimeoutError?
      # retry until it works
      obprint "timeout problem, retrying"
      @mainWindowController.showWarningBar
      @blip.authenticateRequest.performSelector('sendFor:', withObject: self, afterDelay: BLIP_TIMEOUT_DELAY)
    else
      # retry until it works, but wait longer between requests
      obprint "connection problem, retrying"
      @mainWindowController.showErrorBar
      @blip.authenticateRequest.performSelector('sendFor:', withObject: self, afterDelay: FAILED_CONNECTION_DELAY)
    end
  end


  # menu actions

  def forceDashboardUpdate(sender)
    @blip.dashboardMonitor.requestManualUpdate if @blip.account.loggedIn?
  end

  def openDashboard(sender)
    BrowserController.openDashboard
  end

  def newMessagePressed(sender)
    NSApp.activateIgnoringOtherApps(true)
    createMainWindow
    @mainWindowController.performSelector('openNewMessageWindow', withObject: nil, afterDelay: 0.01)
  end

end
