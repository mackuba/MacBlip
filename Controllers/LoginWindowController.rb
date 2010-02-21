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
    [usernameField, passwordField, loginButton].each(&:mbDisable)
    spinner.startAnimation(self)
    connector = OBConnector.sharedConnector
    connector.account.username = usernameField.stringValue
    connector.account.password = passwordField.stringValue
    connector.authenticateRequest.sendFor(self)
  end

  def reenableForm
    [usernameField, passwordField, loginButton].each(&:mbEnable)
    spinner.stopAnimation(self)
    window.makeFirstResponder(usernameField)
  end

  def authenticationSuccessful
    mbNotify :authenticationSuccessful
  end

  def authenticationFailed
    reenableForm
    mbShowAlertSheet("Error", "Login or password is incorrect")
  end

  def requestFailedWithError(error)
    reenableForm
    if error.domain == BLIP_ERROR_DOMAIN && error.code == BLIP_ERROR_MR_OPONKA
      mbShowAlertSheet("Error", "Mr Oponka says that unfortunately the Blip server is overloaded at the moment.")
    else
      mbShowAlertSheet("Error", error.localizedDescription)
    end
  end

end
