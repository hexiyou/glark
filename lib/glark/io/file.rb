#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'rubygems'
require 'riel'
require 'glark/io/line_status'

module Glark; end

class Glark::FileOptions
  attr_accessor :after
  attr_accessor :before
  attr_accessor :formatter
  
  def initialize after, before, formatter
    @after = after
    @before = before
    @formatter = formatter
  end
end

# A thing that can be grepped (er, glarked).
class Glark::File
  include Loggable

  attr_reader :fname, :stati
  attr_accessor :count, :formatter

  # cross-platform end of line:   DOS  UNIX  MAC
  ANY_END_OF_LINE = Regexp.new '(?:\r\n|\n|\r)'

  WRITTEN = Glark::LineStatus::WRITTEN
  
  def initialize fname, io, fopts
    @fname        = fname
    @io           = io
    # index = line number, value = context character
    @stati        = Glark::LineStatus.new
    @count        = nil
    @extracted    = nil
    @regions      = nil
    @linecount    = nil
    @readall      = $/ != "\n"
    @lines        = @readall ? IO.readlines(@fname) : Array.new
    @after        = fopts.after
    @before       = fopts.before
    @formatter    = fopts.formatter
    @matched      = false
  end
  
  def linecount
    @linecount ||= IO.readlines(@fname).size
  end

  def matched?
    @matched
  end

  def each_line &blk
    if @readall
      @lines.each do |line|
        blk.call line
      end
    else
      while (line = @io.gets) && line.length > 0
        @lines << line
        blk.call line
      end
    end
  end

  def mark_as_match startline, endline = startline
    @matched = true

    # even with multi-line matches (--and expressions), we'll display
    # only the first matching line, not the range between the matches.

    if @formatter.kind_of? GrepOutputFormat
      endline = startline
    end

    if @count
      @count += 1
    else
      st = [0, startline - @before].max
      @stati.set_match startline - @before, startline, endline, endline + @after
    end
  end

  # Returns the lines for this file, separated by end of line sequences.
  def get_lines
    return @lines if $/ == "\n"
    
    @extracted ||= begin
                     # This is much easier. Just resplit the whole thing at end of line
                     # sequences.
                     
                     eoline    = "\n"             # should be OS-dependent
                     srclines  = @lines
                     reallines = @lines.join("").split ANY_END_OF_LINE
                     
                     # "\n" after all but the last line
                     extracted = (0 ... (reallines.length - 1)).collect { |lnum| reallines[lnum] + eoline }
                     extracted << reallines[-1]

                     if Log.verbose
                       extracted.each_with_index { |line, idx| "extracted[#{idx}]: #{@extracted[idx]}" }
                     end
                     extracted
                   end
  end
  
  # Returns the given line for this file. For this method, a line ends with a
  # CR, as opposed to the "lines" method, which ends with $/.
  def get_line lnum
    log { "lnum: #{lnum}" }
    ln = get_lines[lnum]
    log { "ln: #{ln}" }
    ln
  end

  # returns the range that is represented by the region number
  def get_range rnum
    if $/ == "\n"
      # easy case: range is the range number, unless it is out of range.
      return rnum < @lines.length ? (rnum .. rnum) : nil
    else
      ### $$$ todo: add tests for this (paragraph separator not \n)
      unless @regions
        @regions = []           # keys = region number; values = range of lines

        lstart = 0
        @lines.each do |line|
          lend = lstart
          line.scan(ANY_END_OF_LINE).each do |cr|
            lend += 1
          end

          @regions << Range.new(lstart, lend - 1)

          lstart = lend
        end
      end

      @regions[rnum]
    end
  end
end
