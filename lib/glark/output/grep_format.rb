#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/output/format'

# -------------------------------------------------------
# Grep output format
# -------------------------------------------------------

# This matches grep, mostly. It is for running within emacs, thus,
# it does not support context or highlighting.
class GrepOutputFormat < OutputFormat
  def write_count matching = true 
    print_file_name
    ct = matching ? @infile.count : @infile.get_lines.size - @infile.count
    puts ct
  end

  # prints the line, and adjusts for the fact that in our world, lines are
  # 0-indexed, whereas they are displayed as if 1-indexed.
  def print_line lnum, ch = nil 
    ln = get_line_to_print lnum 

    if ln
      print_file_name
      if show_line_numbers
        printf "%d: ", lnum + 1
      end
      
      print ln
    end
  end

  def print_file_name
    if show_file_name
      fname = @label || @infile.fname
      print fname, ":"
    end
  end
end