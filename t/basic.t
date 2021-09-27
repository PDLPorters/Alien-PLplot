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
	like $version, qr/^(\d+)\.(\d+)\.(\d+)$/;

	free($buffer);
};

done_testing;
