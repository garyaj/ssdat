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
package MusicData;
use Moo;
use MooX::Types::MooseLike::Base qw(:all);
use Mojo::Template;

has uniqid        => (isa => Str, is => 'rw');
has label         => (isa => Str, is => 'rw');
has lastpublished => (isa => Str, is => 'rw', default => '');
has lastupdated   => (isa => Str, is => 'rw', default => 1386245606);
has layout        => (isa => Str, is => 'rw');
has title         => (isa => Str, is => 'rw');
has type          => (isa => Str, is => 'rw', default => 'page');
has url           => (isa => Str, is => 'rw');

sub initurl {
  my $self = shift;
  $self->url('/'.$self->uniqid.'.html');
}

sub outputdat {
  my $self = shift;
  my $mt = Mojo::Template->new;
  open my $out, ">", 'page/'.$self->uniqid.'.dat' or die "$self->uniqid: $!";
  print $out $mt->render_file($self->format.'.mt', $self->sections);
  close $out;
}

sub config {
  return ( $_[0]->uniqid => {
      label => $_[0]->label,
      lastpublished => $_[0]->lastpublished,
      lastupdated => $_[0]->lastupdated,
      layout => $_[0]->layout,
      title => $_[0]->title,
      type => $_[0]->type,
      url => $_[0]->url,
    }
  );
}
1;

package Composers;
use Moo;
use MooX::Types::MooseLike::Base qw(:all);
use Config::Tiny;
has composers => (isa => ArrayRef[InstanceOf['Composer']], is => 'rw', default => sub {[]});

sub addrec {
  #Search up composer hierarchy, adding parents if necessary,
  #then push flds into composers, works, sections and parts
  my ($self, $flds) = @_;
  my $o;
  if (!@{$self->composers} or $self->composers->[-1] ne $flds->{composer}) {
    $o = Composer->new;
    $o->initfromflds($flds);
    push @{$self->composers}, $o;
  }
  if (!@{$self->composers->[-1]->works} or $self->composers->[-1]->works->[-1]->work ne $flds->{work}) {
    $o = ($flds->{genre} eq 'mass') ? MultiWork->new : SingleWork->new;
    $o->initfromflds($flds);
    push @{$self->composers->[-1]->works}, $o;
  }
  if (!@{$self->composers->[-1]->works->[-1]->sections} or $self->composers->[-1]->works->[-1]->sections->[-1]->section ne $flds->{section}) {
    $o = Section->new;
    $o->initfromflds($flds);
    push @{$self->composers->[-1]->works->[-1]->sections}, $o;
  }
  $o = Part->new;
  $o->initfromflds($flds);
  push @{$self->composers->[-1]->works->[-1]->sections->[-1]->parts}, $o;
}

sub outputdat {
  my $self = shift;
  $_->outputdat foreach (@$self->composers);
}

sub outputconfig {
  my $self = shift;
  my $Config = Config::Tiny->new;
  foreach my $composer (@$self->composers) {
    my ($id, $values) = $composer->config;
    $Config->{$id} = $values;
  }
  $Config->write( 'new.meta', 'utf8' ); #save page data to 'new.meta' file
}
1;

package Composer;
use Moo;
use MooX::Types::MooseLike::Base qw(:all);
extends 'MusicData';
has composer => (isa => Str, is => 'rw');
has dcomposer => (isa => Str, is => 'rw');
has works => (isa => ArrayRef[InstanceOf['Work']], is => 'rw', default => sub {[]});
has template => (isa => Str, is => 'rw', default => 'composer');
sub initfromflds {
  my ($self, $flds) = @_;
  $self->uniqid($flds->{composer});
  $self->label($flds->{dcomposer});
  $self->initurl;
  my $o = ($flds->{genre} eq 'mass') ? MultiWork->new : SingleWork->new;
  $o->initfromflds($flds);
  push @{$self->works}, $o;
}
1;

package Work;
use Moo;
use MooX::Types::MooseLike::Base qw(:all);
extends 'MusicData';
has [qw{genre work dwork} ] => (isa => Str, is => 'rw');
has sections => (isa => ArrayRef[InstanceOf['Section']], is => 'rw', default => sub {[]});
has template => (isa => Str, is => 'rw');
sub initfromflds {
  my ($self, $flds) = @_;
  $self->uniqid($flds->{composer}.'-'.$flds->{work});
  $self->label($flds->{dcomposer}.' - '.$flds->{dwork});
  $self->initurl;
  $self->genre($flds->{genre});
  $self->work($flds->{work});
  $self->dwork($flds->{dwork});
  my $o = Section->new;
  $o->initfromflds($flds);
  push @{$self->sections}, $o;
}
1;

package MultiWork;
use Moo;
use MooX::Types::MooseLike::Base qw(:all);
extends 'Work';
has '+template' => (default => 'mass');
1;

package SingleWork;
use Moo;
use MooX::Types::MooseLike::Base qw(:all);
extends 'Work';
has '+template' => (default => 'song');
1;

package Section;
use Moo;
use MooX::Types::MooseLike::Base qw(:all);
has parts => (isa => ArrayRef[InstanceOf['Part']], is => 'rw', default => sub {[]});
has [qw{section dsection} ] => (isa => Str, is => 'rw');
sub initfromflds {
  my ($self, $flds) = @_;
  $self->section($flds->{section});
  $self->dsection($flds->{dsection});
  my $o = Part->new();
  $o->initfromflds($flds);
  push @{$self->parts}, $o;
}
1;

package Part;
use Moo;
use MooX::Types::MooseLike::Base qw(:all);
has [qw{part gdid dpart ytid} ] => (isa => Str, is => 'rw');
sub initfromflds {
  my ($self, $flds) = @_;
  $self->part($flds->{part});
  $self->gdid($flds->{gdid});
  $self->dpart($flds->{dpart});
  $self->ytid($flds->{ytid});
}
1;

package main;
use 5.010;
use Text::CSV;

my $csv = Text::CSV->new ( { binary => 1, sep_char => "\t", } )  # should set binary attribute.
  or die "Cannot use CSV: ".Text::CSV->error_diag ();
my @names = (qw{genre composer work section part gdid genre2 dcomposer dwork dsection dpart ytid});
$csv->column_names(@names);
open my $fh, "<:encoding(utf8)", "gdytmerge.csv" or die "gdytmerge.csv: $!";

my $composers = Composers->new();
while ( my $hr = $csv->getline_hr( $fh ) ) {
  next unless $hr->{work}; #ignore unparseable entries
  $composers->addrec($hr);
}

$csv->eof or $csv->error_diag();
close $fh;

#output .dat files and new.meta data
$composers->outputdat;
$composers->outputconfig;

# vi:ai:et:sw=2 ts=2

