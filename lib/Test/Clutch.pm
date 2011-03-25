package Test::Clutch;

=head1 NAME

Test::Clutch - add a clutch to your testing drivechain


=head1 SYNOPSIS

   use Test::Clutch;

   # suspend test output
   Test::Clutch::disengage;

   # enable test output again
   Test::Clutch::engage;

   # is the clutch engaged?
   Test::Clutch::engaged ? 'yes' : 'no';
   Test::Clutch::disengaged ? 'no' : 'yes';


=head1 DESCRIPTION

There are many cases where you have a procedure that you might sometimes want
to run in a test-like fashion, and other times just run.  Rather than having
two subroutines, one that emits tests and one that doesn't, doesn't it make
more sense to install a clutch?

C<Test::Clutch> installs a clutch in L<Test::Builder>.  Since C<Test::Builder>
is the base class for a great many test modules, and since it's singleton-ish,
you have a single pedal (most of the time) for engaging and disengaging test
output.

=cut

use 5.006;
use strict;
use warnings;

use Class::MOP;
use Class::MOP::Class;
use Test::Builder;

our $VERSION = '0.01';

my $meta = Class::MOP::Class->initialize('Test::Builder');


=head1 L<Test::Builder> augmentations

C<Test::Clutch> adds an attribute named C<disengaged> to L<Test::Builder>,
as well as C<disengage> and C<engage> methods.

The C<disengaged> attribute actually cannot be initialised, since the
singleton Test::Builder is not created via the MOP; but it is still handy
to create its accessor via the MOP.  This is also the reason the attribute
is called C<disengaged> rather than C<engaged>, the "default" is necessarily
undefined, test output must remain enabled by default.

   $Test->disengaged(1);  # suspend test output
   $Test->disengaged(0);  # enable test output

   $Test->disengage;  # suspend test output
   $Test->engage;     # enable test output

=cut

$meta->add_attribute('disengaged' => (accessor => 'disengaged'));
$meta->add_method('disengage', sub { shift->disengaged(1) });
$meta->add_method('engage', sub { shift->disengaged(undef) });


# simple methods that return 1 on success
foreach (qw/plan done_testing/) {
	$meta->add_around_method_modifier($_, sub {
		my $orig = shift;
		my $self = shift;

		return 1 if $self->disengaged;
		return $self->$orig(@_);
	});
}

# simple methods that return 0 on success
foreach (qw/_print_comment/) {
	$meta->add_around_method_modifier($_, sub {
		my $orig = shift;
		my $self = shift;

		return 0 if $self->disengaged;
		return $self->$orig(@_);
	});
}


=head2   ok

The original ok method is only invoked if the clutch in engaged, but the
C<is_passing> attribute is still set according the first argument.

=cut
$meta->add_around_method_modifier('ok', sub {
	my $orig = shift;
	my $self = shift;

	if ($self->disengaged) {
		$self->is_passing(0) unless $_[0] || $self->in_todo;
		return $_[0] ? 1 : 0;
	}
	# the MOP modifier adds three stack frames
	local $Test::Builder::Level = $Test::Builder::Level + 3;
	return $self->$orig(@_);
});


=head2   child

The child Builder's clutch must be disengaged if the parent (that is, the
invocant) is disengaged; this wrapper takes care of that.

=cut

$meta->add_around_method_modifier('child', sub {
	my $orig = shift;
	my $self = shift;
	# the MOP modifier adds three stack frames
	local $Test::Builder::Level = $Test::Builder::Level + 3;
	my $child = $self->$orig(@_);
	$child->disengaged($self->disengaged);
	return $child;
});


=head1 SUBROUTINES


=head2   engaged

Return true if the clutch is currently engaged, otherwise false.

=cut

sub engaged { !Test::Builder->new->disengaged }


=head2   disengaged

Return true if the clutch is currently disengaged, otherwise false.

=cut

sub disengaged { Test::Builder->new->disengaged }


=head2   disengage

Disable test output.

=cut

sub disengage { Test::Builder->new->disengage }


=head2   engage

Enable test output.

=cut

sub engage { Test::Builder->new->engage }


=head1 AUTHOR

Fraser Tweedale E<lt>frasert@jumbolotteries.comE<gt>


=head1 SEE ALSO

L<Test::Builder> provides the test features that can be enabled/disabled
courtesy of this module.


=head1 COPYRIGHT and LICENSE

Copyright (C) 2011 Jumbo Interactive

This program is free software; you can redistribute it and/or modify it
under the terms of the Artistic License 2.0.

See F<http://www.perlfoundation.org/artistic_license_2_0>

=cut


1;
