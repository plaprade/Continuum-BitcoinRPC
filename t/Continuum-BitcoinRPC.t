use strict;
use warnings;

use EV;
use Test::More;
use Data::Dumper;

my ($rpcuser, $rpcpassword);

BEGIN { 
    my $bitcoinconf = "$ENV{HOME}/.bitcoin/bitcoin.conf";
    open my ($bitcoinfh), $bitcoinconf;
    unless ( $bitcoinfh ) {
        fail "Can't read $bitcoinconf";
        done_testing;
    }
    while ( <$bitcoinfh> ) {
        if ( /^\s*rpcuser=\s*(?<username>.*)/ ) {
            $rpcuser = $+{username};
        } elsif ( /^\s*rpcpassword=\s*(?<password>.*)/ ) {
            $rpcpassword = $+{password};
        }
    }

    unless ( $rpcuser && $rpcpassword ) {
        fail "Bitcoin RPC user or password not found";
        done_testing;
    }

    use_ok( 'Continuum::BitcoinRPC' ); 
    use_ok( 'Continuum' ); 
};

my $client = Continuum::BitcoinRPC->new(
    url => 'http://127.0.0.1:18332',
    username => $rpcuser,
    password => $rpcpassword,
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

done_testing;
