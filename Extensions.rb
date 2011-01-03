# -------------------------------------------------------
# Extensions.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

module Kernel
  def tr(text)
    NSBundle.mainBundle.localizedStringForKey(text, value: text, table: nil)
  end
end

class NilClass
  def blank?
    true
  end
end

class NSError
  def blipTimeoutError?
    (self.domain == "ASIHTTPRequestErrorDomain" && self.code == ASIRequestTimedOutErrorType) ||
    (self.domain == BLIP_ERROR_DOMAIN && self.code == BLIP_ERROR_MR_OPONKA)
  end
end

class NSObject
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
