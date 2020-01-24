use strict;

binmode(STDIN,  ":utf8");
binmode(STDOUT, ":utf8");

my $LANG = $ARGV[0];
my $WORDS = $ARGV[1];
my $SOURCE = $ARGV[2];

my %words;
my %frequent;
if(defined($WORDS) and $LANG eq "en") {
    open(W, "<:utf8", $WORDS);
    while(<W>) {
        chomp;
        my ($w, $c) = split(/\t/, $_);
        if($c >= 5) {
            $words{$w} = 1;
        }
        if($c > 1000) {
            $frequent{$w} = 1;
        }
    }
    close(W);
}

my @source;
if(defined($SOURCE)) {
    open(S, "<:utf8", $SOURCE);
    while(<S>) {
        chomp;
        my @t = /(\p{L}+)/g;
        # what about Chinese?
        push(@source, { map { lc($_) => 1 } @t });
    }
    close(S);
}

my %types;
my $toknum = 0;

while(<STDIN>) {
    chomp;
    $_ = lc($_);
    
    my @lineTokens = /(\p{L}+)/g;
    if($LANG eq "zh") {
        @lineTokens = map { if(/[a-z]/) { $_ } else { my @t = /(.)/g; @t } } @lineTokens;
    }

    # if a source file is present discard infrequent copies
    if(@source) {
        # only use words that are not present in the source or that are frequent in the target language despite that
        # print join("\n", grep { !exists($frequent{$_}) and exists($source[$. - 1]->{$_}) } @lineTokens), "\n";
        @lineTokens = grep { exists($frequent{$_}) or not exists($source[$. - 1]->{$_}) } @lineTokens;

    }

    # if a word count file is available discard very rare words
    if(%words) { 
        # only use words that are seen in the frequency list with occurance 5 and above
        # print join("\n", grep { !exists($words{$_}) } @lineTokens), "\n";
        @lineTokens = grep { exists($words{$_}) } @lineTokens;
    }

    foreach my $t (@lineTokens) {
        $toknum++;
        $types{$t} = 1;
    }
    
}

printf("%.4f\n", (scalar keys %types) / $toknum, scalar keys %types, $toknum);
