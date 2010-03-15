# -------------------------------------------------------
# MessageTextView.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class MessageTextView < NSTextView

  def menuForEvent(event)
    # menu returned by super is a custom menu built by NSTextView, with service items merged in
    # self.menu is our base menu, assigned by the controller
    # here, we make sure that the new menu has the same delegate reference (it's needed later in the handler)
    menu = super
    menu.delegate = self.menu.delegate
    menu
  end

  def awakeFromNib
    self.linkTextAttributes = {
      NSUnderlineStyleAttributeName => 0,
      NSCursorAttributeName => NSCursor.pointingHandCursor,
      NSForegroundColorAttributeName => NSColor.colorWithDeviceRed(0.2, green: 0.4, blue: 0.8, alpha: 1.0)
    }
  end

  def acceptsFirstResponder
    # unselect currently selected text in another text view, if any
    last = self.window.firstResponder
    last.selectedRange = NSRange.new(0, 0) if last.is_a?(MessageTextView)
    true
  end

  # don't craw vertical text cursor
  def shouldDrawInsertionPoint
    false
  end

  # disables annoying "Get Current Selection (Internal)" service menu item from Quicksilver
  def validRequestorForSendType(sendType, returnType: returnType)
    nil
  end

end
