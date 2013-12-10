package MultiWork;
use Moo;
use MooX::Types::MooseLike::Base qw(:all);
extends 'Work';
around 'tohtml' => sub {
  my $orig = shift;
  my $self = shift;
  my $s = '<h2>'.($self->dwork ? $self->dwork : $self->work)."</h2>\n";
  $s .= $orig->($self, @_);
  return $s;
};
1;

