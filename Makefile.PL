use ExtUtils::MakeMaker;

my @tvlib = qw/tv.code tv.private tv.public tv.sym tv.setup/;

WriteMakefile(
	      NAME		=> 'Experimental::TV',
	      PREREQ_PM		=> { Text::Balanced => '1.24' },
	      EXE_FILES		=> [qw(tvgen.pl)],
	      OPTIMIZE		=> '-g -DDEBUGGING',

	      VERSION_FROM	=> 'TV.pm',
	      OBJECT		=> 'TV.o tvcover.o hvtv.o',
	      PM		=> { 
				    'TV.pm' => '$(INST_LIBDIR)/TV.pm',
				    'Test.pm' => '$(INST_LIBDIR)/TV/Test.pm',
				    (map { $_=>'$(INST_LIBDIR)/TV/'.$_ } @tvlib)
				   },
              dist		=> {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
);

sub MY::postamble {
    '
tvgen.pl :: pm_to_blib

test_tv.c test_tvpriv.h test_tvpub.h test_tv.h :: $(INST_SCRIPT)/tvgen.pl test_tv.tmpl
	$(PERL) -Mblib $(INST_SCRIPT)/tvgen.pl

tvcover.c :: ccovscan.pl test_tv.c
	$(PERL) ./ccovscan.pl test_tv.c > $@

avtv.c avtvpriv.h avtvpub.h avtv.h :: $(INST_SCRIPT)/tvgen.pl
	$(PERL) -Mblib $(INST_SCRIPT)/tvgen.pl -p av

hvtv.c hvtvpriv.h hvtvpub.h hvtv.h :: $(INST_SCRIPT)/tvgen.pl hvtv.tmpl
	$(PERL) -Mblib $(INST_SCRIPT)/tvgen.pl -p hv

TV.xs :: test_tv.h avtv.h hvtv.h

clean ::
	rm -rf tvcover.* test_tv*.c test_tv*.h avtv*.c avtv*.h hvtv*.c hvtv*.h

';
}

__END__
