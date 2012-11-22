#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::BinaryFileTestCase < Glark::AppTestCase
  def test_match
    fname = '/proj/org/incava/glark/test/resources/textfile.txt.gz'
    expected = [ "Binary file " + fname + " matches" ]
    run_app_test expected, [ '--binary=binary', 'i' ], fname
  end

  def test_no_match
    fname = '/proj/org/incava/glark/test/resources/textfile.txt.gz'
    expected = [ ]
    run_app_test expected, [ '--binary=binary', 'Q' ], fname
  end

  def test_as_text
    fname = '/proj/org/incava/glark/test/resources/textfile.txt.gz'
    expected = [ 
                '    1 ��$�P textf[30m[43mi[0mle.txt ���n�0E��',
                '    3 ��!��8�&qm��.���(�BIM?��n�A@���8w�X�ޫT-c��`[w�3���� +.�/(�ձs���4�������y#	,�����[30m[43mi[0m<ھ�Ť��,\X[��.�Р�K,����r�(�*%�&Ɨb�h�UnІ��޾�j���^h?���N7v��G�5ɫ���m��2�B5�_��r����f��V�؀j�����֥��a���E���f��-S`(a/ӷ����J�,d�oc;��4JR�e��6=ư&�'
                ]
    run_app_test expected, [ '--binary-files=text', 'i' ], fname
  end

  def test_skip
    fname = '/proj/org/incava/glark/test/resources/textfile.txt.gz'
    expected = [ ]
    run_app_test expected, [ '--binary=skip', 'i' ], fname
  end

  def test_without_match
    fname = '/proj/org/incava/glark/test/resources/textfile.txt.gz'
    expected = [ ]
    run_app_test expected, [ '--binary=without-match', 'i' ], fname
  end

  def run_decompress_gz_single_test binopt
    fname = '/proj/org/incava/glark/test/resources/textfile.txt.gz'
    expected = [ 
                "    5   -rw-r--r--   1 jpace jpace    6525 2010-12-04 15:24 04-[30m[43mTheCooksTale.txt[0m",
                "   10   -rw-r--r--   1 jpace jpace   64791 2010-12-04 15:24 09-[30m[43mTheClerksTale.txt[0m",
                "   23   -rw-r--r--   1 jpace jpace   52953 2010-12-04 15:24 22-[30m[43mTheCanonsYeomansTale.txt[0m",
               ]
    run_app_test expected, [ '--binary=' + binopt, 'The.*C.*' ], fname
  end

  def run_decompress_gz_multiple_test binopt
    fnames = [ '/proj/org/incava/glark/test/resources/textfile.txt.gz',  '/proj/org/incava/glark/test/resources/zfile.txt.gz' ]
    expected = [ 
                "[1m/proj/org/incava/glark/test/resources/textfile.txt.gz[0m",
                "   18   -rw-r--r--   1 jpace jpace   14834 2010-12-04 15:24 17-Ch[30m[43maucersTaleOfSi[0mrThopas.txt",
                "   19   -rw-r--r--   1 jpace jpace   43249 2010-12-04 15:24 18-Ch[30m[43maucersTaleOfMeli[0mboeus.txt",
                "[1m/proj/org/incava/glark/test/resources/zfile.txt.gz[0m",
                "   16 zyg[30m[43maeni[0md",
               ]
    run_app_test expected, [ '--binary=' + binopt, 'a\w*e\w*i' ], *fnames
  end

  def test_decompress_gz_single
    run_decompress_gz_single_test 'decompress'
  end

  def test_decompress_gz_multiple
    run_decompress_gz_multiple_test 'decompress'
  end

  def test_read_gz_single
    run_decompress_gz_single_test 'read'
  end

  def test_read_gz_multiple
    run_decompress_gz_multiple_test 'read'
  end

  def test_list_tar_single
    fname = '/proj/org/incava/glark/test/resources/rc.tar'
    expected = [ 
                "    4 rcm[30m[43ma[0mtch.txt",
                "    5 rcp[30m[43ma[0mth.txt",
               ]
    run_app_test expected, [ '--binary=list', 'a' ], fname
  end

  def test_contents_tar_single
    fname = '/proj/org/incava/glark/test/resources/rc.tar'
    expected = [ 
                "[1mrcfile.txt (in /proj/org/incava/glark/test/resources/rc.tar)[0m",
                "    2 h[30m[43mighlight: si[0mngle",
                "    3 # h[30m[43mighlight: multi[0m",
                "    4 local-conf[30m[43mig-fi[0mles: true",
                "    8 s[30m[43mize-limi[0mt: 1000",
                "[1mrcpath.txt (in /proj/org/incava/glark/test/resources/rc.tar)[0m",
                "    1 match-d[30m[43mirpath: src/mai[0mn/java",
                "    4 not-d[30m[43mirpath: org/incava/uti[0ml",
               ]
    run_app_test expected, [ '--binary=read', 'i.*i' ], fname
  end

  def xxxtest_list_targz_single
    fname = '/proj/org/incava/glark/test/resources/rubies.tar.gz'
    expected = [ 
                "[1mrcfile.txt (in /proj/org/incava/glark/test/resources/rc.tar)[0m",
                "    2 h[30m[43mighlight: si[0mngle",
                "    3 # h[30m[43mighlight: multi[0m",
                "    4 local-conf[30m[43mig-fi[0mles: true",
                "    8 s[30m[43mize-limi[0mt: 1000",
                "[1mrcpath.txt (in /proj/org/incava/glark/test/resources/rc.tar)[0m",
                "    1 match-d[30m[43mirpath: src/mai[0mn/java",
                "    4 not-d[30m[43mirpath: org/incava/uti[0ml",
               ]
    run_app_test expected, [ '--binary=read', 'i.*i' ], fname
  end
end
