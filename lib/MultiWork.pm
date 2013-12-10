package MultiWork;
use Mojo::Template;
use Moo;
use MooX::Types::MooseLike::Base qw(:all);
extends 'Work';

sub tohtml {
  my $self = shift;
  my $mt = Mojo::Template->new;
  return $mt->render(<<'EOF', $self, $self->sections);
% use lib './lib';
% use MultiWork;
% use Section;
% my ($self, $sections) = @_;
<h2><%= ($self->dwork ? $self->dwork : $self->work) %></h2>
<table>
<tbody>
% my $prevsec = '';
% for my $section (@$sections) {
%   if ($section->section ne $prevsec) {
%   if ($prevsec) {
</tr>
%   }
<tr>
<td><%= ($section->dsection) ? $section->dsection : ucfirst($section->section) %></td>
%   }
% for my $part (@{$section->parts}) {
<td>
  % if ($part->ytid) {
  <a href="http://youtu.be/<%= $part->ytid %>?hd=1"> <img style="padding: 0 5px 0 20px;" src="/images/icon_youtube_16x16.gif" alt="Click to view on YouTube" /> </a>
  % }
  <a href="http://drive.google.com/uc?export=view&amp;id=<%= $part->gdid %>"><%= ($part->dpart) ? $part->dpart : ucfirst($part->part) %></a>
</td>
%   }
% $prevsec = $section->section;
 % }
</tr>
</tbody>
</table>
EOF
}

1;

