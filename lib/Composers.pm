package Composers;
use Moo;
use MooX::Types::MooseLike::Base qw(:all);
use Config::Tiny;
has composers => (isa => ArrayRef[InstanceOf['Composer']], is => 'rw', default => sub {[]});
has tinyconfig => (isa => Object, is => 'rw');

sub initconfig {
  my $self = shift;
  my $Config = Config::Tiny->new;
  $self->tinyconfig($Config);
}

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
    $composer->config($self);
    foreach my $work (@{$composer->works}) {
      $work->outputdat($work->sections);
      $work->config($self);
    }
  }
}

#Output pages of links for:
#Composers, masses, oratorios, motets(songs), carols, hymns
#All songs by name
#
sub outputdir {
  my $self = shift;
  my $mt = Mojo::Template->new;
  open my $out, ">", 'page/directory.dat' or die "directory: $!";
  print $out $mt->render(<<'EOF', $self->composers);
% use lib './lib';
% use Composer;
% use Work;
% my ($composers) = @_;
<div class="column_1" style="float: left; width: 33%; margin-right: 2%;">
<h3>Composers</h3>
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
</div>
<div class="column_2" style="float: right; width: 61%;">
% # Build list of genre,title pairs from works lists,
% # sort into genre order and output in sections by genre.
% my $genres = {
%   mass => [1, 'Masses'],
%   oratorio => [2, 'Oratorios'],
%   song => [3, 'Motets'],
%   carol => [4, 'Carols'],
%   hymn => [5, 'Hymns'],
% };
% my @titles;
% for my $composer (@$composers) {
%   for my $work (@{$composer->works}) {
%      push @titles, [ $work->genre, ucfirst( $work->dwork ? $work->dwork : $work->work), $work->url ];
%   }
% }
% my $prevgen = '';
% for my $title (sort {
%  $genres->{$a->[0]}->[0] <=> $genres->{$b->[0]}->[0]
%                          ||
%                 $a->[1] cmp $b->[1]
% } @titles) {
%   if ($title->[0] ne $prevgen) {
%     if ($prevgen) {
</p>
%     }
%     $first = 1;
<h3><%= $genres->{$title->[0]}->[1] %></h3>
<p align="left">
%   }
%   if ($first) {
%     $first = 0;
%   } else {
<br />\
%   }
<a href="<%= $title->[2] %>"><%= $title->[1] %></a>
%   $prevgen = $title->[0];
% }
</p>
</div>
EOF
  close $out;
  open $out, ">", 'page/alltitles.dat' or die "alltitles: $!";
  print $out $mt->render(<<'EOF', $self->composers);
% use lib './lib';
% use Composer;
% use Work;
% my ($composers) = @_;
<div class="column_2" style="float: right; width: 61%;">
<p align="left">
% # Build list of title,link pairs from works lists,
% # sort into title order and output
% my @titles;
% for my $composer (@$composers) {
%   for my $work (@{$composer->works}) {
%      push @titles, [ ucfirst( $work->dwork ? $work->dwork : $work->work), $work->url ];
%   }
% }
% my $first = 1;
% for my $title (sort { $a->[0] cmp $b->[0] } @titles) {
%   if ($first) {
%     $first = 0;
%   } else {
<br />\
%   }
<a href="<%= $title->[1] %>"><%= $title->[0] %></a>
% }
</p>
</div>
EOF
  close $out;
}

sub outputconfig {
  my $self = shift;
  $self->tinyconfig->write( 'new.meta', 'utf8' ); #save page data to 'new.meta' file
}

1;
