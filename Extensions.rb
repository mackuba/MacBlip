# -------------------------------------------------------
# Extensions.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class NilClass
  def blank?
    true
  end
end

class NSView
  def mbHide
    self.hidden = true
  end

  def mbShow
    self.hidden = false
  end
end

class NSControl
  def mbEnable
    self.enabled = true
  end

  def mbDisable
    self.enabled = false
  end
end

class NSObject
  def mbCatcher
    begin
      yield
    rescue Exception => e
      puts e.backtrace
      raise
    end
  end

  def mbObserve(sender, notification, selector = nil)
    selector ||= notification
    NSNotificationCenter.defaultCenter.addObserver(self, selector: selector, name: notification.to_s, object: sender)
  end

  def mbStopObserving(sender, notification)
    NSNotificationCenter.defaultCenter.removeObserver(self, name: notification, object: sender)
  end

  def mbNotify(notification)
    NSNotificationCenter.defaultCenter.postNotificationName(notification.to_s, object: self)
  end
end

class NSString
  def blank?
    self.to_s.gsub(/\s+/, '') == ""
  end
end

class NSWindowController
  def mbShowAlertSheet(title, message)
    alertWindow = NSAlert.alertWithMessageText(title,
      defaultButton: "OK",
      alternateButton: nil,
      otherButton: nil,
      informativeTextWithFormat: message
    )
    alertWindow.beginSheetModalForWindow(self.window, modalDelegate: nil, didEndSelector: nil, contextInfo: nil)
  end
end
