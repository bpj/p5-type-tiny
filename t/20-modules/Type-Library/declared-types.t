=pod

=encoding utf-8

=head1 PURPOSE

Tests that placeholder objects generated by C<< -declare >> work.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2020-2023 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use strict;
use warnings;
use Test::More;
use Test::TypeTiny;

BEGIN {
	package MyTypes;
	
	use Type::Library -base, -declare => 'MyHashRef';
	use Types::Standard -types;
	
	my $tmp     = MyHashRef;
	my $coderef = \&MyHashRef;
	sub get_tmp     { $tmp     }
	sub get_coderef { $coderef }
	
	__PACKAGE__->add_type(
		name    => MyHashRef,
		parent  => HashRef[ Int | MyHashRef ],
	);
};

should_pass( { foo => 1, bar => { quux => 2   } }, MyTypes->get_tmp );
should_fail( { foo => 1, bar => { quux => 2.1 } }, MyTypes->get_tmp );

should_pass( { foo => 1, bar => { quux => 2   } }, MyTypes->get_coderef->() );
should_fail( { foo => 1, bar => { quux => 2.1 } }, MyTypes->get_coderef->() );

isnt( MyTypes->get_coderef, \&MyTypes::MyHashRef, 'coderef got redefined' );

note( MyTypes->get_tmp->inline_check(q/$xyz/) );
note( MyTypes->get_coderef->()->inline_check(q/$xyz/) );

done_testing;
