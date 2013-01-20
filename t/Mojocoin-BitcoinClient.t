use strict;
use warnings;

use EV;
use Test::More;
use AnyEventX::CondVar;
use AnyEventX::CondVar::Util qw( :all );
use Data::Dumper;

BEGIN { 
    use_ok( 'Mojocoin::BitcoinClient' ); 
};

my $client = Mojocoin::BitcoinClient->new(
    url => 'http://127.0.0.1:18332',
    username => `echo -n \`cat ../etc/username.key\``,
    password => `echo -n \`cat ../etc/password.key\``,
);

isa_ok( $client, 'Mojocoin::BitcoinClient',
    'Mojocoin::BitcoinClient instance' );

done_testing();


