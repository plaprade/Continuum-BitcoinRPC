package Continuum::BitcoinRPC::Util;

use base 'Exporter';

our @EXPORT = (qw(
    JSONToAmount
    AmountToJSON
));

# Transform a BTC float into Satoshi integer
sub JSONToAmount {
    sprintf( '%.0f', 1e8 * shift );
}

# Integer to fixed point decimal (BTC)
sub AmountToJSON {
    ( my $value = sprintf( '%.8f', (shift) / 1e8 ) ) =~ s/\.?0+$//;
    $value;
}

1;

