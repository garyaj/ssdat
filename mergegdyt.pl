#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: mergegdyt.pl
#
#        USAGE: ./mergegdyt.pl  
#
#  DESCRIPTION: Use fuzzy matching to identify items in GD list which correspond
#               to those in YT list.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Gary Ashton-Jones (GAJ), gary@ashton-jones.com.au
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 06/12/2013 19:13:01
#     REVISION: ---
#===============================================================================

use 5.010;
use autodie;

#Slurp YT list into a hash keyed on compacted composer and work names.
#Add Carols as composer if no composer.
my %Vnames=(
  s => 'Soprano',
  a => 'Alto',
  t => 'Tenor',
  b => 'Bass',
  s1 => 'Soprano1',
  a1 => 'Alto1',
  t1 => 'Tenor1',
  b1 => 'Bass1',
  s2 => 'Soprano2',
  a2 => 'Alto2',
  t2 => 'Tenor2',
  b2 => 'Bass2',
  satb => 'SATB',
);

my $ytid = {};
my $fh;
open ($fh, '<', 'ytlistsort.csv')
  or die "Can't open ytlistsort.csv:$!";
while (my $line = <$fh>) {
  chomp $line;
  my ($descr, $id) = split /\t/, $line;
  my @a = split /\s\-\s/, $descr;
  die "Too many parts" if (@a > 4);
  die "Not enough parts" if (@a < 2);
  if (@a == 4) {
    unshift(@a, 'mass');
  } elsif (@a == 3) {
    unshift(@a, 'song');
    splice(@a,3,0,'section');
  } elsif (@a == 2) {
    unshift(@a, 'carol', 'carol');
    splice(@a,3,0,'section');
  }
  my @b = @a;
  map { s/.*/\L$&/; s/[^a-z0-9]//g; $_} @b;
  $ytid->{$b[0]}->{$b[1]}->{$b[2]}->{$b[3]}->{$b[4]} = [@a,$id];
}
close $fh;

1;
#Read each line of GD list, split and extract compacted composer and work names
#(and section and part names where appropriate).
#If can match composer and work => output line with YT data attached.
# 
#Else attempt to match words in YT work name with compacted GD work name.
#(Ignore stop words like 'a', 'and' and 'the'.) If more than one YT match, sort
#into highest match order and output line with YT data attached
#Else if no words match output line with YT date but blank YTID field.
open ($fh, '<', 'gdlistsort2.csv')
  or die "Can't open gdlistsort2.csv:$!";
while (my $line = <$fh>) {
  chomp $line;
  my ($descr, $id) = split /\t/, $line;
  my @a = split /\s\-\s/, $descr;
  my ($section, $part) = ($a[-1] =~ /(.*)_([satb][atb]*[12]?)\.mp3/);
  $part = $Vnames{$part};  #full part name
  splice(@a,-1,1,$section,$part);
  die "Too many parts: $line" if (@a > 4);
  die "Not enough parts: $line" if (@a < 2);
  if (@a == 4) {
    unshift(@a, 'mass');
  } elsif (@a == 3) {
    unshift(@a, 'song');
    splice(@a,3,0,'section');
  } elsif (@a == 2) {
    unshift(@a, 'carol', 'carol');
    splice(@a,3,0,'section');
  }
  my @b = @a;
  map { s/.*/\L$&/; s/[^a-z0-9]//g; $_} @b;
  my $yt = $ytid->{$b[0]}->{$b[1]}->{$b[2]}->{$b[3]}->{$b[4]};
  $,="\t";
  say @b,$id,($yt?@{$yt}:('','','','',''));
}
close $fh;

1;
# vi:ai:et:sw=2 ts=2

