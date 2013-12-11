#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: builddat.pl
#
#        USAGE: ./builddat.pl  
#
#  DESCRIPTION: Use gdytmerg.csv to create *.dat files and site.meta data.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Gary Ashton-Jones (GAJ), gary@ashton-jones.com.au
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 07/12/2013 15:16:38
#     REVISION: ---
#===============================================================================

# genre composer work section part gdid genre2 dcomposer dwork dsection dpart ytid
# label => $label,
# lastpublished => '',
# lastupdated => 1386245606,
# layout => 'work',
# title => $filename,
# type => 'page',
# url => "/$filename.html",

use 5.010;
use lib './lib';
use MusicData;
use Composers;
use Composer;
use Work;
use MultiWork;
use SingleWork;
use Section;
use Part;
use Text::CSV;

my $csv = Text::CSV->new ( { binary => 1, sep_char => "\t", } )  # should set binary attribute.
  or die "Cannot use CSV: ".Text::CSV->error_diag ();
my @names = (qw{genre composer work section part gdid genre2 dcomposer dwork dsection dpart ytid});
$csv->column_names(@names);
open my $fh, "<:encoding(utf8)", "gdytmerge.csv" or die "gdytmerge.csv: $!";

my $composers = Composers->new();
$composers->initconfig;
while ( my $hr = $csv->getline_hr( $fh ) ) {
  next unless $hr->{work}; #ignore unparseable entries
  $composers->addrec($hr);
}

$csv->eof or $csv->error_diag();
close $fh;

#output .dat files and new.meta data
$composers->outputdat;
$composers->outputdir;
$composers->outputconfig;

# vi:ai:et:sw=2 ts=2

