# -*-perl-*- please

BEGIN { print "1..31\n"; }
END { print "not ok 1\n" if !$test; }

use lib './t';
use test;
use strict;

print "ok 1\n"; ++$test;

#--------------------------------------

sub null_test {
    my $o = shift->new;

    ok(!defined $o->fetch('bogus'));
    $o->delete('bogus');

    $o->new_cursor; #make sure we delete one
    my $c = $o->new_cursor;

    eval { $c->step(0); };
    ok($@ =~ m'step by zero');
    undef $@;
    eval { $c->store('oops') };
    ok($@ =~ m'unset cursor');
    undef $@;

    ok(!$c->seek('bogus'));
    ok($c->where eq 'start');
    ok(!defined $c->each(1));
    ok($c->where eq 'start');

    for (1..3) { $o->insert($_, $_); }

    $c->moveto(-1);
    ok(!$o->CACHE_TREEFILL() or $c->pos()==-1);
    $c->seek(1.5);
    if ($o->CACHE_TREEFILL()) {
	eval { $c->pos() };
	ok($@ =~ m'unpositioned') or warn $@;
	undef $@;
    } else {
	ok(1);
    }
    ok($c->where() eq 'mid') or warn $c->where;

    ok(!defined $o->fetch('bogus'));
    $o->delete('bogus');
}

#--------------------------------------

sub easy_test {
    my $o = shift->new;
    $o->insert('chorze', 'fwaz');
    $o->insert('fwap', 'fwap');
    $o->insert('snorf', 'snorf');
    
    my $c = $o->new_cursor;
    ok($c->seek('snorf'));
    my @r = $c->fetch();
    ok($r[0] eq 'snorf') or warn $r[0];
    ok($r[1] eq 'snorf') or warn $r[1];

    $c->store('borph');
    @r = $c->fetch();
    ok($r[0] eq 'snorf' and $r[1] eq 'borph') or warn @r;
    
    $c->step(1);
    ok(!defined $c->fetch());
    $c->step(-1);
    @r = $c->fetch();
    ok($r[0] eq 'snorf' and $r[1] eq 'borph') or warn @r;

    for (qw(a chorze fwap snorf)) { $o->delete($_); }
    ok(($o->stats)[0]==0 and ($o->stats)[1]==0) or warn $o->stats;

    eval { $c->fetch() };
    ok($@ =~ m'out of sync') or warn $@;
    undef $@;
}

#--------------------------------------

# make non-recursive XXX
sub permute {
    my (@a) = @_;
    return (\@a) if @a == 1;
    my @r;
    my $last;
    for (my $c=0; $c < @a; $c++) {
	my @copy = @a;
	$last = splice(@copy, $c, 1);
	for my $rest (permute(@copy)) {
	    push(@$rest, $last);
	    push(@r, $rest);
	}
    }
    @r;
}

sub insert_test {
    my $o = shift->new;
    my $c = $o->new_cursor;
    for my $e (permute(qw/a b c d e a b/)) {
#	warn @$e;
	for my $kv (@$e) {
	    $o->insert($kv, $kv);
#	    $o->dump;
	}
	$c->moveto('start');
	my @done;
	while (my ($k,$v) = $c->each(1)) {
#	    warn "$k\n";
	    push(@done, $k);
	}
	die @done if join('',@done) ne 'aabbcde';
	$o->clear;
    }
    ok(1);
}

sub insert2_test {
    my $o = shift->new;
    my $c = $o->new_cursor;

    # keep position & direction across splits?
    for (1..4) { $c->insert($_,$_); }
    $c->moveto(3);
    $c->step(-1);
    $c->insert(5,5);
    $c->step(-1);
    ok($c->pos() == 1);

    $o->clear;
    $c->moveto(-1);
    for (1..4) { $c->insert($_,$_); }
    $c->moveto(2);
    $c->insert(5,5);
    $c->step(1);
    ok($c->pos() == 3);

    # is treecache updated if top node splits?
    $c->step(-1);
    for (6..9) { $c->insert($_,$_); }
    ok(1);
}

#--------------------------------------

sub cursor_test {
    my $o = shift->new;
    my @e = qw(a b c d e f g h i j k l m n o p q r s t u v w x y z);
    my $max = $#e;
    for (@e) { $o->insert($_, $_); }

    # forward
    my $c = $o->new_cursor;
    $c->moveto('start');
    for (my $r=0; $r <= @e+2; $r++) {
	my @r=();
	for (my $s=0; $s <= $r; $s++) {
	    push(@r, ($c->each(1))[0]);
	}
	for (my $s=0; $s <= $r; $s++) { 
	    push(@r, ($c->each(-1))[0]);
	}
	my $mess1 = join('',@r);
	my @tmp = (@e[0..$r], reverse(@e[0..($r-1)]));
	my $mess2 = join('', map {defined $_? $_ : '' } @tmp);
	if ($mess1 ne $mess2) {
	    die "Expecting '$mess2', got '$mess1'";
	}
#	warn "$mess1\n";
    }
    ok(1);

    # backward
    $c->moveto('end');
    for (my $r=0; $r <= @e+2; $r++) {
	my @r=();
	for (my $s=0; $s <= $r; $s++) {
	    push(@r, ($c->each(-1))[0]);
#	    warn "each-1\n"; $c->dump;
	}
	for (my $s=0; $s <= $r; $s++) { 
	    push(@r, ($c->each(1))[0]);
#	    warn "each1\n"; $c->dump;
	}
	my $mess1 = join('',@r);
	my $ex = $max-$r;
	my $mess2 = join('', reverse(@e[($ex<0?0:$ex)..$max]),
			 @e[($ex+1<0?0:$ex+1)..$max]);
	if ($mess1 ne $mess2) {
	    die "Expecting '$mess2', got '$mess1'";
	}
#	warn "$mess1\n";
    }
    ok(1);
}

