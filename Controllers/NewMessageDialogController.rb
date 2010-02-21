# -------------------------------------------------------
# NewMessageDialogController.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class NewMessageDialogController < NSWindowController

  MAX_CHARS = 160

  attr_accessor :counterLabel, :sendButton, :textField, :spinner

  def initWithMainWindow(mainWindow)
    initWithWindowNibName "NewMessageDialog"
    @mainWindow = mainWindow
    @blip = OBConnector.sharedConnector
    @gray = NSColor.colorWithDeviceRed 0.2, green: 0.2, blue: 0.2, alpha: 1.0
    @red = NSColor.colorWithDeviceRed 0.67, green: 0, blue: 0, alpha: 1.0
    self
  end

  def windowDidLoad
    refreshCounter
    window.setContentBorderThickness(32, forEdge: NSMinYEdge)
    window.movableByWindowBackground = true
    window.delegate = self
    mbObserve(textField, NSControlTextDidChangeNotification, :refreshCounter)
  end

  def windowWillClose(notification)
    # TODO handle closing with content
    mbStopObserving(textField, NSControlTextDidChangeNotification)
    @mainWindow.newMessageDialogClosed
  end

  def refreshCounter
    text = textField.stringValue
    counterLabel.stringValue = "#{text.length} / #{MAX_CHARS}"
    counterLabel.textColor = (text.length <= MAX_CHARS) ? @gray : @red
    sendButton.enabled = (text.length > 0 && text.length <= MAX_CHARS)
  end

  def sendPressed(sender)
    sendButton.mbDisable
    textField.mbDisable
    spinner.startAnimation(self)

    message = textField.stringValue
    # @blip.sendMessageRequest(message).sendFor(self)
    # workaround until they fix CFReadStreamOpen in MacRuby

    url = NSURL.URLWithString("http://api.blip.pl/updates")
    escapedMessage = message.gsub(/\\/, "\\\\").gsub(/"/, "\\\"")
    content = "{\"update\": {\"body\": \"#{escapedMessage}\"}}"
    username = @blip.account.username
    password = @blip.account.password
    authString = "Basic "
    authString += ASIHTTPRequest.base64forData("#{username}:#{password}".dataUsingEncoding(NSUTF8StringEncoding))
    
    request = NSMutableURLRequest.alloc.initWithURL(
      url,
      cachePolicy: NSURLRequestReloadIgnoringLocalCacheData,
      timeoutInterval: 15
    )
    request.HTTPMethod = "POST"
    request.HTTPBody = content.dataUsingEncoding(NSUTF8StringEncoding)
    request.setValue(BLIP_API_VERSION, forHTTPHeaderField: "X-Blip-API")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(@blip.userAgent, forHTTPHeaderField: "User-Agent")
    request.setValue(authString, forHTTPHeaderField: "Authorization")
    
    NSURLConnection.alloc.initWithRequest(request, delegate: self)
  end

  def connectionDidFinishLoading(con)
    window.close
    @blip.dashboardMonitor.performSelector('forceUpdate', withObject: nil, afterDelay: 1)
  end

  def requestFailedWithError(error)
    sendButton.mbEnable
    textField.mbEnable
    spinner.stopAnimation(self)
    mbShowAlertSheet("Error", error.localizedDescription)
  end

end