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

end
