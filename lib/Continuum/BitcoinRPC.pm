package Continuum::BitcoinRPC;

use v5.14;

use Moose;
use namespace::autoclean;

use Continuum;
use AnyEvent::JSONRPC::HTTP::Client;

use version; our $VERSION = version->declare("v0.0.2"); 

has _jsonrpc_client => (
    is => 'ro',
    isa => 'AnyEvent::JSONRPC::HTTP::Client',
);

sub BUILDARGS {
    my $self = shift;
    my %args = (
        url => 'http://127.0.0.1:18332',
        username => '',
        password => '',
        @_
    );

    +{ 
        _jsonrpc_client => AnyEvent::JSONRPC::HTTP::Client->new( 
            url => $args{ url },
            username => $args{ username },
            password => $args{ password },
        )
    };
}

# Valid method calls are defined in the bitcoind API call list
# Valid calls are case-agnostic and ignore underscores:
# $self->getnewaddres(...)
# $self->GetNewAddress(...)
# $self->get_new_address(...)
# are all valid and equivalent calls 
sub AUTOLOAD {
    my ( $self, @args ) = @_;
    my ( $method ) = our $AUTOLOAD =~ m/::(\w+)$/;
    $method =~ s/_//g;
    portal( $self->_jsonrpc_client->call( lc( $method ), @args ) );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 Continuum::BitcoinRPC - Asynchronous BitcoinRPC client

Continuum::BitcoinRPC is a client that interfaces the RPC commands of
the Satoshi bitcoin implementation (L<Satoshi
Node|http://github.com/bitcoin/bitcoin>). It is built on top of the
L<Continuum|http://github.com/ciphermonk/Continuum> framework to
provide a powerful asynchronous API. Continuum::BitcoinRPC is meant to
run within an event loop environment such as L<Mojolicious> or
L<AnyEvent>.

Usage is quite simple:

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

This should get you started quite easily. Note that the library
doesn't check the validity of your commands (yet). So if you're
calling

    $client->hoobahoop

You're essentially trying to call the hoobahoop method through the
JSON RPC interface on bitcoind, which will fail. 

=head2 Continuum

You get access to the Continuum API for free using this module.  Every
call to Continuum::BitcoinRPC return a Portal, so you can write this:

    use Continuum;

    $client->GetBalance( 'fred' )
        ->merge( $client->GetAccountAddress( 'fred' ) )
        ->then( sub {
            my ( $balance, $account ) = @_;
            ...
        });

GetBalance and GetAccountAddress are computed in parallel. Once both
of them are completed, the callback in C<then> is called with the
values. 

Please head to the L<Continuum|http://github.com/ciphermonk/Continuum>
project page for more details.

=cut

