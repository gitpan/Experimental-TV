use strict;
package Experimental::TV::Test;

sub keys {
    my ($o) = @_;
    my @k;
    my $c = $o->new_cursor;
    while (my($k,$v) = $c->each(1)) {
	push(@k, $k);
    }
    @k;
}

sub values {
    my ($o) = @_;
    my @v;
    my $c = $o->new_cursor;
    while (my($k,$v) = $c->each(1)) {
	push(@v, $v);
    }
    @v;
}

1;
