package Dancer2::Logger::LogAny;
# ABSTRACT: Use Log::Any to log from your Dancer2 app
our $VERSION = '0.9908';

use strict; use warnings;
#use Dancer2 qw/ !log !debug !info !notice !warning !error /;
use Dancer2::Core::Types qw/ Str ArrayRef /;

use Log::Any::Adapter;

use Moo;
with 'Dancer2::Core::Role::Logger';

has category    => ( is => 'ro', isa => Str );
has logger      => ( is => 'ro', isa => ArrayRef, required => 1 );
has _logger_obj => ( is => 'lazy' );

sub _build__logger_obj {
    my $self = shift;

    my %category = $self->category ?
        ( category => $self->category ) : ();

    Log::Any::Adapter->set( @{ $self->logger } );
    return Log::Any->get_logger( %category ); 
}

=method log( @args )

This is the function required by C<Dancer2::Core::Role::Logger>

=cut

sub log {
    my ( $self, $level, $message ) = @_;

    $level = 'debug' if $level eq 'core';

    $self->_logger_obj->$level( $message );
}

1; # return true

=head1 DESCRIPTION

This module implements a Dancer2 logging engine using C<Log::Any>.
You can then use any C<Log::Any::Adapter>-based output class on the backend.

=head1 CONFIGURATION

In your Dancer2 config:

  logger: LogAny
 
  engines:
      logger:
          LogAny:
              category: Important Messages
              logger:
                  - Stderr
                  - newline
                  - 1

If you omit the category setting, C<Log::Any::Adapter> will use the name of
this class as the category.

=head1 SEE ALSO

C<Log::Any>, C<Log::Any::Adapter>, C<Dancer2::Core::Role::Logger>

=cut

