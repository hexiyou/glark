#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'glark/match/factory'
require 'tc'

class Glark::MatchTestCase < Glark::TestCase
  def run_search_test expected, contents, exprargs
    info "exprargs: #{exprargs}".yellow
    opts = Glark::Options.instance
    
    # Egads, Ruby is fun. Converting a maybe-array into a definite one:
    args = [ exprargs ].flatten

    expr = opts.get_expression_factory.make_expression args

    outfname = infname = nil

    begin
      Log.verbose = true

      outfname = create_file do |outfile|
        opts.out = outfile
        infname = write_file contents

        files = [ infname ]
        glark = Glark::Runner.new expr, files
        glark.search infname
      end

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
      Glark::Options.instance.reset
    end
  end

  def test_invert_with_match
    expected = [
                "    1 ABC",
                "    2 DEF",
                "    3 GHI",
                "    5 MNO",
                "    6 PQR",
                "    7 STU",
               ]

    Log.verbose = false
    
    opts = Glark::Options.instance
    opts.invert_match = true
    opts.verbose = false
    Log.verbose = false

    run_abc_test expected, 'K'
  end

  def test_invert_no_matches
    expected = [
                "    1 ABC",
                "    2 DEF",
                "    3 GHI",
                "    4 JKL",
                "    5 MNO",
                "    6 PQR",
                "    7 STU",
               ]

    Log.verbose = false
    
    opts = Glark::Options.instance
    opts.invert_match = true
    opts.verbose = false
    Log.verbose = false

    run_abc_test expected, 'X'
  end

  def get_colors patterns
    defcolors = Text::ANSIHighlighter::DEFAULT_COLORS

    patterns.collect_with_index do |pat, pidx|
      color = Text::ANSIHighlighter.make defcolors[pidx % defcolors.length]
      [ pat, color ]
    end
  end

  def run_abc_test expected, exprargs
    contents = [
                "ABC",
                "DEF",
                "GHI",
                "JKL",
                "MNO",
                "PQR",
                "STU",
               ]

    run_search_test expected, contents, exprargs
  end

  def test_plain_old_match_first_line
    expected = [
                "    1 [30m[43mA[0mBC"
               ]
    
    run_abc_test expected, 'A'
  end

  def test_plain_old_match_middle_line
    expected = [
                "    4 J[30m[43mK[0mL"
               ]

    run_abc_test expected, 'K'
  end

  def test_regexp_or
    expected = [
                "    4 J[30m[43mK[0mL",
                "    5 M[30m[42mN[0mO"
               ]    

    run_abc_test expected, '(K)|(N)'
  end

  def run_z_test expected, exprargs
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
    
    run_search_test expected, contents, exprargs
  end

  def test_multicolor_alt_regexp_one_match
    patterns = %w{ nul }

    expected = [
                "    6 zo[30m[43mnul[0mae"
               ]

    exprargs = patterns.collect { |x| "(#{x})" }.join('|')
    
    run_z_test expected, exprargs
  end

  def test_multicolor_alt_regexp_3_patterns
    patterns = %w{ oo ae z }

    expected = [
                "    1 [30m[45mz[0maffres",
                "    2 [30m[45mz[0mo[30m[42mae[0ma",
                "    3 [30m[45mz[0mo[30m[42mae[0ma's",
                "    4 [30m[45mz[0moea",
                "    5 [30m[45mz[0moeas",
                "    6 [30m[45mz[0monul[30m[42mae[0m",
                "    7 [30m[45mz[0m[30m[43moo[0mea",
                "    8 [30m[45mz[0m[30m[43moo[0me[30m[42mae[0m",
                "    9 [30m[45mz[0m[30m[43moo[0meal",
                "   10 [30m[45mz[0m[30m[43moo[0meas",
                "   11 [30m[45mz[0m[30m[43moo[0mecia",
                "   12 [30m[45mz[0m[30m[43moo[0mecium",
                "   13 [30m[45mz[0m[30m[43moo[0mgloe[30m[42mae[0m",
                "   14 [30m[45mz[0m[30m[43moo[0mgloeal",
                "   15 [30m[45mz[0m[30m[43moo[0mgloeas",
                "   16 [30m[45mz[0myg[30m[42mae[0mnid",
               ]

    exprargs = patterns.collect { |x| "(#{x})" }.join('|')
    
    run_z_test expected, exprargs
  end

  def test_multicolor_or_expression_3_patterns
    patterns = %w{ oo ae z }

    expected = [
                "    1 [30m[45mz[0maffres",
                "    2 [30m[45mz[0mo[30m[42mae[0ma",
                "    3 [30m[45mz[0mo[30m[42mae[0ma's",
                "    4 [30m[45mz[0moea",
                "    5 [30m[45mz[0moeas",
                "    6 [30m[45mz[0monul[30m[42mae[0m",
                "    7 [30m[45mz[0m[30m[43moo[0mea",
                "    8 [30m[45mz[0m[30m[43moo[0me[30m[42mae[0m",
                "    9 [30m[45mz[0m[30m[43moo[0meal",
                "   10 [30m[45mz[0m[30m[43moo[0meas",
                "   11 [30m[45mz[0m[30m[43moo[0mecia",
                "   12 [30m[45mz[0m[30m[43moo[0mecium",
                "   13 [30m[45mz[0m[30m[43moo[0mgloe[30m[42mae[0m",
                "   14 [30m[45mz[0m[30m[43moo[0mgloeal",
                "   15 [30m[45mz[0m[30m[43moo[0mgloeas",
                "   16 [30m[45mz[0myg[30m[42mae[0mnid",
               ]

    exprargs = patterns[0 ... -1].collect { '--or' } + patterns
    info "exprargs: #{exprargs}".on_blue
    
    run_z_test expected, exprargs
  end

  def test_and_expression_2_lines_apart
    Log.level = Log::DEBUG
    info "self: #{self}"
    
    # 'ea', 'ec' within 2 lines of each other:
    expected = [
                "    9 zoo[30m[43mea[0ml",
                "   10 zoo[30m[43mea[0ms",
                "   11 zoo[30m[42mec[0mia",
                "   12 zoo[30m[42mec[0mium",
                "   13 zooglo[30m[43mea[0me",
                "   14 zooglo[30m[43mea[0ml"
               ]
    
    patterns = %w{ ea ec }
    
    exprargs = [ "--and", "2" ] + patterns

    run_z_test expected, exprargs
  end

  def test_and_expression_3_lines_apart
    expected = [
                "    3 zo[30m[43maea[0m's",
                "    4 zoea",
                "    5 zoeas",
                "    6 zon[30m[42mula[0me"
               ]

    patterns = %w{ aea ula }
    
    exprargs = [ "--and", "3" ] + patterns

    run_z_test expected, exprargs
  end

  def test_and_expression_entire_file
    expected = [
                "    1 z[30m[43maff[0mres",
                "    2 zoaea",
                "    3 zoaea's",
                "    4 zoea",
                "    5 zoeas",
                "    6 zonulae",
                "    7 zooea",
                "    8 zooeae",
                "    9 zooeal",
                "   10 zooeas",
                "   11 zooecia",
                "   12 zooecium",
                "   13 zoogloeae",
                "   14 zoogloeal",
                "   15 zoogloeas",
                "   16 z[30m[42myga[0menid",
               ]

    patterns = %w{ aff yga }    
    exprargs = [ "--and", "-1" ] + patterns

    run_z_test expected, exprargs
  end

  def test_range_in_range
    expected = [
                "    5 [30m[43mM[0mNO",
               ]

    Log.verbose = false
    
    opts = Glark::Options.instance
    opts.range = Glark::Range.new '4', '5'
    opts.verbose = false
    Log.verbose = true

    run_abc_test expected, 'M'
  end

  def test_range_out_of_range
    expected = [
               ]

    Log.verbose = false
    
    opts = Glark::Options.instance
    opts.range = Glark::Range.new '6', '8'
    opts.verbose = false
    Log.verbose = true

    run_abc_test expected, 'M'
  end
end
