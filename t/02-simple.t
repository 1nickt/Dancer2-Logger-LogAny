use strict; use warnings; use Data::Dumper; ++$Data::Dumper::Sortkeys;

use Test::More;

use Plack::Test;
use HTTP::Request::Common;

use Log::Any::Test;
use Log::Any qw/ $log /;

my @levels = ( qw/ debug info warning error / );

{
    package TestApp;
    use Dancer2;
    set logger => 'LogAny';
    set LogAny => { category => 'Blorgle' };

    get '/debug'   => sub { debug 'debug-msg'; return 'debug-msg' };
    get '/info'    => sub { info 'info-msg'; return 'info-msg' };
    get '/warning' => sub { warning 'warning-msg'; return 'warning-msg' };
    get '/error'   => sub { error 'error-msg'; return 'error-msg' };
}
 
my $testapp = TestApp->to_app;

test_psgi $testapp, sub {
    my $cb = shift;

    for my $level ( @levels ) {
        my $url = '/' . $level;
        my $message = $level . '-msg';
        my $res  = $cb->( GET $url );
        ok( $res->is_success,                   "request to $url successful" );
        is( $res->content, $message,            'page content as expected' );

        my $messages = $log->msgs;

        is_deeply(
            pop @{ $messages },
            {
                category => 'Dancer2::Logger::LogAny',
                level    => ( $level eq 'core' ? 'info' : $level ),
                message  => "$level $message"
            },                                  'log content is as expected',
        );

        $log->clear;
    }
};

done_testing;
