# -------------------------------------------------------
# ApplicationDelegate.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class ApplicationDelegate

  def awakeFromNib
    @mainWindow = MainWindowController.new
    @mainWindow.showWindow(self)

    blip = OBConnector.sharedConnector
    blip.account.username = "..."
    blip.account.password = "..."
    blip.authenticateRequest.sendFor(self)
  end

  def restoreMainWindow
    @mainWindow.showWindow(self) unless @mainWindow.window.isVisible
  end

  def applicationWillBecomeActive(notification)
    restoreMainWindow
  end

  def applicationShouldHandleReopen(app, hasVisibleWindows: hasWindows)
    restoreMainWindow
    false
  end

  def authenticationSuccessful
    OBConnector.sharedConnector.dashboardMonitor.startMonitoring
  end

  def requestFailedWithError(error)
    p error.localizedDescription
  end

end
