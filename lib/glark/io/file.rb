#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'rubygems'
require 'riel'

module Glark; end

# A thing that can be grepped (er, glarked).
class Glark::File
  include Loggable

  attr_reader :fname, :stati
  attr_accessor :count, :output, :invert_match

  # cross-platform end of line:   DOS  UNIX  MAC
  ANY_END_OF_LINE = Regexp.new '(?:\r\n|\n|\r)'

  WRITTEN = "written"
  
  def initialize fname, io, args = Glark::Options.instance 
    @fname        = fname
    @io           = io
    @stati        = Array.new      # index = line number, value = context character
    @count        = nil
    @extracted    = nil
    @regions      = nil
    @modlines     = nil
    @invert_match = false
    @linecount    = nil
    @readall      = $/ != "\n"
    @lines        = @readall ? IO.readlines(@fname) : Array.new

    @after        = args[:after]
    @before       = args[:before]
    @output       = args[:output]

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

  def set_status from, to, ch, force = false
    from.upto(to) do |ln|
      if (not @stati[ln]) || (@stati[ln] != WRITTEN && force)
        @stati[ln] = ch
      end
    end
  end

  def mark_as_match startline, endline = startline
    @matched = true

    # even with multi-line matches (--and expressions), we'll display
    # only the first matching line, not the range between the matches.

    if @output == "grep"
      endline = startline
    end

    if @count
      @count += 1
    else
      st = [0, startline - @before].max
      set_status st,          startline - 1,    "-"
      set_status startline,   endline,          ":",  true
      set_status endline + 1, endline + @after, "+"
    end
  end

  def write_matches matching, from = nil, to = nil
    @output.write_matches matching, from, to
  end

  def write_all
    @output.write_all
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
      rnum < @lines.length ? (rnum .. rnum) : nil
    else
      unless @regions
        srclines = @modlines ? @modlines : @lines

        @regions = []           # keys = region number; values = range of lines

        lstart = 0
        srclines.each do |line|
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
