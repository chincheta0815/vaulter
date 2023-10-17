package Plugins::SqueezeCEC::Plugin;

use strict;

use base qw(Slim::Plugin::Base);

use Slim::Utils::Prefs;
use Slim::Utils::Log;

my $prefs = preferences('plugin.squeezecec');

my $log = Slim::Utils::Log->addLogCategory({
	'category'     => 'plugin.squeezecec',
	'defaultLevel' => 'INFO',
	'description'  => 'PLUGIN_SQUEEZECEC',
});

sub initPlugin {
	my $class = shift;

#	if ( main::WEBUI ) {
#		require Plugins::SqueezeCEC::PlayerSettings;
#		Plugins::SqueezeCEC::PlayerSettings->new;
#	}

	$class->SUPER::initPlugin(@_);
	# no name can be a subset of others due to a bug in addPlayerClass
	Slim::Networking::Slimproto::addPlayerClass($class, 42, 'squeezecec', { client => 'Plugins::SqueezeCEC::Player', display => 'Slim::Display::NoDisplay' });
	main::INFOLOG && $log->is_info && $log->info("Added class 42 for SqueezeCEC");

}

1;
