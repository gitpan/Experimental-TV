#include "test_tv.h"

test_XPVTC *global_cursor=0;

MODULE = Experimental::TV		PACKAGE = Experimental::TV

PROTOTYPES: ENABLE

void
case_report()
	CODE:
	test_tv_c_CCOV_REPORT();

int
CACHE_TREEFILL(...)
	CODE:
{
#ifdef test_TV_CACHE_TREEFILL
	RETVAL = 1;
#else
	RETVAL = 0;
#endif
}
	OUTPUT:
	RETVAL

test_XPVTV *
new(CLASS)
	char *CLASS;
	CODE:
	RETVAL = test_NEW_XPVTV(0);
	OUTPUT:
	RETVAL

void
test_XPVTV::DESTROY()
	CODE:
	test_free_tv(THIS);

void
test_XPVTV::insert(key, data)
	char *key
	SV *data
	CODE:
	test_tv_insert(THIS, key, &data);

SV *
test_XPVTV::fetch(key)
	char *key
	CODE:
	if (!test_tv_fetch(THIS, key, &RETVAL))
	  RETVAL = &sv_undef;
	OUTPUT:
	RETVAL

void
test_XPVTV::delete(key)
	char *key
	CODE:
	test_tv_delete(THIS, key);

void
test_XPVTV::clear()
	CODE:
	test_tv_clear(THIS);

void
test_XPVTV::stats()
	PPCODE:
	XPUSHs(sv_2mortal(newSViv(test_TvFILL(THIS))));
	XPUSHs(sv_2mortal(newSViv(test_TvMAX(THIS))));

test_XPVTC *
test_XPVTV::new_cursor()
	PREINIT:
	char *CLASS = "Experimental::TV::Remote";
	CODE:
	/* ignore refcnt problem */
	RETVAL = test_NEW_XPVTC(THIS, THIS);
	OUTPUT:
	RETVAL

void
test_XPVTV::dump()
	CODE:
	test_tv_dump(THIS);


MODULE = Experimental::TV		PACKAGE = Experimental::TV::Remote

void
test_XPVTC::DESTROY()
	CODE:
	/* test_free_tc(THIS); be sloppy XXX */

test_XPVTV *
test_XPVTC::focus()
	PREINIT:
	char *CLASS = "Experimental::TV";
	CODE:
	RETVAL = test_TcTV(THIS);
	OUTPUT:
	RETVAL

void
test_XPVTC::delete()
	CODE:
	test_tc_delete(THIS);

void
test_XPVTC::moveto(...)
	PROTOTYPE: $;$
	PREINIT:
	SV *where;
	I32 xto=-2;
	CODE:
	if (items == 1) {
	  xto=-1;
	} else {
	  where = ST(1);
	  if (SvNIOK(where)) { xto = SvIV(where); }
	  else if (SvPOK(where)) {
	    char *wh = SvPV(where, na);
	    if (strEQ(wh, "start")) xto=-1;
	    else if (strEQ(wh, "end")) xto=test_TvFILL(test_TcTV(THIS));
	  } else {
	    croak("TC(%p)->moveto(): unknown location", THIS);
	  }
	}
	if (xto < -1 || xto > test_TvFILL(test_TcTV(THIS)))
	  croak("TC(0x%p)->moveto(%d): out of range('start','end',-1..%d)",
	    THIS, xto, test_TvFILL(test_TcTV(THIS)));
	test_tc_moveto(THIS, xto);

SV *
test_XPVTC::pos()
	PREINIT:
	I32 where;
	PPCODE:
{
#ifdef test_TV_CACHE_TREEFILL
	XPUSHs(sv_2mortal(newSViv(test_tc_pos(THIS))));
#endif
}

SV *
test_XPVTC::where()
	PREINIT:
	I32 where;
	int len;
	char *wh;
	PPCODE:
	wh = test_tc_where(THIS, &len);
	XPUSHs(sv_2mortal(newSVpv(wh, len)));

int
test_XPVTC::seek(key)
	char *key
	CODE:
	RETVAL = test_tc_seek(THIS, key);
	OUTPUT:
	RETVAL

void
test_XPVTC::step(delta)
	int delta
	CODE:
	test_tc_step(THIS, delta);

void
test_XPVTC::each(delta)
	int delta;
	PREINIT:
	char *key;
	SV *out;
	PPCODE:
	test_tc_step(THIS, delta);
	key = test_tc_fetch(THIS, &out);
	if (key) {
	  XPUSHs(sv_2mortal(newSVpv(key,0)));
	  XPUSHs(sv_2mortal(newSVsv(out)));
	}

void
test_XPVTC::fetch()
	PREINIT:
	char *key;
	SV *out;
	PPCODE:
	key = test_tc_fetch(THIS, &out);
	if (key) {
	  XPUSHs(sv_2mortal(newSVpv(key,0)));
	  XPUSHs(sv_2mortal(newSVsv(out)));
	}

void
test_XPVTC::store(data)
	SV *data
	CODE:
	test_tc_store(THIS, &data);

void
test_XPVTC::dump()
	CODE:
	test_tc_dump(THIS);
