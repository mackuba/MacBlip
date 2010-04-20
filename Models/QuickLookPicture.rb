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
    cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true).first
    return nil unless cachesDirectory

    macblipCache = cachesDirectory.stringByAppendingPathComponent(NSBundle.mainBundle.bundleIdentifier)
    imagesCache = macblipCache.stringByAppendingPathComponent("Pictures")

    isDirectory = Pointer.new_with_type("B")
    directoryExists = NSFileManager.defaultManager.fileExistsAtPath(imagesCache, isDirectory: isDirectory)
    if directoryExists && !isDirectory[0]
      return nil
    elsif !directoryExists
      created = NSFileManager.defaultManager.createDirectoryAtPath(imagesCache,
        withIntermediateDirectories: true,
        attributes: nil,
        error: nil
      )
      return nil unless created
    end

    imageName = (url =~ /\.jpg$/) ? url.gsub(/.*\//, '') : url.gsub(/\/$/, '.jpg').gsub(/.*\//, '')
    imagesCache.stringByAppendingPathComponent(imageName)
  end

  def previewItemURL
    @url
  end

end
