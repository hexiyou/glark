#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

module Glark
  class NameTestCase < AppTestCase
    def test_match_single
      dirname = '/proj/org/incava/glark/test/resources'
      expected = [
                  '[1m/proj/org/incava/glark/test/resources/rcfile.txt[0m',
                  '    1 # commen[30m[43mt here[0m',
                  '    2 highligh[30m[43mt: single[0m',
                  '    4 local-config-files: [30m[43mtrue[0m',
                  '    7 ignore-case: [30m[43mtrue[0m',
                  '   10 [30m[43mtext-color-3: underline mage[0mnta',
                  '[1m/proj/org/incava/glark/test/resources/textfile.txt[0m',
                  '    2   -rw-r--r--   1 jpace jpace  126084 2010-12-04 15:24 01-TheKnigh[30m[43mtsTale[0m.txt',
                  '    7   -rw-r--r--   1 jpace jpace   71054 2010-12-04 15:24 06-TheWifeOfBa[30m[43mthsTale[0m.txt',
                  '   11   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-TheMerchan[30m[43mtsTale[0m.txt',
                  '   14   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-TheDoc[30m[43mtorsTale[0m.txt',
                  '   21   -rw-r--r--   1 jpace jpace   45326 2010-12-04 15:24 20-TheNunsPries[30m[43mtsTale[0m.txt',
                 ]
      run_app_test expected, [ '-r', '--match-name', '^\w+ile.txt$', 't.*e' ], dirname
    end

    def test_not_single
      dirname = '/proj/org/incava/glark/test/resources'
      expected = [
                  "[1m/proj/org/incava/glark/test/resources/04-TheCooksTale.txt[0m",
                  "    1 Of many a pil[30m[43mgrim hast thou Christe's curse[0m,",
                  "    7 Now tell on, [30m[43mgentle Roger, by thy name[0m,",
                  "[1m/proj/org/incava/glark/test/resources/filelist.txt[0m",
                  "    2 01-The_Kni[30m[43mghts_Tale[0m.txt",
                  "[1m/proj/org/incava/glark/test/resources/rcgrep.txt[0m",
                  "    1 [30m[43mgrep: true[0m",
                  "[1m/proj/org/incava/glark/test/resources/spaces.txt[0m",
                  "    2 01 The Kni[30m[43mghts Tale[0m.txt",
                 ]
      run_app_test expected, [ '-r', '--skip-name', '^\w+e.txt$', 'g.*t.*e\b' ], dirname
    end

    def test_match_multiple
      dirname = '/proj/org/incava/glark/test/resources'
      expected = [
                  "[1m/proj/org/incava/glark/test/resources/filelist.txt[0m",
                  "    7 06-The_Wife_Of_Ba[30m[43mths_Tale[0m.txt",
                  "[1m/proj/org/incava/glark/test/resources/rcext.txt[0m",
                  "    1 ma[30m[43mtch-e[0mxt: rb",
                  "    2 ma[30m[43mtch-e[0mxt: pl",
                  "[1m/proj/org/incava/glark/test/resources/rcmatch.txt[0m",
                  "    1 ma[30m[43mtch-name[0m: \\w+.java",
                  "    2 ma[30m[43mtch-name[0m: \\w+.rb",
                  "[1m/proj/org/incava/glark/test/resources/rcpath.txt[0m",
                  "    2 ma[30m[43mtch-dirpath: src/te[0mst/ruby",
                  "[1m/proj/org/incava/glark/test/resources/spaces.txt[0m",
                  "    7 06 The Wife Of Ba[30m[43mths Tale[0m.txt",
                 ]
      run_app_test expected, [ '-r', '--match-name', '^\w+[^e].txt$', '--match-name', 'rcgrep.txt', 't.*h.*e' ], dirname
    end    

    def test_not_multiple
      dirname = '/proj/org/incava/glark/test/resources'
      expected = [
                  "[1m/proj/org/incava/glark/test/resources/filelist.txt[0m",
                  "    2 01-The_Kni[30m[43mghts_Tale[0m.txt",
                  "[1m/proj/org/incava/glark/test/resources/rcgrep.txt[0m",
                  "    1 [30m[43mgrep: true[0m",
                  "[1m/proj/org/incava/glark/test/resources/spaces.txt[0m",
                  "    2 01 The Kni[30m[43mghts Tale[0m.txt",
                 ]
      run_app_test expected, [ '-r', '--skip-name', '^\w+e.txt$', '--skip-name', '04.*', 'g.*t.*e\b' ], dirname
    end
  end
end
