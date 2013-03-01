use strict;
use warnings;

use EV;
use Test::More;
use Data::Dumper;

BEGIN { 
    use_ok( 'Continuum' ); 
    use_ok( 'Continuum::BitcoinRPC' ); 
    use_ok( 'Continuum::BitcoinRPC::Util', qw( AmountToJSON JSONToAmount ) ); 
    use_ok( 'Test::Bitcoin::Daemon' );
}

my $bitcoind = new Test::Bitcoin::Daemon;

my $client = Continuum::BitcoinRPC->new(
    url => $bitcoind->url,
    username => $bitcoind->username,
    password => $bitcoind->password,
);

subtest rpc_client => sub {

    plan tests => 9;

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

};

subtest AmountToJSON => sub {

    plan tests => 4;

    cmp_ok( AmountToJSON( 1 ), '==', 0.00000001,
        'AmountToJSON 1 satoshi' );

    cmp_ok( AmountToJSON( 100010000 ), '==', , 1.0001,
        'AmountToJSON 4 digit precision' );

    cmp_ok( AmountToJSON( 100001 ), '==', 0.00100001,
        'AmountToJSON 8 decimal precision' );

    cmp_ok( AmountToJSON( 2100000000000000 ), '==', 21000000,
        'AmountToJSON 21 million coins' );
};

subtest JSONToAmount => sub {

    plan tests => 7;

    cmp_ok( JSONToAmount( 0.00000001 ), '==', 1,
        'JSONToAmount 1 satoshi' );

    cmp_ok( JSONToAmount( 0.000000006 ), '==', 1,
        'JSONToAmount round to 1 satoshi' );

    cmp_ok( JSONToAmount( 0.000000004 ), '==', 0,
        'JSONToAmount round to 0 satoshi' );

    cmp_ok( JSONToAmount( 1.0001 ), '==', , 100010000,
        'JSONToAmount 4 digit precision' );

    cmp_ok( JSONToAmount( 0.00100001 ), '==', 100001,
        'JSONToAmount 8 decimal precision' );

    cmp_ok( JSONToAmount( 21000000 ), '==', 2100000000000000,
        'JSONToAmount 21 million coins' );

    # 1.1 + 2.2 == 3.3 fails in perl due to float point precision
    # Working with satoshi integer fixes this issue
    cmp_ok( JSONToAmount( 1.1 + 2.2 ), '==', 330000000,
        'JSONToAmount 1.1 + 2.2 = 3.3' );
};

done_testing;
