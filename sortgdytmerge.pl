#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: sortgdytmerge.pl
#
#        USAGE: ./sortgdytmerge.pl  
#
#  DESCRIPTION: Sort gdytmerge.csv file into comp. work, section, part order
#               where, if it's a mass, sections are as per mass, and parts are 
#               s,a,t,b,satb.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Gary Ashton-Jones (GAJ), gary@ashton-jones.com.au
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 07/12/2013 22:19:14
#     REVISION: ---
#===============================================================================

use 5.010;

use File::Slurp;

my %Snames=(
  kyrie => '01',
  gloria => '02',
  credo => '03',
  sanctus => '04',
  benedictus => '05',
  agnusdei => '06',
);
my %Vnames=(
  sop => 10,
  alt => 20,
  ten => 30,
  bas => 40,
  sat => 50,
);

print map { $_->[0] }
      sort {
        $a->[2] cmp $b->[2] #composer
                ||
        $a->[1] cmp $b->[1] #genre
                ||
        $a->[3] cmp $b->[3] #work
                ||
  sect($a->[4]) cmp sect($b->[4]) #section
                ||
  part($a->[5]) <=> part($b->[5]) #part
      }
  map { [$_, split(/\t/, $_)] }
  read_file( 'gdytmerge.csv' );

sub sect {
  return (exists $Snames{$_[0]} ? $Snames{$_[0]} : '').$_[0];
}

sub part {
  my $res = $Vnames{substr($_[0],0,3)} + ($_[0] =~ /(\d)/);
  return $res;
}
# vi:ai:et:sw=2 ts=2

