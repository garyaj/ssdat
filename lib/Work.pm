package Work;
use Mojo::Template;
use Moo;
use MooX::Types::MooseLike::Base qw(:all);
extends 'MusicData';
has [qw{genre work dwork} ] => (isa => Str, is => 'rw');
has '+layout' => (default => 'work');
has sections => (isa => ArrayRef[InstanceOf['Section']], is => 'rw', default => sub {[]});
sub initfromflds {
  my ($self, $flds) = @_;
  $self->uniqid($flds->{composer}.'-'.$flds->{work});
  $self->label( ($flds->{dcomposer}?$flds->{dcomposer}:ucfirst($flds->{composer})).' - '.
                ($flds->{dwork}?$flds->{dwork}:ucfirst($flds->{work})) );
  $self->title($flds->{composer}.'-'.$flds->{work});
  $self->initurl;
  $self->genre($flds->{genre});
  $self->work($flds->{work});
  $self->dwork($flds->{dwork});
  my $o = Section->new;
  $o->initfromflds($flds);
  push @{$self->sections}, $o;
}

1;

