#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'rubygems'
require 'riel'
require 'glark/input/lines/lines'

module Glark; end

# A thing that can be grepped (er, glarked).
class Glark::File
  include Loggable

  attr_reader :fname
  
  def initialize fname, io, range
    @fname = fname
    @range = range

    linescls = $/ == "\n" ? Glark::LinesCR : Glark::LinesNonCR
    info "linescls: #{linescls}"
    @lines = linescls.new fname, io
    info "@lines: #{@lines}"
  end
  
  def linecount
    @lines.count
  end

  def each_line &blk
    @lines.each_line(&blk)
  end

  # Returns the lines for this file, separated by end of line sequences.
  def get_lines
    @lines.get_lines
  end
  
  # Returns the given line for this file. For this method, a line ends with a
  # CR, as opposed to the "lines" method, which ends with $/.
  def get_line lnum
    @lines.get_line lnum
  end

  # returns the region/range that is represented by the region number
  def get_region rnum
    @lines.get_region rnum
  end

  def get_range_start
    st = @range && @range.from && @range.to_line(@range.from, linecount)
    st
  end

  def get_range_end
    @range && @range.to && @range.to_line(@range.to, linecount)
  end
end
