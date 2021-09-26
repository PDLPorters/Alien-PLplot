use Test2::V0;
use Test::Alien;
use Test::Alien::Diag;
use Alien::PLplot;

alien_diag 'Alien::PLplot';
alien_ok 'Alien::PLplot';

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
