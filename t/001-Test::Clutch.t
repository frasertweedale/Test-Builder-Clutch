use strict;
use warnings;

use Test::More;
use Test::Builder;
use Test::Clutch;

plan tests => 11;

ok(1, 'ok() works');

TODO: {
	local $TODO = 'TODO block works';
	fail 'abject failure';
}

subtest 'subtest works' => sub {
	plan tests => 2;
	pass;
	pass;
};

TODO: {
	local $TODO = 'subtest inside TODO';
	subtest 'subtest inside TODO works' => sub {
		plan tests => 2;
		pass;
		fail 'abject failure';
	};
}

TODO: {
	local $TODO = 'subtest inside subtest inside TODO';
	subtest 'subtest inside subtest inside TODO works' => sub {
		plan tests => 2;
		pass;
		subtest 'subtest inside TODO works' => sub {
			plan tests => 2;
			pass;
			fail 'abject failure';
		}
	};
}

Test::Clutch->disengage;
pass 'clutch is disengaged'; # DO NOT COUNT THIS TEST
Test::Clutch->engage;
pass 'clutch is engaged';
ok(Test::Builder->new->is_passing, 'test is still passing');

Test::Clutch->disengage;
fail 'clutch is disengaged'; # DO NOT COUNT THIS TEST
Test::Clutch->engage;
pass 'clutch is engaged';
ok(!Test::Builder->new->is_passing, 'test is no longer passing');


my $Test = Test::Builder->new;

TODO: {
	local $TODO = 'Test::Builder failures inside TODO';

	$Test->ok(0, 'abject failure');

	$Test->subtest('Test::Builder->subtest with failures' => sub {
		$Test->plan(tests => 2);
		$Test->ok(1);
		$Test->ok(0, 'abject failure');
	});
}

