# -------------------------------------------------------
# BrowserController.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class BrowserController
  class << self

    def openURL(url)
      NSWorkspace.sharedWorkspace.openURL(NSURL.URLWithString(url))
    end

    def openPage(path)
      openURL("http://blip.pl#{path}")
    end

    def openDashboard
      openPage "/dashboard"
    end

    def openUsersDashboard(username)
      openPage "/users/#{username}/dashboard"
    end

  end
end
