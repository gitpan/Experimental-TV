use strict;
package Experimental::TV;

use vars qw($VERSION @ISA @EXPORT);

require Exporter;
require DynaLoader;
require AutoLoader;

@ISA = qw(Exporter DynaLoader);
@EXPORT = qw();
$VERSION = '0.00';

bootstrap Experimental::TV $VERSION;

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

# add tie interfaces



1;
__END__

=head1 NAME

Experimental::TV - Perl Extension to Implement B-Trees

=head1 SYNOPSIS

  use Experimental::TV;

=head1 DESCRIPTION

 TYPE       Speed       Flexibility  Scales     Memory   Keeps-Order
 ---------- ----------- ------------ ---------- -------- ------------
 Arrays     fastest     so-so        not good   min      yes
 Hashes     fast        good         so-so      so-so    no
 B-Trees    medium      silly        big        good     yes

B-Trees are not the best for many niche applications, but
they do have excellent all-terrain performance.

=head1 CURSOR BEHAVIOR

Keys can only be sorted alphabetically in ascending order.  You can
always step through them in reverse to emulate descending. XXX

What happens to the cursor on insert/delete:  like shift/unshift.

=head2 What If The Cursor Is Out Of Sync After A Tree Modification?

Both the cursor and the tree store a version number.  If there is
a mismatch, an exception is thrown.

Complete cursor behavior ridiculously complicated and cannot easily be
explained.

=head1 PERFORMANCE

Tune TnWIDTH

tc_bseek, tc_distance, tc_insert rotation

=head1 PUBLIC SOURCE CODE

The source code is being released in a malleable form to encourage as
much testing as possible.  Bugs in fundemental collections are simply
UNACCEPTABLE and it is hard to trust a single vendor to debug their
code properly.

Get it at http://www.perl.com/CPAN/authors/id/JPRIT/!

=head1 AUTHOR

Copyright (c) 1997 Joshua Nathaniel Pritikin.  All rights reserved.

This package is free software and is provided "as is" without express
or implied warranty.  It may be used, redistributed and/or modified
under the terms of the Perl Artistic License (see
http://www.perl.com/perl/misc/Artistic.html)

=cut
