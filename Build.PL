use Module::Build;
Module::Build->new(
	module_name => 'Test::Clutch',
	license => 'artistic_2',
	requires => {
		'perl' => '5.006',
		'Test::Builder' => '0.98',
		'Class::MOP' => '1.04',
	}
)->create_build_script;
