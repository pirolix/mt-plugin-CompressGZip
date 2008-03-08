package MT::Plugin::OMV::CompressGZip;
#   CompressGZip - Enable zlib compression of the static contents
#           Original Copyright (c) 2007 Piroli YUKARINOMIYA
#           Open MagicVox.net - http://www.magicvox.net/
#           @see http://www.magicvox.net/archive/2007/03041744/

use strict;
use Compress::Zlib;

use vars qw( $MYNAME $VERSION );
$MYNAME = 'CompressGZip';
$VERSION = '1.10';

use base qw( MT::Plugin );
my $plugin = new MT::Plugin ({
        name => $MYNAME,
        version => $VERSION,
        author_name => 'Piroli YUKARINOMIYA',
        author_link => 'http://www.magicvox.net/?'. $MYNAME,
        doc_link => 'http://www.magicvox.net/archive/2007/03041744/?'. $MYNAME,
        description => <<HTMLHEREDOC,
Enable <i>zlib</i> compression of the static contents with
<a href="http://search.cpan.org/~pmqs/Compress-Zlib-2.003/lib/Compress/Zlib.pm">Compress::Zlib</a>
 v.$Compress::Zlib::VERSION
HTMLHEREDOC
});
MT->add_plugin ($plugin);

sub instance { $plugin }

########################################################################
use MT::Template::Context;

### MTCompressGZip
MT::Template::Context->add_container_tag (CompressGZip => \&compress_gzip);
sub compress_gzip {
    my ($ctx, $args, $cond) = @_;
#
    my $builder = $ctx->stash ('builder');
    my $tokens = $ctx->stash ('tokens');
    defined (my $out = $builder->build ($ctx, $tokens, $cond))
        or return $ctx->error ($builder->errstr);

    Compress::Zlib::memGzip ($out);
}

### MTRecommendedEntries
MT::Template::Context->add_container_tag( HTTPCompressGZip => \&http_compress_gzip );
sub http_compress_gzip {
    my ($ctx, $args, $cond) = @_;
#
    my $builder = $ctx->stash ('builder');
    my $tokens = $ctx->stash ('tokens');
    defined (my $out = $builder->build ($ctx, $tokens, $cond))
        or return $ctx->error ($builder->errstr);

    my $app = MT->instance;
    my $accept = $app->get_header( 'Accept-Encoding' );
    if( $accept =~ /\bgzip\b/ ) {
        $app->set_header( 'Content-Encoding', 'gzip' );
        $app->set_header( 'Vary', 'Accept-Encoding' );
        $out = Compress::Zlib::memGzip( $out );
    }

    $out;
}

1;
__END__
########################################################################
# '08/03/08 1.10    HTTPCompressGZipFContent-Encoding GZIP ˆ³k“]‘—
# '07/03/04 1.00    ‰”ÅŒöŠJ
