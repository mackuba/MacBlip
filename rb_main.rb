# -------------------------------------------------------
# rb_main.rb
#
# Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
# Licensed under GPL v3 license
# -------------------------------------------------------

# Loading frameworks
framework 'Cocoa'

# Loading all the Ruby project files
main = File.basename(__FILE__, File.extname(__FILE__))
dir_path = NSBundle.mainBundle.resourcePath.fileSystemRepresentation
Dir.glob(File.join(dir_path, '*.bridgesupport')).uniq.each do |path|
  load_bridge_support_file(path)
end
Dir.glob(File.join(dir_path, '*.{rb,rbo}')).map { |x| File.basename(x, File.extname(x)) }.uniq.each do |path|
  require(path) unless path == main
end

# Starting the Cocoa main loop
NSApplicationMain(0, nil)
