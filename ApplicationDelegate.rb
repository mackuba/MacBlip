# -------------------------------------------------------
# ApplicationDelegate.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class ApplicationDelegate

  USERNAME_KEY = "account.username"

  # initialization

  def awakeFromNib
    GrowlApplicationBridge.growlDelegate = ""
    @blip = OBConnector.sharedConnector
    @blip.userAgent = userAgentString
    @blip.autoLoadAvatars = true
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

  def applicationWillBecomeActive(notification)
    restoreMainWindow
  end

  def applicationShouldHandleReopen(app, hasVisibleWindows: hasWindows)
    restoreMainWindow
    false
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
    # TODO: handle timeouts (retry)
    @mainWindow.displayLoadingError(error)
  end


  # menu actions

  def forceDashboardUpdate(sender)
    @blip.dashboardMonitor.forceUpdate if @blip.account.loggedIn?
  end

end
