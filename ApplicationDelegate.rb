# -------------------------------------------------------
# ApplicationDelegate.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class ApplicationDelegate

  USERNAME_KEY = "account.username"
  LOGGING_KEY = "objectiveblip.forceLogging"

  # initialization

  def awakeFromNib
    GrowlApplicationBridge.growlDelegate = ""
    @blip = OBConnector.sharedConnector
    @blip.userAgent = userAgentString
    @blip.autoLoadAvatars = true
    @blip.initialDashboardFetch = 30
    initMidnightTimer

    # enable logging with: defaults write net.psionides.MacBlip 'objectiveblip.forceLogging' -bool YES
    OBConnector.loggingEnabled = true if NSUserDefaults.standardUserDefaults.boolForKey(LOGGING_KEY)

    loadLoginAndPassword

    if @blip.account.hasCredentials
      createMainWindow
      restoreMainWindow
      @blip.authenticateRequest.sendFor(self)
    else
      @loginDialog = LoginWindowController.new
      @loginDialog.showWindow(self)
      mbObserve(@loginDialog, :authenticationSuccessful, :firstLoginSuccessful)
    end
  end

  def createMainWindow
    @mainWindow ||= MainWindowController.new
  end

  def restoreMainWindow
    if @mainWindow && !@mainWindow.window.visible?
      @mainWindow.showWindow(self)
      # TODO @mainWindow.makeKeyWindow
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

  def initMidnightTimer
    calendar = NSCalendar.currentCalendar
    fields = calendar.components(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit, fromDate: NSDate.date)
    thisMidnight = calendar.dateFromComponents(fields)
    interval = NSDateComponents.alloc.init
    interval.day = 1
    nextMidnight = calendar.dateByAddingComponents(interval, toDate: thisMidnight, options: 0)

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
    @mainWindow.listView.setNeedsDisplay(true)

    # force resizing of date labels
    @mainWindow.listView.viewDidEndLiveResize
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


  # authentication

  def firstLoginSuccessful
    mbStopObserving(@loginDialog, :authenticationSuccessful)
    @loginDialog.close
    saveLoginAndPassword
    authenticationSuccessful
  end

  def authenticationSuccessful
    createMainWindow
    restoreMainWindow
    @blip.dashboardMonitor.interval = 60
    @blip.dashboardMonitor.startMonitoring
  end

  def requestFailedWithError(error)
    obprint "ApplicationDelegate: got error: #{error.domain}, #{error.code}, #{error.localizedDescription}"
    if error.blipTimeoutError?
      # retry until it works
      obprint "timeout problem, retrying"
      @blip.authenticateRequest.performSelector('sendFor:', withObject: self, afterDelay: 10.0)
    else
      @mainWindow.displayLoadingError(error)
    end
  end


  # menu actions

  def forceDashboardUpdate(sender)
    @blip.dashboardMonitor.requestManualUpdate if @blip.account.loggedIn?
  end

  def showAboutWindow(sender)
    @aboutWindow ||= AboutWindowController.new
    @aboutWindow.showWindow(self)
  end

  def openDashboard(sender)
    BrowserController.openDashboard
  end

  def newMessagePressed(sender)
    NSApp.activateIgnoringOtherApps(true)
    createMainWindow
    @mainWindow.performSelector('openNewMessageWindow', withObject: nil, afterDelay: 0.01)
  end

end
