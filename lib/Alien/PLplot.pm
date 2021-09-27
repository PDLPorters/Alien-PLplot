package Alien::PLplot;

use strict;
use warnings;
use base qw( Alien::Base );
use File::Spec;
use 5.008004;

sub inline_auto_include {
	return  [ 'plplot.h' ];
}

sub _fix_libs_flags {
	my ($class, $libs_flags) = @_;
	if( $class->install_type('share') ) {
		my $lib_dir = File::Spec->catfile( $class->dist_dir, 'lib' );
		$lib_dir =~ s,\\,/,g if $^O eq 'MSWin32';
		$libs_flags =~ s/(^|\s)-Llib\b/$1-L$lib_dir/g;
	}
	return $libs_flags;
}

sub libs {
	my $class = shift;
	my $libs = $class->SUPER::libs(@_);
	return $class->_fix_libs_flags($libs);
}
sub libs_static {
	my $class = shift;
	my $libs = $class->SUPER::libs_static(@_);
	return $class->_fix_libs_flags($libs);
}

1;
__END__
# ABSTRACT: Alien package for the PLplot plotting library

=head1 DESCRIPTION

This distribution provides PLplot so that it can be used by other
Perl distributions that are on CPAN.  It does this by first trying to
detect an existing install of PLplot on your system.  If found it
will use that.  If it cannot be found, the source code will be downloaded
from the internet and it will be installed in a private share location
for the use of other modules.

=head1 SEE ALSO

=over 4

=item L<Alien>

Documentation on the Alien concept itself.

=item L<Alien::Base>

The base class for this Alien.

=item L<PLplot|http://plplot.sourceforge.net/>

=back

=cut
