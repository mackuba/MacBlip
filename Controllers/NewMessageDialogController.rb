# -------------------------------------------------------
# NewMessageDialogController.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class NewMessageDialogController < NSWindowController

  MAX_CHARS = 160

  attr_accessor :counterLabel, :sendButton, :shortenButton, :textField, :sendSpinner, :shortenSpinner

  def initWithMainWindowController(mainWindowController, text: text)
    initWithWindowNibName "NewMessageDialog"

    @mainWindowController = mainWindowController
    @blip = OBConnector.sharedConnector
    @gray = NSColor.colorWithDeviceRed 0.2, green: 0.2, blue: 0.2, alpha: 1.0
    @red = NSColor.colorWithDeviceRed 0.67, green: 0, blue: 0, alpha: 1.0
    @sent = false
    @edited = false
    @text = text || ""

    self.shouldCascadeWindows = false
    positionWindowOnSameScreen

    self
  end

  def positionWindowOnSameScreen
    if window.screen != @mainWindowController.window.screen
      screenFrame = @mainWindowController.window.screen.visibleFrame
      windowSize = window.frame.size
      window.setFrame(NSMakeRect(
        (screenFrame.size.width - windowSize.width) / 2.0 + screenFrame.origin.x,
        screenFrame.size.height * 0.66 - windowSize.height / 2.0 + screenFrame.origin.y,
        windowSize.width,
        windowSize.height
      ), display: false)
    end
  end

  def windowDidLoad
    window.setContentBorderThickness(32, forEdge: NSMinYEdge)
    window.movableByWindowBackground = true
    window.delegate = self
    mbObserve(textField, NSControlTextDidChangeNotification, :textEdited)
    textField.stringValue = @text
    refreshCounter
  end

  def showWindow(sender)
    wasVisible = self.window.isVisible
    super
    textField.psUnselectText unless wasVisible
  end

  def windowShouldClose(notification)
    if @edited && !@sent
      alertWindow = NSAlert.alertWithMessageText(tr("Are you sure?"),
        defaultButton: tr("Close window"),
        alternateButton: tr("Cancel"),
        otherButton: nil,
        informativeTextWithFormat: tr("You haven't sent that message yet.")
      )
      alertWindow.beginSheetModalForWindow(self.window,
        modalDelegate: self,
        didEndSelector: 'confirmationWindowClosed:result:context:',
        contextInfo: nil
      )
      false
    else
      closeWindow
      true
    end
  end

  def closeWindow
    mbStopObserving(textField, NSControlTextDidChangeNotification)
    @mainWindowController.newMessageDialogClosed
    window.close
  end

  def confirmationWindowClosed(alert, result: result, context: context)
    if result == NSAlertDefaultReturn
      @sent = true
      closeWindow
    end
  end

  def textEdited
    @edited = true
    refreshCounter
  end

  def refreshCounter
    text = textField.stringValue
    counterLabel.stringValue = "#{text.length} / #{MAX_CHARS}"
    counterLabel.textColor = (text.length <= MAX_CHARS) ? @gray : @red
    sendButton.enabled = (text.length > 0 && text.length <= MAX_CHARS)
  end

  def sendPressed(sender)
    enterRequestMode
    message = textField.stringValue
    @blip.sendMessageRequest(message).sendFor(self)
  end

  def messageSent
    @sent = true
    closeWindow
    @blip.dashboardMonitor.performSelector('requestManualUpdate', withObject: nil, afterDelay: 1)
  end

  def shortenLinksPressed(sender)
    links = textField.stringValue.scan(/((http|https|ftp):\/\/[^\s]+)/).map(&:first)
    if links.length > 0
      #enterRequestMode
      p links
    end
  end

  def enterRequestMode
    sendButton.psDisable
    shortenButton.psDisable
    textField.psDisable
    sendSpinner.startAnimation(self)
  end

  def leaveRequestMode
    sendButton.psEnable
    shortenButton.psEnable
    textField.psEnable
    sendSpinner.stopAnimation(self)
  end

  def authenticationFailed
    leaveRequestMode
    message = tr("Invalid username or password. Try to restart MacBlip and log in again…")
    window.psShowAlertSheetWithTitle(tr("Error"), message: message)
  end

  def requestFailedWithError(error)
    leaveRequestMode
    window.psShowAlertSheetWithTitle(tr("Error"), message: error.localizedDescription)
  end

end
