% my ($num, $text) = @_;
%= 5 * 5
<!DOCTYPE html>
<html>
  <head><title>More advanced</title></head>
  <body>
    test 123
    foo <% my $i = $num + 2; %>
    % for (1 .. 23) {
    * some text <%= $i++ %>
    % }
    <%= $text %>
  </body>
</html>
