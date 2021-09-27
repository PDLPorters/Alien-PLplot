use Test2::V0;
use Test::Alien;
use Test::Alien::Diag;
use Alien::PLplot;

use Env qw(@LD_LIBRARY_PATH @DYLD_FALLBACK_LIBRARY_PATH @PATH);
use DynaLoader;
use File::Basename qw(dirname);

alien_diag 'Alien::PLplot';
alien_ok 'Alien::PLplot';

if( Alien::PLplot->install_type('share') ) {
	my $rpath = dirname( ( Alien::PLplot->dynamic_libs )[0] );
	unshift @LD_LIBRARY_PATH, $rpath;
	unshift @DYLD_FALLBACK_LIBRARY_PATH, $rpath;
	unshift @PATH, $rpath;
	unshift @DynaLoader::dl_library_path, $rpath;
	# load shared object dependencies
	for my $lib ( qw(-lcsirocsa -lqsastime -lplplot) ) {
		my @files = DynaLoader::dl_findfile($lib);
		DynaLoader::dl_load_file($files[0]) if @files;
	}
}

my $version_re = qr/^(\d+)\.(\d+)\.(\d+)$/;

my $xs = do { local $/; <DATA> };
xs_ok $xs, with_subtest {
	my($module) = @_;
	like $module->version, $version_re;
};

ffi_ok { symbols => ['c_plgver'] }, with_subtest {
	my ($ffi) = @_;
	eval q{
		use FFI::Platypus::Memory qw( malloc free );
		use FFI::Platypus::Buffer qw( scalar_to_buffer );
		1; } or skip "$@";
	my $get_version = $ffi->function( c_plgver => ['opaque'] => 'void' );

	my $buffer = malloc(80);
	$get_version->call($buffer);
	my $version = $ffi->cast( 'opaque' => 'string', $buffer );

	note "version: $version";
	like $version, $version_re;

	free($buffer);
};

done_testing;
__DATA__
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <string.h>
#include <plplot.h>

SV*
version(const char *class)
{
	char ver[80];
	c_plgver(ver);

	SV* ver_sv = newSVpv( ver, strlen(ver) );

	return ver_sv;
}

MODULE = TA_MODULE PACKAGE = TA_MODULE

SV* version(class);
	const char *class;
