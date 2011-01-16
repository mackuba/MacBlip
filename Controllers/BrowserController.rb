# -------------------------------------------------------
# BrowserController.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under Eclipse Public License v1.0
# -------------------------------------------------------

class BrowserController
  class << self

    def openURL(url)
      NSWorkspace.sharedWorkspace.openURL(NSURL.URLWithString(url))
    end

    def openPage(path)
      openURL(BLIP_WWW_HOST + path)
    end

    def openDashboard
      openUsersDashboard(OBConnector.sharedConnector.account.username)
    end

    def openUsersDashboard(username)
      openPage "/users/#{username}/dashboard"
    end

    def openAttachedPicture(message)
      if message.pictures && message.pictures.first
        openURL(message.pictures.first['url'])
      end
    end

  end
end
