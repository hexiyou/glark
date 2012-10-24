#!/usr/bin/ruby -w
# -*- ruby -*-

testlib = File.expand_path(__FILE__).sub(Regexp.new('/test.*'), '/test')
$:.unshift testlib

applib = testlib.sub '/test', '/lib' 
$:.unshift applib

# puts "$:: #{$:.join(' ')}"

require 'rubygems'
require 'riel'

require 'test/unit'
require 'yaml'
require 'tempfile'

STDOUT.sync = true
STDERR.sync = true

require 'glark/runner'

Log.verbose = true
Log.set_widths(-15, 35, -35)

class GlarkTestCase < Test::Unit::TestCase
  include Loggable

  # Returns a list of instance methods, in sorted order, so that they are run
  # predictably by the unit test framework.

  class << self
    alias :unsorted_instance_methods :instance_methods
    
    def instance_methods b
      unsorted_instance_methods(true).sort
    end
  end
  
  def run_file_test fname, expected
    info "fname: #{fname}".cyan

    lnum = 0

    File.open(fname) do |file|
      file.each do |line|
        line.chomp!
        log "lnum    : #{lnum}"
        log "expected: #{expected[lnum]}"
        log "line    : #{line}"

        assert_equal expected[lnum], line, "line #{lnum}"
        lnum += 1
      end
    end
    
    assert_equal expected.length, lnum, "ending line number"
    
    File.delete fname
  end

  def create_file fname = nil
    if fname
      File.open(fname, File::CREAT | File::WRONLY | File::TRUNC) do |file|
        yield file
      end
    else
      Tempfile.open "glark" do |file|
        fname = file.path
        yield file
      end
    end
    fname
  end

  def write_file contents, fname = nil
    fname = create_file(fname) do |file|
      for line in contents
        file.puts line
      end
    end
    fname
  end

  def test_nothing
  end
end