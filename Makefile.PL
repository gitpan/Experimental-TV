use ExtUtils::MakeMaker;

my @tvlib = qw/tv.code tv.private tv.public tv.sym tv.setup/;

WriteMakefile(
	      NAME		=> 'Experimental::TV',
#	      PREREQ_PM		=> { Data::Dumper => '2.07' },
	      EXE_FILES		=> [qw(tvgen.pl)],
	      OPTIMIZE		=> '-g -DDEBUGGING',

	      VERSION_FROM	=> 'TV.pm',
	      OBJECT		=> 'tvcover.o TV.o',
	      PM		=> { 
				    'TV.pm' => '$(INST_LIBDIR)/TV.pm',
				    (map { $_=>'$(INST_LIBDIR)/TV/'.$_ } @tvlib)
				   },
              dist		=> {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
);

sub MY::postamble {
    '
tvgen.pl :: '.join(' ',@tvlib).'

test_tv.c test_tvpriv.h test_tvpub.h test_tv.h :: $(INST_SCRIPT)/tvgen.pl
	$(PERL) -Mblib $(INST_SCRIPT)/tvgen.pl

tvcover.c :: ccovscan.pl test_tv.c
	$(PERL) ./ccovscan.pl test_tv.c > $@

clean ::
	rm -rf tvcover.* test_tv*

';
}

__END__
