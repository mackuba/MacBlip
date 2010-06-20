# -------------------------------------------------------
# NewMessageDialogController.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class NewMessageDialogController < NSWindowController

  MAX_CHARS = 160

  attr_accessor :counterLabel, :sendButton, :textField, :spinner

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
    textField.psUnselectText
    refreshCounter
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
    sendButton.psDisable
    textField.psDisable
    spinner.startAnimation(self)

    message = textField.stringValue
    @blip.sendMessageRequest(message).sendFor(self)
  end

  def messageSent
    @sent = true
    closeWindow
    @blip.dashboardMonitor.performSelector('requestManualUpdate', withObject: nil, afterDelay: 1)
  end

  def requestFailedWithError(error)
    sendButton.psEnable
    textField.psEnable
    spinner.stopAnimation(self)
    psShowAlertSheet(tr("Error"), error.localizedDescription)
  end

end