use strict;

sub max {
    my @s = @_;
    my $max = 0;
    foreach (@s) { $max = $_ if $_ > $max; }
    return $max;
}

sub min {
    my @s = @_;
    my $min = 9999999;
    foreach (@s) { $min = $_ if $_ < $min; }
    return $min;
}

sub mean {
    my @s = @_;
    my $sum = 0;
    $sum += $_ foreach (@s);
    return $sum / @s;
}

sub percentile {
    my $p = shift;
    my @s = sort { $a <=> $b } @_;
    
    if(@s % 2 == 0) {
        return ($s[@s * $p] + $s[@s * $p + 1]) / 2;
    } else {
        return $s[@s * $p];
    }
}

my @scores;
while(<STDIN>) {
    chomp;
    my ($sys, $score) = split(/\s/, $_);
    push(@scores, $score);
}

printf("%.4f %.4f %.4f %.4f %.4f\n", min(@scores), percentile(0.25, @scores), percentile(0.5, @scores), percentile(0.75, @scores), max(@scores));