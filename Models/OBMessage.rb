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

end
