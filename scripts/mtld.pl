use strict;

binmode(STDIN,  ":utf8");
binmode(STDOUT, ":utf8");

my $LANG = $ARGV[0];

sub mtldfw {
    my @tokens = @_;

    return 0 if not @tokens;

    my $factors = 0;
    my $toknum = 0;
    my %types;

    my $ttr;
    foreach my $t (@tokens) {
        $toknum++;
        $types{$t} = 1;

        $ttr = (scalar keys %types) / $toknum;
        if($ttr <= 0.72) {
            $factors++ if($toknum >= 10);
            $toknum = 0;
            %types = ();
        }
    }

    # if all token are uniq MTLD is INF, let's pretend there is one repeated token
    if($factors == 0 and $ttr == 1) {
        $ttr = (@tokens - 1) / @tokens;
    }

    my $remain = (1 - $ttr) / (1 - 0.72);
    my $num = ($factors + $remain);

    my $mtld = @tokens / $num;
    return $mtld;
}

sub mtld {
    return (mtldfw(@_) + mtldfw(reverse @_)) / 2;
}

sub min {
    my ($a, $b) = @_;
    return $a < $b ? $a : $b;
}

my @tokens;
while(<STDIN>) {
    chomp;
    $_ = lc($_);

    my @lineTokens = /(\p{L}+)/g;
    if($LANG eq "zh") {
        @lineTokens = map { if(/[a-z]/) { $_ } else { my @t = /(.)/g; @t } } @lineTokens;
    }

    push(@tokens, @lineTokens);
}

printf("%.4f\n", mtld(@tokens));
