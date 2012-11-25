#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/criteria'
require 'glark/input/filter/filter'
require 'glark/input/filter/options'
require 'glark/util/optutil'

module Glark; end

class Glark::FileCriteria < Glark::Criteria
  include Glark::OptionUtil

  def opt_classes
    [
     Glark::SizeLimitOption,
     Glark::MatchNameOption,
     Glark::NotNameOption,
     Glark::MatchPathOption,
     Glark::NotPathOption,
     Glark::MatchExtOption,
     Glark::NotExtOption,
    ]
  end

  def config_fields
    maxsize = (filter = find_by_class(:size, :negative, SizeLimitFilter)) && filter.max_size
    fields = {
      "size-limit" => maxsize
    }
  end
end