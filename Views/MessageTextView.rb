# -------------------------------------------------------
# MessageTextView.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class MessageTextView < NSTextView

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
