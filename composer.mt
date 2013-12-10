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
