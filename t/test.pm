use strict;

package test;
use Carp;
require Experimental::TV;
require Exporter;
use vars  qw(@ISA @EXPORT $test);
@ISA    = qw(Exporter);
@EXPORT = qw(&ok $test);
$test = 1;

sub ok {
    my ($ok, $guess) = @_;
    carp "This is ok $test" if $guess && $guess != $test;
    print(($ok? '':'not ')."ok $test\n");
#    croak $test if !$ok;
    ++ $test;
    $ok;
}

1;