#--------------------------------------

sub seek_test {
    my $o = shift->new;
    my @l1 = qw/b c d e f g h i j k/;
    my @l2 = qw/l m n o p q r s t u v/;
    for my $e (reverse @l1) { $o->insert($e,$e); }
    for my $e (@l2) { $o->insert($e,$e); }
    my $c = $o->new_cursor;

    my @all = ('a',@l1,@l2);
    for (my $t=0; $t < @all; $t++) {
	$c->seek("$all[$t]+");
#	$o->dump;
#	warn "seek $all[$t]+";
#	$c->dump;
	$c->step(-1);
#	warn "step -1";
#	$c->dump;
	if ($t == 0) {
	    die $t if $c->fetch() || $c->where() ne 'start';
	} else {
	    die $t if ($c->fetch())[1] ne $all[$t];
	}
    }
    for (my $t=0; $t < @all; $t++) {
	$c->seek("$all[$t]+");
#	$o->dump;
#	warn "seek $all[$t]+";
#	$c->dump;
	$c->step(1);
#	warn "step 1";
#	$c->dump;
	if ($t == @all-1) {
	    die $t if $c->fetch() || $c->where() ne 'end';
	} else {
	    die $t if ($c->fetch())[1] ne $all[$t+1];
	}
    }
}

#--------------------------------------

sub delete_test {
    # delete just one element
    my $o = shift->new;
    my $c = $o->new_cursor;
    for my $targ (-10 .. 10) {
	$o->clear;
	for (my $n=1; $n < 10; $n += 2) {
	    $o->insert("$n", $n); 
	    $o->insert("-$n", -$n);
	}
	for (my $n=2; $n <= 10; $n += 2) {
	    $o->insert("$n", $n); 
	    $o->insert("-$n", -$n);
	}
	$o->insert(0,0);
	$c->seek($targ);
	my $pos = $c->pos();
	$c->delete();
	# 9 is the last element due to strcmp
	if ($o->CACHE_TREEFILL() and
	    $c->pos() != ($targ==9? -1 : $pos)) {
	    $o->dump;
	    $c->dump;
	    die "deleted $targ at $pos: moved to ".$c->pos();
	}
	for my $n (-10 .. 10) {
#	    $c->seek($n);
#	    my $got = ($c->fetch())[1];
	    my $got = $o->fetch($n);
	    if ($n != $targ) {
		if ($got != $n) {
		    $o->dump;
#		    $c->dump;
		    die "$targ: got $got, expected $n";
		}
	    } else {
		if ($got) {
		    die "$targ: got $got, expected () at $n";
		}
	    }
	}
    }
    ok(1);
}

sub delete_test2 {
    # delete all elements 1-by-1
    my $o = shift->new;
    my $sz = 12;
    my $mk = sub {
	$o->clear;
	for (my $n=1; $n < $sz; $n += 2) {
	    $o->insert("$n", $n);$o->insert("-$n", $n);
	}
	for (my $n=2; $n <= $sz; $n += 2){
	    $o->insert("$n",-$n);$o->insert("-$n",-$n);
	}
	$o->insert(0,0);
    };
    $mk->();
    for my $n (-$sz .. $sz) {
#	warn $n;
	$o->delete($n);
	my @what = $o->keys();
	my @guess = sort (($n+1)..$sz);
	die "@what ne @guess" if "@what" ne "@guess";
    }
    $mk->();
    for (my $n=$sz; $n >= -$sz; $n--) {
	$o->delete($n);
	my @what = $o->keys();
	my @guess = sort (-$sz .. ($n-1));
	die "@what ne @guess" if "@what" ne "@guess";
    }
    ok(1);
}

#--------------------------------------

sub moveto_test {
    my $o = shift->new;
    return ok(1) if !$o->CACHE_TREEFILL();
    for my $n (45..90) { $o->insert("$n", $n); }
    for my $n (10..44) { $o->insert("$n", $n); }
    my $c = $o->new_cursor;
    for my $n (10..90) {
	$c->moveto($n-10);
	if (($c->fetch)[0] != $n) {
	    $o->dump;
	    $c->dump;
	    die $n;
	}
    }
    ok(1);
}

#--------------------------------------

sub multi_test {
    my $o = shift->new;
    $o->clear;
    my $c = $o->new_cursor;
    for (qw/b b c/) { $o->insert($_,$_) }
    $c->seek('b');
    $c->step(-1);
    ok($c->where() eq 'start');

    $o->insert('a','a');
    $c->seek('b');
    $c->step(-1);
    ok(($c->fetch())[1] eq 'a');
}

# should split to multiple files once the coverage analysis is restartible

my $tv = 'Experimental::TV::Test';

null_test($tv);
easy_test($tv);
insert_test($tv);
insert2_test($tv);
cursor_test($tv);
seek_test($tv);
delete_test($tv);
delete_test2($tv);
moveto_test($tv);
multi_test($tv);

Experimental::TV::Test::case_report();
