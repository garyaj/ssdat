package MusicData;
use Moo;
use MooX::Types::MooseLike::Base qw(:all);

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
  my ($self, $items) = @_;
  open my $out, ">", 'page/'.$self->uniqid.'.dat' or die "$self->uniqid: $!";
  print $out $self->tohtml;
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

