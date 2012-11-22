#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'rubygems'
require 'riel'
require 'glark/app/options'
require 'glark/input/file/file'
require 'glark/input/file/binary_file'
require 'glark/input/file/gz_file'
require 'glark/input/file/tar_file'
require 'glark/input/file/zip_file'
require 'glark/input/fileset'

$stdout.sync = true             # unbuffer
$stderr.sync = true             # unbuffer

module Glark; end

# The main processor.
class Glark::Runner
  include Loggable

  attr_reader :exit_status
  
  def initialize opts, files
    @opts = opts
    @expr = opts.expr
    @searched_files = Array.new          # files searched, so we don't cycle through links

    @exclude_matching = @opts.input_options.exclude_matching

    @range = @opts.range
    @output_opts = @opts.output_options
    @invert_match = @output_opts.invert_match

    # 0 == matches, 1 == no matches, 2 == error
    @exit_status = @invert_match ? 0 : 1
    
    @opts.files.each do |type, file|
      search type, file
    end
  end

  def search_file file, output_type
    @expr.process file, output_type

    if output_type.matched?
      @exit_status = @invert_match ? 1 : 0
    end
  end

  def create_input_file filecls, fname, io
    filecls.new fname, io, @range
  end

  def create_output_type file
    @output_opts.create_output_type file
  end

  def search_text fname
    io = fname == "-" ? $stdin : File.new(fname)

    file = create_input_file Glark::File, fname, io
    output_type = create_output_type file
    search_file file, output_type
  end

  def search_binary fname
    file = Glark::BinaryFile.new fname
    output_type = BinaryFileSummary.new file, @output_opts
    search_file file, output_type
  end

  def search_read fname
    info "fname: #{fname}".yellow

    extname = fname.extname
    info "extname: #{extname}".cyan
    case extname
    when '.gz'
      Glark::GzFile.new(fname) do |file|
        output_type = create_output_type file
        search_file file, output_type
      end
    when '.tar'
      @output_opts.show_file_names = true
      tarfile = Glark::TarFile.new(fname)
      tarfile.each_file do |entry|
        contents = StringIO.new entry.read
        file = Glark::File.new entry.full_name + " (in #{fname})", contents, nil
        output_type = create_output_type file
        info "output_type: #{output_type}"
        search_file file, output_type
      end
    else
      raise "extension '#{extname}' is not handled"
    end
  end

  def search_list fname
    extname = fname.extname
    info "extname: #{extname}".yellow

    case extname
    when '.tar'
      contents = StringIO.new 
      tarfile = Glark::TarFile.new(fname)
      tarfile.each_file do |entry|
        contents << "#{entry.full_name}\n"
      end
    when '.jar', '.zip'
      contents = StringIO.new 
      jarfile = Glark::ZipFile.new(fname)
      jarfile.each_file do |entry|
        contents << "#{entry.name}\n"
      end
    else
      raise "extension '#{extname}' is not handled"
    end
    contents.rewind
    
    file = create_input_file Glark::File, fname, contents
    output_type = create_output_type file
    search_file file, output_type
  end

  def search_archive fname
    extname = fname.extname
    info "extname: #{extname}".yellow

    case extname
    when '.tar'
      entries = get_tar_entries fname
      entries.each do |entry|
        contents = StringIO.new entry.read
        file = create_input_file Glark::File, entry.full_name + " (in #{fname})", contents
        output_type = create_output_type file
        search_file file, output_type
      end
    end
  end
  
  def search type, name
    if @exclude_matching
      expr = @opts.expr
      return if expr.respond_to?(:re) && expr.re.match(name)
    end
    
    if name == "-" 
      write "reading standard input..."
      search_text "-"
    else
      case type
      when FileType::BINARY
        search_binary name 
      when FileType::TEXT
        search_text name 
      when :decompress, :read
        search_read name 
      when :list
        search_list name 
      else
        raise "type unknown: file: #{name}; type: #{type}"
      end
    end
  end
end
