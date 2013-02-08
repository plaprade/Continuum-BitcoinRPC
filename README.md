# Continuum::BitcoinRPC - Asynchronous BitcoinRPC client

Continuum::BitcoinRPC is a client that interfaces the RPC commands of
the Satoshi bitcoin implementation ([Satoshi Node](http://github.com/bitcoin/bitcoin)). It is built on top of the
[Continuum](http://github.com/ciphermonk/Continuum) framework to
provide a powerful asynchronous API. Continuum::BitcoinRPC is meant to
run within an event loop environment such as [Mojolicious](http://search.cpan.org/perldoc?Mojolicious) or
[AnyEvent](http://search.cpan.org/perldoc?AnyEvent).

Usage is quite simple:

```perl
    use Continuum::BitcoinRPC;

    # Set your RPC username/password in ~/.bitcoin/bitcoin.conf
    my $client = Continuum::BitcoinRPC->new(
        url => 'http://127.0.0.1:18332',
        username => 'rpc_username',
        password => 'rpc_password',
    );

    # Blocking call
    my $balance = $client->get_balance->recv;

    # Non-blocking call
    $client->get_balance->then( sub {
        my $balance = shift;
    });

    # Underscores and case are ignored. These are equivalent:
    $client->get_balance;
    $client->getbalance;
    $client->getBalance;
    $client->GetBalance;
```

This should get you started quite easily. Note that the library
doesn't check the validity of your commands (yet). So if you're
calling

```perl
    $client->hoobahoop
```

You're essentially trying to call the hoobahoop method through the
JSON RPC interface on bitcoind, which will fail. 

## Continuum

You get access to the Continuum API for free using this module.  Every
call to Continuum::BitcoinRPC return a Portal, so you can write this:

```perl
    use Continuum;

    $client->GetBalance( 'fred' )
        ->merge( $client->GetAccountAddress( 'fred' ) )
        ->then( sub {
            my ( $balance, $account ) = @_;
            ...
        });
```

GetBalance and GetAccountAddress are computed in parallel. Once both
of them are completed, the callback in `then` is called with the
values. 

Please head to the [Continuum](http://github.com/ciphermonk/Continuum)
project page for more details.
