package Alien::PLplot;

use strict;
use warnings;
use base qw( Alien::Base );
use 5.008004;

sub inline_auto_include {
	return  [ 'plplot.h' ];
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
