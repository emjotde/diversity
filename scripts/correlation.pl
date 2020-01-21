use strict;

sub mean {
    my $x = shift;
    my $sum = 0;
    $sum += $_ foreach(@$x);
    return $sum / @$x;
}

sub correlation {
    my ($x, $y) = @_;
    my $xm = mean($x);
    my $ym = mean($y);

    my $num = 0; my $denom1 = 0; my $denom2 = 0;
    foreach my $i (0 .. @$x - 1) {
        $num    += ($x->[$i] - $xm) * ($y->[$i] - $ym);
        $denom1 += ($x->[$i] - $xm)**2;
        $denom2 += ($y->[$i] - $ym)**2;
    }

    return $num / (sqrt($denom1) * sqrt($denom2));
}

my @x; my @y;
while(<STDIN>) {
    chomp;
    my ($x, $y) = split(/\s/, $_);
    push(@x, $x);
    push(@y, $y);
}

printf("%.4f\n", correlation(\@x, \@y));