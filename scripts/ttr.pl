use strict;

binmode(STDIN,  ":utf8");
binmode(STDOUT, ":utf8");

my $LANG = $ARGV[0];

my %types;
my $toknum = 0;
while(<STDIN>) {
    chomp;
    $_ = lc($_);
    
    my @tokens = /(\p{L}+)/g;
    if($LANG eq "zh") {
        @tokens = map { if(/[a-z]/) { $_ } else { my @t = /(.)/g; @t } } @tokens;
    }

    foreach my $t (@tokens) {
        $toknum++;
        $types{$t} = 1;
    }
    
}
printf("%.4f\n", (scalar keys %types) / $toknum);
