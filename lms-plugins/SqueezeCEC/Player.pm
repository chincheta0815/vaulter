package Plugins::SqueezeCEC::Player;

use strict;
use warnings;

use base qw(Slim::Player::SqueezePlay);

use Slim::Utils::Log;
use Slim::Utils::Prefs;

my $plugin_prefs = preferences('plugin.squeezecec');
my $server_prefs = preferences('server');
my $log = logger('plugin.squeezecec');

sub new {
	my $class = shift;
	my $client = $class->SUPER::new(@_);

	return $client;
}

sub model {
	my $client = shift;
	$client->_model;
}

sub modelName { 'SqueezeCEC' }

# Don't mess with Texas:
# Muting, fading aare quite a bunch of Spaghetti...
sub fade_volume {
	my ($client, $fade, $callback, $callbackargs) = @_;

	my $data;

	$data = pack('C', 1);
	$client->sendFrame( 'audf' => \$data );

	if (abs($fade) > 1) {
		$client->SUPER::fade_volume($fade, $callback, $callbackargs);
	}
	else {
		my $vol = abs($server_prefs->client($client)->get('volume'));
		$vol = ($fade > 0) ? $vol : 0;
		$client->volume($vol, -1);
		if ($callback) {
			&{$callback}(@{$callbackargs});
		}
	}

	$data = pack('C', 0);
	$client->sendFrame( 'audf' => \$data );
}

sub mute {
	my $client = shift;
	my $data;

	$client->SUPER::mute();

	my $mute = $server_prefs->client($client)->get('mute');
        $data = pack('C', $mute);
        $client->sendFrame( 'audm' => \$data );
}

sub volume {
	my $client = shift;
	my $newvolume = shift;
	my $temp = shift;

	my $volume;

	if (defined($temp)) {
		if ($temp == -1) {
			$volume = $client->SUPER::volume($newvolume, 1);
		}
		else {
			$newvolume = $server_prefs->client($client)->get('volume');
			$volume = $client->SUPER::volume($newvolume);
		}
	}
	else {
		$volume = $client->SUPER::volume($newvolume, @_);
	}

	return $volume;
}

1;
