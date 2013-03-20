# NAME

Continuum::BitcoinRPC - Asynchronous BitcoinRPC client

# DESCRIPTION

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
        username => 'rpc\_username',
        password => 'rpc\_password',
    );

    # Blocking call
    my $balance = $client->get\_balance->recv;

    # Non-blocking call
    $client->get\_balance->then( sub {
        my $balance = shift;
    });

    # Underscores and case are ignored. These are equivalent:
    $client->get\_balance;
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
call to Continuum::BitcoinRPC returns a Portal, so you can write this:

```perl
    use Continuum;

    $client->GetBalance( 'fred' )
        ->merge( $client->GetAccountAddress( 'fred' ) )
        ->then( sub {
            my ( $balance, $account ) = @\_;
            ...
        });
```

GetBalance and GetAccountAddress are computed in parallel. Once both
of them are completed, the callback in `then` is called with the
values. 

Please head to the [Continuum](http://github.com/ciphermonk/Continuum)
project page for more details.

## Bugs

Please report any bugs in the projects bug tracker:

[http://github.com/ciphermonk/Continuum-BitcoinRPC/issues](http://github.com/ciphermonk/Continuum-BitcoinRPC/issues)

You can also submit a patch.

## Contributing

We're glad you want to contribute! It's simple:

- Fork Continuum::BitcoinRPC
- Create a branch `git checkout -b my\_branch`
- Commit your changes `git commit -am 'comments'`
- Push the branch `git push origin my\_branch`
- Open a pull request

## Installing

These are the modules on which this one depends:

- [My fork of AnyEvent::JSONRPC](https://github.com/ciphermonk/anyevent-jsonrpc-perl)
- [Continuum](https://github.com/ciphermonk/Continuum)
- [Moose](https://metacpan.org/module/Moose)
- [namespace::autoclean](https://metacpan.org/module/namespace::autoclean)
- [EV](https://metacpan.org/module/EV) (for testing)
- [Test::Bitcoin::Daemon](https://github.com/eroot/perl-test-bitcoind)
(for testing)

In order to run tests, [bitcoind](http://bitcoin.org) must be available in the application search path.

## Supporting

Like what you see? You can support the project by donating in
[Bitcoins](http://www.weusecoins.com/) to:

__17YWBJUHaiLjZWaCyPwcV8CJDpfoFzc8Gi__