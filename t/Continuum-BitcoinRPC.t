use strict;
use warnings;

use EV;
use Test::More;
use Data::Dumper;

BEGIN { 

    unless(
        -f 'etc/username.key' &&
        -f 'etc/password.key'
    ) {
        diag "Please setup a bitcoin RPC node and put your RPC "
            . "username and password in etc/username.key and "
            . "etc/password.key in this projects folder. Then run "
            . "the test again";
        fail "Test dependencies missing";
        done_testing;
        exit;
    }

    use_ok( 'Continuum::BitcoinRPC' ); 
    use_ok( 'Continuum' ); 
};

my $client = Continuum::BitcoinRPC->new(
    url => 'http://127.0.0.1:18332',
    username => `echo -n \`cat ../etc/username.key\``,
    password => `echo -n \`cat ../etc/password.key\``,
);

isa_ok( $client, 'Continuum::BitcoinRPC',
    'Continuum::BitcoinRPC instance' );

foreach my $method ( qw(
    get_balance
    getbalance
    getBalance
    GetBalance
)){
    cmp_ok( $client->$method->recv, '>=', 0, $method );
}

foreach my $method ( qw (
    get_account_address
    getaccountaddress
    getAccountAddress
    GetAccountAddress
)){
    cmp_ok( $client->$method( '' )->recv, '=~', qr/\w+/, $method );
}

done_testing();


