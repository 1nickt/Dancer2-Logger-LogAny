package Dancer2::Logger::LogAny;


use strict; use warnings; use Data::Dumper; ++$Data::Dumper::Sortkeys;
use Dancer2 qw/ :syntax !log !debug !info !notice !warning !error /;
use Dancer2::Core::Types qw/ Str /;
use Log::Any;
use Moo;
with 'Dancer2::Core::Role::Logger';

has category    => ( is => 'ro', isa => Str );
has _logger_obj => ( is => 'lazy' );

sub _build__logger_obj {
    my $self = shift;

    my $settings = config->{'engines'}->{'logger'}->{'LogAny'};

    if ( $settings->{'logger'} ) {
        require Log::Any::Adapter;
        Log::Any::Adapter->set( @{ $settings->{'logger'} } );
    }

    my %category = exists $settings->{'category'} ?
        ( category => $settings->{'category'} ) : ();

    return Log::Any->get_logger( %category );
}

sub log {
    my ( $self, $level, $message ) = @_;

    $level = 'debug' if $level eq 'core';

    $self->_logger_obj->$level( $message );
}

1; # return true

=head1 NAME

Dancer2::Logger::LogAny - Use Log::Any to control logging from your Dancer2 app

=head1 DESCRIPTION

This module implements a Dancer2 logging engine using C<Log::Any>.
You can then use any C<Log::Any::Adapter>-based output class on the backend.

=head1 CONFIGURATION

In your Dancer2 config:

  logger: LogAny
 
  engines:
      logger:
          LogAny:
              logger:
                  - Stderr
                  - newline
                  - 1

=head1 METHODS

=head2 method_name( )

Method documentation here

=head1 SEE ALSO

C<Log::Any>

=head1 AUTHOR

Nick Tonkin <tonkin@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Nick Tonkin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
