package Mojocoin::BitcoinClient;

use v5.14.0;

use Moose;
use namespace::autoclean;

use AnyEvent::JSONRPC::HTTP::Client;
use AnyEventX::CondVar;
use AnyEventX::CondVar::Util qw( :all );
use Carp;

use version; our $VERSION = version->declare("v0.0.1"); 

=pod

=head1 Mojocoin::BitcoinClient - Bitcoin client for making JSONRPC calls to bitcoind.

=cut

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
    cv_build { 
        $self->_jsonrpc_client->call( lc( $method ), @args )
    };
}

__PACKAGE__->meta->make_immutable;

1;
