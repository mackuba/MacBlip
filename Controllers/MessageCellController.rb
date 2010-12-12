# -------------------------------------------------------
# MessageCellController.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class MessageCellController < SDListViewItem

  attr_accessor :dateLabel, :textView, :pictureView

  MINIMUM_CELL_HEIGHT = 72

  def self.dateFormatter
    @dateFormatter ||= HumanReadableDateFormatter.new
  end

  def loadView
    super
    dateLabel.formatter = self.class.dateFormatter

    scrollView = textView.enclosingScrollView
    frame = scrollView.frame

    self.view.initializeLayoutWithTextFrame(frame, withPicture: representedObject.hasPicture)

    # pull text view out of its scroll view (we can't do that in IB, Bad Things happen then)
    scrollView.removeFromSuperview
    textView.frame = frame
    self.view.addSubview(textView)

    self.view.menu = createContextMenu
    self.view.subviews.each { |v| v.menu = self.view.menu }

    # notify text view when body changes, to let it update the tooltips
    representedObject.addObserver(textView, forKeyPath: "processedBody", options: 0, context: nil)
  end

  def createContextMenu
    menu = NSMenu.alloc.initWithTitle ""
    menu.addItemWithTitle(tr("Quote..."), action: 'quoteActionSelected:', keyEquivalent: '')
    if representedObject.user.login != OBConnector.sharedConnector.account.username
      menu.addItemWithTitle(tr("Reply..."), action: 'replyActionSelected:', keyEquivalent: '')
    end
    if representedObject.pictures && representedObject.pictures.length > 0
      menu.addItemWithTitle(tr("Open picture in browser..."), action: 'showPictureActionSelected:', keyEquivalent: '')
    end
    menu.delegate = self
    menu
  end

  def heightForGivenWidth(newCellWidth)
    padding = self.view.padding
    newTextWidth = newCellWidth - padding.width - 2 * textView.textContainer.lineFragmentPadding
    boxForTextView = textView.textStorage.boundingRectWithSize(
      NSMakeSize(newTextWidth, 2000),
      options: NSStringDrawingUsesLineFragmentOrigin
    )
    pictureHeight = self.representedObject.hasPicture ? pictureView.frame.size.height : 0
    newCellHeight = [boxForTextView.size.height, pictureHeight].max + padding.height

    [newCellHeight, MINIMUM_CELL_HEIGHT].max
  end

  def avatarClicked(sender)
    BrowserController.openUsersDashboard(self.representedObject.user.login)
  end

  def pictureClicked(sender)
    mainWindowController = self.view.window.windowController
    mainWindowController.displayImageInQuickLook(self.representedObject)
  end

end
