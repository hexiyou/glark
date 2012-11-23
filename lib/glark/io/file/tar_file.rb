#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/io/file/archive_file'

class Glark::TarFile < Glark::ArchiveFile
  def initialize fname, io = nil, &blk
    super fname

    # Given that this is a gem, I'm not sure if it is installed with other
    # package managers. So the require is down here, used only if needed.
    
    # module Gem::Package is declared in 'rubygems/package', not in
    # .../tar_reader.
    require 'rubygems/package'
    require 'rubygems/package/tar_reader'
    @io = io
  end

  def each_file &blk
    f = @io || ::File.new(@fname)
    tr = Gem::Package::TarReader.new f

    tr.each do |entry|
      if entry.file?
        blk.call entry
      end
    end
  end

  def list
    contents = Array.new
    each_file do |entry|
      contents << entry.full_name
    end
    contents
  end
end
