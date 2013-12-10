package Composer;
use Moo;
use MooX::Types::MooseLike::Base qw(:all);
extends 'MusicData';
has '+layout' => (default => 'composer');
has composer => (isa => Str, is => 'rw');
has dcomposer => (isa => Str, is => 'rw');
has works => (isa => ArrayRef[InstanceOf['Work']], is => 'rw', default => sub {[]});

sub initfromflds {
  my ($self, $flds) = @_;
  $self->uniqid($flds->{composer});
  $self->label($flds->{dcomposer}?$flds->{dcomposer}:ucfirst($flds->{composer}));
  $self->title($flds->{composer});
  $self->initurl;
  $self->composer($flds->{composer});
  $self->dcomposer($flds->{dcomposer});
  my $o = ($flds->{genre} eq 'mass') ? MultiWork->new : SingleWork->new;
  $o->initfromflds($flds);
  push @{$self->works}, $o;
}

sub tohtml {
  my ($self, $items) = @_;
  my $s = "<p align=\"left\">\n";
  my $first = 1;
  for my $item (@$items) {
    $s .= "<br />\n" unless $first;
    $s .= '<a href="'.$item->url.'">'.$item->label."</a>\n";
    $first = 0;
  }
  $s .= "</p>\n";
  return $s;
}

sub outputdir {
  my $self = shift;
  foreach my $composer (@{$self->composers}) {
    $composer->outputdat($composer->works);
    foreach my $work (@{$composer->works}) {
      $work->outputdat($work->sections);
    }
  }
}

1;

