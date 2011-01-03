# -------------------------------------------------------
# LoginWindowController.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class LoginWindowController < NSWindowController

  attr_accessor :usernameField, :passwordField, :loginButton, :spinner

  def init
    initWithWindowNibName "LoginWindow"
    self
  end

  def windowDidLoad
    usernameField.objectValue = NSUserName()
  end

  def usernameEntered(sender)
    window.makeFirstResponder(passwordField) unless usernameField.stringValue.blank?
  end

  def passwordEntered(sender)
    loginPressed(self) unless usernameField.stringValue.blank? || passwordField.stringValue.blank?
  end

  def loginPressed(sender)
    return if usernameField.stringValue.blank? || passwordField.stringValue.blank?
    [usernameField, passwordField, loginButton].each(&:psDisable)
    spinner.startAnimation(self)
    connector = OBConnector.sharedConnector
    connector.account.username = usernameField.stringValue
    connector.account.password = passwordField.stringValue
    authenticate
  end

  def authenticate
    OBConnector.sharedConnector.authenticateRequest.sendFor(self, callback: 'authenticationSuccessful')
  end

  def reenableForm
    [usernameField, passwordField, loginButton].each(&:psEnable)
    spinner.stopAnimation(self)
    window.makeFirstResponder(usernameField)
  end

  def authenticationSuccessful
    mbNotify :authenticationSuccessful
  end

  def authenticationFailedInRequest(request)
    reenableForm
    window.psShowAlertSheetWithTitle(tr("Error"), message: tr("Login or password is incorrect"))
  end

  def requestFailed(request, withError: error)
    if error.blipTimeoutError?
      OBConnector.sharedConnector.log "LoginWindowController: timeout problem, retrying"
      self.performSelector('authenticate', withObject: nil, afterDelay: ApplicationDelegate::BLIP_TIMEOUT_DELAY)
    else
      reenableForm
      window.psShowAlertSheetWithTitle(tr("Error"), message: error.localizedDescription)
    end
  end

end
