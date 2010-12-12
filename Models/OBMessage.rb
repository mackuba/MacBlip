# -------------------------------------------------------
# OBMessage.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class OBMessage

  def senderAndRecipient
    case messageType
      when OBDirectedMessage then "#{user.login} > #{recipient.login}"
      when OBPrivateMessage then "#{user.login} >> #{recipient.login}"
      else user.login
    end
  end

  def self.keyPathsForValuesAffectingSenderAndRecipient
    NSSet.setWithArray(["messageType", "user.login", "recipient.login"])
  end

  def viewBackgroundColor
    # if messageType == OBNoticeMessage
    #   if body =~ /do obserwowanych/
    #     MessageCell::FOLLOW_BACKGROUND
    #   else
    #     MessageCell::NOTICE_BACKGROUND
    #   end
    # else
    MessageCell.backgroundColor
    # end
  end

  def self.keyPathsForValuesAffectingViewBackgroundColor
    NSSet.setWithArray(["messageType", "body"])
  end

  def picture
    pictureData = pictures.first && pictures.first['data']
    if pictureData
      image = NSImage.alloc.initWithData(pictureData)
      rep = image && image.representations.first
      if rep
        image.size = NSMakeSize(rep.pixelsWide, rep.pixelsHigh)  # force correct size, even if DPI is weird
        minSize = [image.size.width, image.size.height].min
        image.imageCroppedToFitSize(NSMakeSize(minSize, minSize))
      end
    end
  end

  def self.keyPathsForValuesAffectingPicture
    NSSet.setWithObject("pictures")
  end

  def sanitizeTag(tag)
    # remove accented characters, i.e. replace "ó" with "o" etc.
    # first, separate characters and accents
    # the letter ł doesn't seem to work with this method so we'll replace it manually
    decomposed = tag.downcase.gsub(/ł/, 'l').decomposedStringWithCanonicalMapping

    # now, remove everything that is not a letter or digit
    goodChars = NSCharacterSet.characterSetWithCharactersInString("0123456789abcdefghijklmnopqrstuvwxyz")
    decomposed.componentsSeparatedByCharactersInSet(goodChars.invertedSet).componentsJoinedByString('')
  end

  def detectLinks(richText, regexp)
    rubyString = String.new(richText.string)
    rubyString.scan(regexp) do
      offset = $~.offset(0)
      url = yield
      if url && url.length > 0
        range = NSRange.new(offset.first, offset.last - offset.first)
        expanded = LinkExpander.sharedLinkExpander.expand(url) || url
        nsurl = NSURL.URLWithString(expanded)
        richText.addAttribute(NSLinkAttributeName, value: nsurl, range: range) unless nsurl.nil?
      end
    end
  end

  def bodyForGrowl
    hasPicture ? "#{body} [#{tr('PHOTO')}]" : body
  end

  def self.keyPathsForValuesAffectingBodyForGrowl
    NSSet.setWithArray(["hasPicture", "body"])
  end

  def processedBody
    richText = NSMutableAttributedString.alloc.initWithString(body, attributes: {})

    detectLinks(richText, /\#([^\s\!\@\#\$\%\^\&\*\(\)\[\]\+\=\{\}\:\;\'\"\\\|\,\.\<\>\?\/\`\~]+)/) do
      BLIP_WWW_HOST + "/tags/#{sanitizeTag($1)}"
    end
    detectLinks(richText, /\^(\w+)/) { BLIP_WWW_HOST + "/users/#{$1}/dashboard" }
    detectLinks(richText, /\b(\w+\:\/\/[^\s\^\{\}\"\\\|\`\<\>]+)/) { $1 }
    detectLinks(richText, /\[#{tr('PHOTO')}\]$/) { pictures && pictures.first && pictures.first['url'] }

    richText
  end

  def self.keyPathsForValuesAffectingProcessedBody
    NSSet.setWithArray(["body", "pictures"])
  end

  def refreshBody
    willChangeValueForKey "processedBody"
    didChangeValueForKey "processedBody"
  end

end
