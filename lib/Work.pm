package Work;
use Moo;
use MooX::Types::MooseLike::Base qw(:all);
extends 'MusicData';
has [qw{genre work dwork} ] => (isa => Str, is => 'rw');
has '+layout' => (default => 'work');
has sections => (isa => ArrayRef[InstanceOf['Section']], is => 'rw', default => sub {[]});
sub initfromflds {
  my ($self, $flds) = @_;
  $self->uniqid($flds->{composer}.'-'.$flds->{work});
  $self->label( ($flds->{dcomposer}?$flds->{dcomposer}:ucfirst($flds->{composer})).' - '.
                ($flds->{dwork}?$flds->{dwork}:ucfirst($flds->{work})) );
  $self->title($flds->{composer}.'-'.$flds->{work});
  $self->initurl;
  $self->genre($flds->{genre});
  $self->work($flds->{work});
  $self->dwork($flds->{dwork});
  my $o = Section->new;
  $o->initfromflds($flds);
  push @{$self->sections}, $o;
}

sub tohtml {
  my ($self, $items) = @_;
  my $s;
  $s .= <<EOT;
<table>
<tbody>
EOT
  my $prevsec = '';
  for my $item (@$items) {
    if ($self->work ne $prevsec) {
      if ($prevsec) {
        $s .= <<EOT;
</tr>
EOT
      }
      $s .= <<EOT;
<tr>
EOT
      $s .= '<td>';
      $s .= $self->dwork ? $self->dwork : ucfirst($self->work);
      $s .= <<EOT;
</td>
EOT
    }
  for my $part (@{$item->parts}) {
    $s .= <<EOT;
<td>
EOT
    if ($part->ytid) {
      my $p = $part->ytid;
      $s .= <<EOT;
  <a href="http://youtu.be/$p?hd=1"><img style="padding: 0 5px 0 20px;" src="/images/icon_youtube_16x16.gif" alt="Click to view on YouTube" /></a>
EOT
    }
      my $p = $part->dpart ? $part->dpart : ucfirst($part->part);
      $s .= <<EOT;
  <a href="http://drive.google.com/uc?export=view&amp;id=$p"></a>
EOT
    $s .= <<EOT;
</td>
EOT
    }
    $prevsec = $self->work;
   }
      $s .= <<EOT;
</tr>
</tbody>
</table>
EOT
  return $s;
}
1;

