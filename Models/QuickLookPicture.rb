# -------------------------------------------------------
# QuickLookPicture.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class QuickLookPicture

  def initialize(pictureInfo)
    filePath = localPathForPictureAtUrl(pictureInfo['url'])
    return nil unless filePath

    unless NSFileManager.defaultManager.fileExistsAtPath(filePath)
      pictureInfo['data'].writeToFile(filePath, atomically: false)
    end
    @url = NSURL.fileURLWithPath(filePath)
  end

  def localPathForPictureAtUrl(url)
    cache = FilesController.picturesCacheDirectory
    imageName = (url =~ /\.jpg$/) ? url.gsub(/.*\//, '') : url.gsub(/\/$/, '.jpg').gsub(/.*\//, '')
    cache && cache.stringByAppendingPathComponent(imageName)
  end

  def previewItemURL
    @url
  end

end
