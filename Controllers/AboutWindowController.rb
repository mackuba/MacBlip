# -------------------------------------------------------
# AboutWindowController.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class AboutWindowController < NSWindowController

  attr_accessor :versionLabel

  def init
    initWithWindowNibName "AboutWindow"
    self
  end

  def windowDidLoad
    version = NSBundle.mainBundle.infoDictionary['CFBundleVersion']
    versionLabel.stringValue = "#{tr('Version')} #{version}"
  end

end
