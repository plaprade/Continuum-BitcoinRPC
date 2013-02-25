use strict;
use warnings;

use EV;
use Test::More;
use Data::Dumper;
use File::Temp qw(tempdir);
use POSIX ":sys_wait_h";
use Cwd;

my ($port, $clicmd);

BEGIN { 
    use_ok( 'Continuum' ); 
    use_ok( 'Continuum::BitcoinRPC' ); 
    use_ok( 'Continuum::BitcoinRPC::Util', qw( AmountToJSON JSONToAmount ) ); 

    my $tmp = tempdir(CLEANUP => 1);
    $port = int(rand 32768) + 32768;
    my $cmd = "bitcoind -testnet -rpcuser=testuser "
        . "-rpcpassword=testpass -rpcport=$port";
    $clicmd = "$cmd -rpcconnect=127.0.0.1";
    my $pid = fork;
    if ($pid == 0) {
        chdir $tmp;
        my $srvcmd = "$cmd -listen=0 -server -datadir='$tmp'";
        exec $srvcmd;
    } elsif ($pid < 0) {
        fail "Could not launch bitcoind";
        done_testing;
        exit;
    }

    $SIG{CHLD} = sub {
        while ((my $child = waitpid(-1, WNOHANG)) > 0) {
            if ($child == $pid) {
                die "bitcoind died";
            }
        }
    };

    sleep 1 while system("$clicmd getinfo 2>/dev/null") != 0;
}

my $client = Continuum::BitcoinRPC->new(
    url => "http://127.0.0.1:$port",
    username => 'testuser',
    password => 'testpass',
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

system "$clicmd stop 2>/dev/null";
wait;

done_testing;
