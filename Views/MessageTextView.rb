# -------------------------------------------------------
# MessageTextView.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class MessageTextView < NSTextView

  def menuForEvent(event)
    self.menu
  end

end
