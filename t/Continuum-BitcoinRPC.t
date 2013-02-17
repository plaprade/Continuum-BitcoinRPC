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
    use_ok( 'Continuum::BitcoinRPC' ); 
    use_ok( 'Continuum' ); 

    my $tmp = tempdir(CLEANUP => 1);
    $port = int(rand 32768) + 32768;
    my $cmd = "bitcoind -testnet -rpcuser=test -rpcpassword=test -rpcport=$port";
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
    username => 'test',
    password => 'test',
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

system "$clicmd stop 2>/dev/null";
wait;
done_testing;
