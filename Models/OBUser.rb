# -------------------------------------------------------
# OBUser.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under Eclipse Public License v1.0
# -------------------------------------------------------

class OBUser

  def avatar
    if avatarData
      image = NSImage.alloc.initWithData(avatarData)
      # fix for NSImage#size returning wrong size because of weird DPI
      image.representations.each { |r| r.size = NSSize.new(50, 50) } if image
      image
    end
  end

  def fixedAvatarData
    avatar && avatar.TIFFRepresentation
  end

  def keyPathsForValuesAffectingAvatar
    NSSet.setWithObjects("avatarData", nil)
  end

  def keyPathsForValuesAffectingFixedAvatarData
    NSSet.setWithObjects("avatar", nil)
  end

end
