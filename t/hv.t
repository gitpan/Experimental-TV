# -*-perl-*- please

BEGIN { print "1..5\n"; }

use lib './t';
use test;
use strict;

package Experimental::TV::HV;

sub TIEHASH {
    bless Experimental::TV::HV->new(), shift;
}

sub new_hash {
    my %fake;
    tie %fake, shift;
    \%fake;
}

package main;

my $pkg = 'Experimental::TV::HV';

my $h = $pkg->new_hash;
for (1..5) { $h->{$_} = 2*$_ }
ok($h->{1} == 2);
ok(exists $h->{4});
delete $h->{3};
ok(join('', keys %$h) eq '1245');
ok(join('', values %$h) eq '24810');
%$h = ();
ok(!exists $h->{1});

use Benchmark;

my $hash = {};

print "WARNING: This is not a fair test.\n";
timethese(1,
	  {
	   'tied btree' => sub {
	       for (my $x=0; $x < 20000; $x++) {
		   $h->{$x} = $x;
		   $h->{"-$x"} = -$x;
	       }
	   },
	   'hash' => sub {
	       for (my $x=0; $x < 20000; $x++) {
		   $hash->{$x} = $x;
		   $hash->{"-$x"} = -$x;
	       }
	   },
       });
