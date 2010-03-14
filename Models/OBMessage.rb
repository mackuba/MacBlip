# -------------------------------------------------------
# OBMessage.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class OBMessage

  def senderAndRecipient
    case messageType
      when OBStatusMessage then user.login
      when OBDirectedMessage then "#{user.login} > #{recipient.login}"
      when OBPrivateMessage then "#{user.login} >> #{recipient.login}"
    end
  end

  def keyPathsForValuesAffectingSenderAndRecipient
    NSSet.setWithObjects("messageType", "user", "recipient", nil)
  end

  def processedBody
    text = body
    text += " [FOTO]" if pictures && pictures.length > 0
    text
  end

  def keyPathsForValuesAffectingProcessedBody
    NSSet.setWithObjects("body", "pictures", nil)
  end

end
