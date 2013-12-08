% my ($sections) = @_;
<table>
<tbody>
% my $prevsec = '';
% for my $section (@$sections) {
%   if ($section->{section} ne $prevsec) {
%   if ($prevsec) {
</tr>
%   }
<tr>
<td><%= ($section->{dwork}) ? $section->{dwork} : $section->{work} %></td>
%   }
<td>
  % if ($section->{ytid}) {
  <a href="http://youtu.be/<%= $section->{ytid} %>?hd=1"> <img style="padding: 0 5px 0 20px;" src="/images/icon_youtube_16x16.gif" alt="Click to view on YouTube" /> </a>
  % }
  <a href="http://drive.google.com/uc?export=view&amp;id=<%= $section->{gdid} %>"><%= ($section->{dpart}) ? $section->{dpart} : ucfirst($section->{part}) %></a>
</td>
% $prevsec = $section->{section};
 % }
</tr>
</tbody>
</table>
