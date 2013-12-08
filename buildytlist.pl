#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: buildgdlist.pl
#
#        USAGE: ./buildgdlist.pl  
#
#  DESCRIPTION: Retrieve all video IDs from YouTube and create
#               lookup table of filename = videoid.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Gary Ashton-Jones (GAJ), gary@ashton-jones.com.au
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 06/12/2013 09:59:47
#     REVISION: ---
#===============================================================================

use 5.010;
use autodie;
use WebService::GData::YouTube;
use WebService::GData::YouTube::Query;
use WebService::GData::ClientLogin;
use Getopt::Long;
use Config::Tiny;

my $Config = Config::Tiny->new;
$Config = Config::Tiny->read( "$ENV{HOME}/.youtube/cred.conf" ) or die "Can't open cred.conf";
my $Email    = $Config->{_}->{Email};
my $Password = $Config->{_}->{Password};
my $Key      = $Config->{_}->{Key};

my $auth;
eval {
  $auth = WebService::GData::ClientLogin->new(
    email    => $Email,
    password => $Password,
    key      => $Key,
  );
};
if (my $error = $@){
  die "Can't login to YouTube:",$error->code,':',$error->content;
}

my $yt = WebService::GData::YouTube->new($auth);
my $line = 1;
my $start = 1;
my $limit = 50;
$,="\t";
while (1) {
  $yt->query()->limit($limit,$start);
  my $videos = $yt->get_user_videos();
  foreach my $video (@$videos) {
    $line++;
    say $video->title, $video->video_id;
  }
  $start += $limit;
  last if ($line > 603);
}

# vi:ai:et:sw=2 ts=2

