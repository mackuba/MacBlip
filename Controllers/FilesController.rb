# -------------------------------------------------------
# FilesController.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

class FilesController
  class << self

    def fileManager
      @fileManager = NSFileManager.defaultManager
    end

    def macblipCacheDirectory
      unless @macblipCacheDirectory
        cache = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true).first
        macblipCache = cache && cache.stringByAppendingPathComponent(NSBundle.mainBundle.bundleIdentifier)
        exists = ensureDirectoryExists(macblipCache)
        @macblipCacheDirectory = exists && macblipCache
      end
      @macblipCacheDirectory
    end

    def picturesCacheDirectory
      unless @picturesCacheDirectory
        picturesCache = macblipCacheDirectory && macblipCacheDirectory.stringByAppendingPathComponent("Pictures")
        exists = ensureDirectoryExists(picturesCache)
        @picturesCacheDirectory = exists && picturesCache
      end
      @picturesCacheDirectory
    end

    def ensureDirectoryExists(path)
      return false if path.blank?
      isDirectory = Pointer.new_with_type("B")
      directoryExists = fileManager.fileExistsAtPath(path, isDirectory: isDirectory)
      if directoryExists && !isDirectory[0]
        return false
      elsif !directoryExists
        created = fileManager.createDirectoryAtPath(path,
          withIntermediateDirectories: true,
          attributes: nil,
          error: nil
        )
        return false unless created
      end
      true
    end

  end
end
