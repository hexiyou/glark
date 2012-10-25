#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'glark/exprfactory'
require 'tc'
require 'stringio'

Log.level = Log::DEBUG

class MatchTestCase < GlarkTestCase

  def run_search_test expected, contents, exprargs
    info "exprargs: #{exprargs}".yellow
    opts = GlarkOptions.instance
    
    # Egads, Ruby is fun. Converting a maybe-array into a definite one:
    args = [ exprargs ].flatten

    expr = ExpressionFactory.new.make_expression args

    outfname = infname = nil

    begin
      outfname = create_file do |outfile|
        opts.out = outfile
        infname = write_file contents

        files = [ infname ]
        glark = Glark::Runner.new expr, files
        glark.search infname
      end

      Log.verbose = true

      puts "contents"
      puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
      puts contents
      puts "-------------------------------------------------------"
      puts "expected"
      puts expected
      puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
      
      info "IO::readlines(outfname): #{IO::readlines(outfname)}"

      results = IO::readlines outfname
      puts "results"
      puts results
      puts "*******************************************************" 

      run_file_test outfname, expected
    ensure
      [ outfname, infname ].each do |fname|
        if fname && File.exists?(fname)
          File.delete fname
        end
      end
      GlarkOptions.instance.reset
    end
  end

  def test_match_invert
    contents = [
      "ABC",
      "DEF",
      "GHI",
      "JKL",
      "MNO",
      "PQR",
      "STU",
    ]

    exprstr = "K"

    expected = contents.collect_with_index do |line, idx|
      next if idx == 3
      sprintf "%5d %s", idx + 1, line
    end.compact

    Log.verbose = false
    
    opts = GlarkOptions.instance
    opts.invert_match = true
    opts.verbose = false
    Log.verbose = false

    run_search_test expected, contents, exprstr
  end

  def get_colors patterns
    defcolors = Text::ANSIHighlighter::DEFAULT_COLORS

    patterns.collect_with_index do |pat, pidx|
      color = Text::ANSIHighlighter.make defcolors[pidx % defcolors.length]
      [ pat, color ]
    end
  end

  def run_match_test contents, patterns, regexp, exprargs
    patdata = get_colors patterns

    expected = contents.collect_with_index do |line, li|
      if line.index regexp
        ln = line.dup
        patdata.each do |pat|
          ln.gsub!(pat[0]) { pat[1].highlight pat[0] }
        end
        sprintf "%5d %s", li + 1, ln
      else
        nil
      end
    end.compact

    # Log.verbose = false
    
    opts = GlarkOptions.instance
    opts.verbose = Log.verbose = false

    run_search_test expected, contents, exprargs
  end

  def test_match_plain_old_match
    info "self: #{self}"
    contents = [
      "ABC",
      "DEF",
      "GHI",
      "JKL",
      "MNO",
      "PQR",
      "STU",
    ]

    expected = [
                "    1 [30m[43mA[0mBC"
               ]
    
    run_search_test expected, contents, 'A'

    expected = [
                "    4 J[30m[43mK[0mL"
               ]

    run_search_test expected, contents, 'K'
  end

  def test_match_regexp_or
    contents = [
      "ABC",
      "DEF",
      "GHI",
      "JKL",
      "MNO",
      "PQR",
      "STU",
    ]

    expected = [
                "    4 J[30m[43mK[0mL",
                "    5 M[30m[42mN[0mO"
               ]
    
    run_search_test expected, contents, '(K)|(N)'
  end

  def run_test_match_alteration
    patternsets = [
      %w{ nul },
      %w{ oo ae z },
      %w{ zoo },
      %w{ zeff },
    ]

    contents = [
      "zaffres",
      "zoaea",
      "zoaea's",
      "zoea",
      "zoeas",
      "zonulae",
      "zooea",
      "zooeae",
      "zooeal",
      "zooeas",
      "zooecia",
      "zooecium",
      "zoogloeae",
      "zoogloeal",
      "zoogloeas",
      "zygaenid",
    ]

    patternsets.each do |patterns|
      regexp   = Regexp.new patterns.collect { |x| "(#{x})" }.join('|')
      exprargs = yield patterns

      run_match_test contents, patterns, regexp, exprargs
    end
  end

  def test_match_multicolor_alt_regexp
    run_test_match_alteration do |patterns|
      patterns.collect { |x| "(#{x})" }.join('|')
    end
  end

  def test_match_multicolor_or_expression
    run_test_match_alteration do |patterns|
      exprargs = [ patterns[-1] ]
      patterns.reverse[1 .. -1].each do |pat|
        exprargs.insert 0, "--or", pat
      end
      exprargs
    end
  end

  def run_test_match_and_expression contents, matches, patterns, exprargs
    regexp = Regexp.new patterns.collect { |x| "(#{x})" }.join('|')

    patdata = get_colors patterns

    expected = contents.collect_with_index do |line, li|
      if matches.include? line
        ln = line.dup
        patdata.each do |pat|
          ln.gsub!(pat[0]) { pat[1].highlight pat[0] }
        end
        sprintf "%5d %s", li + 1, ln
      else
        nil
      end
    end.compact

    if false
      for line in expected
        $stderr.puts line
      end
    end

    opts = GlarkOptions.instance
    opts.verbose = Log.verbose = false
    
    run_search_test expected, contents, exprargs
  end

  def test_match_and_expression_2_lines_apart
    Log.level = Log::DEBUG
    info "self: #{self}"
    
    contents = [
      "zaffres",
      "zoaea",
      "zoaea's",
      "zoea",
      "zoeas",
      "zonulae",
      "zooea",
      "zooeae",
      "zooeal",
      "zooeas",
      "zooecia",
      "zooecium",
      "zoogloeae",
      "zoogloeal",
      "zoogloeas",
      "zygaenid",
    ]

    # 'ea', 'ec' within 2 lines of each other:
    matches = [
      "zooeal",
      "zooeas",
      "zooecia",
      "zooecium",
      "zoogloeae",
      "zoogloeal",
    ]

    patterns = %w{ ea ec }
    
    exprargs = [ "--and", "2" ] | patterns

    run_test_match_and_expression contents, matches, patterns, exprargs
  end

  def test_match_and_expression_3_lines_apart
    contents = [
      "zaffres",
      "zoaea",
      "zoaea's",
      "zoea",
      "zoeas",
      "zonulae",
      "zooea",
      "zooeae",
      "zooeal",
      "zooeas",
      "zooecia",
      "zooecium",
      "zoogloeae",
      "zoogloeal",
      "zoogloeas",
      "zygaenid",
    ]

    matches = [
      "zoaea's",
      "zoea",
      "zoeas",
      "zonulae",
    ]

    patterns = %w{ aea ula }
    
    exprargs = [ "--and", "3" ] | patterns

    run_test_match_and_expression contents, matches, patterns, exprargs
  end

  def test_match_and_expression_entire_file
    contents = [
      "zaffres",
      "zoaea",
      "zoaea's",
      "zoea",
      "zoeas",
      "zonulae",
      "zooea",
      "zooeae",
      "zooeal",
      "zooeas",
      "zooecia",
      "zooecium",
      "zoogloeae",
      "zoogloeal",
      "zoogloeas",
      "zygaenid",
    ]

    matches = contents

    patterns = %w{ aff yga }
    
    exprargs = [ "--and", "-1" ] | patterns

    run_test_match_and_expression contents, matches, patterns, exprargs
  end

  def test_match_range
    contents = [
      "ABC",
      "DEF",
      "GHI",
      "JKL",
      "MNO",
      "PQR",
      "STU",
    ]

    exprstr = "M"

    expected = contents.collect_with_index do |line, idx|
      if line.index exprstr
        sprintf "%5d %s", idx + 1, line
      end
    end.compact

    Log.verbose = false
    
    opts = GlarkOptions.instance
    opts.range_start = '4'
    opts.range_end = '5'
    opts.verbose = false
    Log.verbose = true

    run_match_test contents, %w{M}, %r{M}, 'M'
  end
end