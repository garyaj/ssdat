#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: sortdir.pl
#
#        USAGE: ./sortdir.pl  
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
#      CREATED: 15/12/2013 18:37:23
#     REVISION: ---
#===============================================================================

use 5.010;
use File::Slurp;

print map { $_->[0] }
      sort {
        $a->[1] cmp $b->[1] #genre
      }
  map { [$_, m/(?:<[^>]*>)+([^>]*)/ ] }
  read_file( 'directory.dat' );
# vi:ai:et:sw=2 ts=2

