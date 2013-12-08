#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: gdlist.pl
#
#        USAGE: ./gdlist.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Gary Ashton-Jones (GAJ), gary@ashton-jones.com.au
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 01/04/2013 21:39:45
#     REVISION: ---
#===============================================================================

use 5.010;

open my $fh, '<', 'gdlist.csv'
  or die "Can't open file:$!";

while (<$fh>) {
  chomp;
  my @a = split /\s*,\s*/;
  print $a[0],'=',$a[1],"\n";
}
# vi:ai:et:sw=2 ts=2

