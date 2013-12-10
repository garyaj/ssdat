package Part;
use Moo;
use MooX::Types::MooseLike::Base qw(:all);
has [qw{part gdid dpart ytid} ] => (isa => Str, is => 'rw');
sub initfromflds {
  my ($self, $flds) = @_;
  $self->part($flds->{part});
  $self->gdid($flds->{gdid});
  $self->dpart($flds->{dpart});
  $self->ytid($flds->{ytid} // '');
}
1;

