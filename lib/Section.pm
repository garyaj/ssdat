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

