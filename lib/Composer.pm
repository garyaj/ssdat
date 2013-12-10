package Composer;
use Mojo::Template;
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
  my $o = ($flds->{genre} =~ /mass|oratorio/) ? MultiWork->new : SingleWork->new;
  $o->initfromflds($flds);
  push @{$self->works}, $o;
}

sub tohtml {
  my $self = shift;
  my $mt = Mojo::Template->new;
  return $mt->render(<<'EOF', $self->works);
% use lib './lib';
% use Composer;
% my ($works) = @_;
<p align="left">
% my $first = 1;
% for my $work (@$works) {
%   if ($first) {
%     $first = 0;
%   } else {
<br />
%   }
<a href="<%= $work->url %>"><%= $work->label %></a>
%   }
</p>
EOF
}

1;
