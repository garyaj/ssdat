#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: gdinsert.pl
#
#        USAGE: ./gdinsert.pl  
#
#  DESCRIPTION: Find insertion point in GD directory tree and insert file.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Gary Ashton-Jones (GAJ), gary@ashton-jones.com.au
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 04/12/2013 11:56:02
#     REVISION: ---
#===============================================================================

use 5.010;
use Getopt::Long;
use Config::Tiny;
use Cwd;
use File::Slurp;
use Mojo::DOM;
use Log::Log4perl qw(:easy);
use Net::Google::Drive::Simple;

package GDFileUpload;
# Find and/or create directory for file upload.
# Then upload the file(s)
#
sub new {
  my ( $class ) = @_;
  $class = ( ref $class || $class );
  my $self = {};
  bless( $self, $class );
  # requires a ~/.google-drive.yml file with an access token, 
  $self->{gd} = Net::Google::Drive::Simple->new();
  return $self;
}

sub gd {
  return $_[0]->{gd};
}

sub share_folder {
    my( $self, $id ) = @_;
    my $url = URI->new( $self->gd->{ api_file_url }.'/'.$id.'/permissions' );
    my $data = $self->gd->http_json( $url, {
        role => 'reader',
        type => 'anyone',
        value => 'me',
    } );
    return 1;
}

sub dir {
  my ($self, $path, $prcomposer, $prwork) = @_;
  my ($id, $children, $parent);
  ($children, $parent) = $self->gd->children("$path/$prcomposer");
  if (!$children) {
    ($children, $parent) = $self->gd->children($path);
    $id = $self->gd->folder_create($prcomposer, $parent);
    $self->share_folder($id);
  }
  ($children, $parent) = $self->gd->children("$path/$prcomposer/$prwork");
  if (!$children) {
    ($children, $parent) = $self->gd->children("$path/$prcomposer");
    $id = $self->gd->folder_create($prwork, $parent);
    $self->share_folder($id);
    $parent = $id;
  }
  return $parent;
}

sub upload {
  my ( $self, $path ) = @_;
  my $index;

  my $children = $self->gd->children($path);
  for my $child ( @$children ) {
    my $file = $child->title;
    warn $file;
    if ($child->mimeType eq 'application/vnd.google-apps.folder') {  #it's a folder
      $self->upload("$path/$file");
    } elsif ($child->mimeType eq 'audio/mpeg') {  #it's an MP3
      my $id = $child->id;
      print "$path/$file, $id\n";
    } #else ignore the file
  }

  return 1;
}

package main;

# Get display names
my ($dcomposer, $dwork);
GetOptions(
  'composer=s' => \$dcomposer,
  'work=s' => \$dwork,
);
die "Usage: $0 --composer composer --work work"
  unless $dcomposer and $dwork;

#Generate lowercase equivalents of composer and work, taken from current
#directory
# ~gary/Music/sibs/sib/Saint-Saens/Oratorio_de_Noel
my $cwd = cwd();
my ($composer, $work) = (split /\//, $cwd)[-2,-1];   #2nd last is Composer, last is Work
(my $prcomposer = $composer) =~ s/[^a-zA-Z]//g;
$prcomposer =~ s/.*/\L$&/;
(my $prwork = $work) =~ s/[^a-zA-Z]//g;
$prwork =~ s/.*/\L$&/;

Log::Log4perl->easy_init($DEBUG);
my $ftbl = GDFileUpload->new();
my $dir = $ftbl->dir("/practice",$prcomposer,$prwork);

# vi:ai:et:sw=2 ts=2

