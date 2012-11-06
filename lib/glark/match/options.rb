#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Options for matching.

require 'rubygems'
require 'riel/log'
require 'glark/match/factory'
require 'glark/util/colors'
require 'glark/util/options'

class MatchOptions < Glark::Options
  attr_accessor :expr           # the expression to be evaluated
  attr_accessor :extended       # whether to use extended regular expressions
  attr_accessor :extract_matches
  attr_accessor :ignorecase     # match case
  attr_accessor :whole_lines    # true means patterns must match the entire line
  attr_accessor :whole_words    # true means all patterns are '\b'ed front and back

  def initialize colors, optdata
    @colors = colors
    @expr = nil
    @extended = false
    @extract_matches = false
    @ignorecase = false
    @whole_lines = false
    @whole_words = false

    add_as_options optdata
  end

  def read_expression args, warn_option = false
    @expr = ExpressionFactory.new(self).make_expression args, warn_option
  end

  def text_highlights
    @colors.text_highlights
  end

  def set_text_highlights text_colors
    @colors.text_highlights = text_colors
  end

  def set_text_highlight index, text_color
    @colors.text_highlights[index] = text_color
  end

  def config_fields
    fields = {
      "ignore-case" => @ignorecase,
      "text-color" => text_highlights.join(' '),
    }
  end

  def dump_fields
    fields = {
      "expr" => @expr,
      "extract_matches" => @extract_matches,
      "ignorecase" => @ignorecase,
      "text_highlights" => text_highlights.compact.collect { |hl| hl.highlight("text") }.join(", "),
      "whole_lines" => @whole_lines,
      "whole_words" => @whole_words,
    }
  end

  def update_fields fields
    fields.each do |name, value|
      case name
      when "ignore-case"
        @ignorecase = to_boolean value
      end
    end
  end

  def add_as_options optdata
    optdata << whole_word_option = {
      :tags => %w{ -w --word },
      :set  => set(:whole_words, true)
    }
    
    optdata << ignore_case_option = {
      :tags => %w{ -i --ignore-case },
      :set  => set(:ignorecase, true)
    }

    optdata << whole_line_option = {
      :tags => %w{ -x --line-regexp },
      :set  => set(:whole_lines, true)
    }

    optdata << extended_option = {
      :tags => %w{ --extended },
      :set  => set(:extended, true)
    }

    optdata << expr_file_option = {
      :tags => %w{ -f --file },
      :arg  => [ :string ],
      :set  => Proc.new { |fname| @expr = ExpressionFactory.new(self).read_file fname }
    }

    optdata << orand_expr_option = {
      :tags => %w{ -o -a },
      :set  => Proc.new do |md, opt, args|
        args.unshift opt
        @expr = ExpressionFactory.new(self).make_expression args
      end
    }

    optdata << text_color_option = {
      :tags => %w{ --text-color },
      :arg  => [ :string ],
      :set  => Proc.new { |val| @colors.text_highlights = [ @colors.make_highlight "text-color", val ] }
    }

    optdata << extract_matches_option = {
      :tags => %w{ -y --extract-matches },
      :set  => set(:extract_matches, true)
    }
  end
end
