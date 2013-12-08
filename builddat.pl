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

use 5.010;
use Config::Tiny;
use Text::CSV;
use Mojo::Template;

my $mt = Mojo::Template->new;

my $Config = Config::Tiny->new; #build new.meta details and output at end.

my $csv = Text::CSV->new ( { binary => 1, sep_char => "\t", } )  # should set binary attribute.
  or die "Cannot use CSV: ".Text::CSV->error_diag ();
my @names = (qw{genre composer work section part gdid genre2 dcomposer dwork dsection dpart ytid});
$csv->column_names(@names);
open my $fh, "<:encoding(utf8)", "gdytmerge.csv" or die "gdytmerge.csv: $!";
$,="; ";
my %composers;
my @sections;
my $prevhr = {};
while ( my $hr = $csv->getline_hr( $fh ) ) {
  next unless $hr->{work}; #ignore unparseable entries

  if ($hr->{composer} ne $prevhr->{composer}) {
    if ($prevhr->{composer}) {
      outputdat('comp', $prevhr, $mt, \@sections);
      @sections = ();
    }
  }
  if ($hr->{work} ne $prevhr->{work}) {
    if ($prevhr->{work}) {
      outputdat('song', $prevhr, $mt, \@sections);
      @sections = ();
    }
  } elsif ($hr->{section} ne $prevhr->{section}) {
    if ($prevhr->{section}) {
      if ($prevhr->{genre} ne 'mass') {
        #output single section template
        outputdat('song', $prevhr, $mt, \@sections);
        @sections = ();
      }
    }
  }
  #normal processing: same composer, work, section
  push @sections, $hr;
  $prevhr = $hr;
}
outputdat('song', $prevhr, $mt, \@sections);
outputdat('comp', $prevhr, $mt, \@sections);

$csv->eof or $csv->error_diag();
close $fh;
$Config->write( 'new.meta', 'utf8' ); #save page data to 'new.meta' file

sub outputdat {
  my ($type, $ph, $mt, $sections) = @_;
  my $filename = $ph->{composer}.($type ne 'comp' ? '-'.$ph->{work} : '');
  open my $out, ">", "page/$filename.dat" or die "$filename: $!";
  print $out $mt->render_file(
    ($type eq 'comp' ? 'comp'
                     : ($ph->{genre} eq 'mass' ? 'mass'
                                               : 'song')
  ).'.mt', $sections);
  close $out;
  my $label = ($ph->{dcomposer} ?$ph->{dcomposer} :$ph->{composer} ).
              ($type ne 'comp' ? ' - '.($ph->{dwork} ?$ph->{dwork} :$ph->{work}) : '' );
  $Config->{$filename} = {
    label => $label,
    lastpublished => '',
    lastupdated => 1386245606,
    layout => 'work',
    title => $filename,
    type => 'page',
    url => "/$filename.html",
  };
  1;
}

# vi:ai:et:sw=2 ts=2

