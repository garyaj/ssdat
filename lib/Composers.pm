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
  if (!@{$self->composers} or $self->composers->[-1]->composer ne $flds->{composer}) {
    $o = Composer->new;
    $o->initfromflds($flds);
    push @{$self->composers}, $o;
  }
  if (!@{$self->composers->[-1]->works} or $self->composers->[-1]->works->[-1]->work ne $flds->{work}) {
    $o = ($flds->{genre} =~ /mass|oratorio/) ? MultiWork->new : SingleWork->new;
    $o->initfromflds($flds);
    push @{$self->composers->[-1]->works}, $o;
  }
  if (!@{$self->composers->[-1]->works->[-1]->sections}
      or $self->composers->[-1]->works->[-1]->sections->[-1]->section ne $flds->{section}) {
    $o = Section->new;
    $o->initfromflds($flds);
    push @{$self->composers->[-1]->works->[-1]->sections}, $o;
  }
  if (!@{$self->composers->[-1]->works->[-1]->sections->[-1]->parts}
      or $self->composers->[-1]->works->[-1]->sections->[-1]->parts->[-1]->part ne $flds->{part}) {
    $o = Part->new;
    $o->initfromflds($flds);
    push @{$self->composers->[-1]->works->[-1]->sections->[-1]->parts}, $o;
  }
}

sub outputdat {
  my $self = shift;
  foreach my $composer (@{$self->composers}) {
    $composer->outputdat($composer->works);
    foreach my $work (@{$composer->works}) {
      $work->outputdat($work->sections);
    }
  }
}

sub outputconfig {
  my $self = shift;
  my $Config = Config::Tiny->new;
  foreach my $composer (@{$self->composers}) {
    my ($id, $values) = $composer->config;
    $Config->{$id} = $values;
    foreach my $work (@{$composer->works}) {
      my ($id, $values) = $work->config;
      $Config->{$id} = $values;
    }
  }
  $Config->write( 'new.meta', 'utf8' ); #save page data to 'new.meta' file
}

sub outputdir {
  my $self = shift;
  my $mt = Mojo::Template->new;
  open my $out, ">", 'page/directory.dat' or die "directory: $!";
  print $out $mt->render(<<'EOF', $self->composers);
% use lib './lib';
% use Composer;
% my ($composers) = @_;
<p align="left">
% my $first = 1;
% for my $composer (@$composers) {
%   if ($first) {
%     $first = 0;
%   } else {
<br />\
%   }
<a href="<%= $composer->url %>"><%= $composer->dcomposer %></a>
%   }
</p>
EOF
  close $out;
}


1;
