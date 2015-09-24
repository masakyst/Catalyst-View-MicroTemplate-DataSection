package Catalyst::View::MicroTemplate::DataSection;
use Moose;
use Encode;
use Text::MicroTemplate::DataSection;
use namespace::autoclean;

our $VERSION = "0.01";

extends 'Catalyst::View';
with 'Catalyst::Component::ApplicationAttribute';

has context => (
    is  => 'rw',
    isa => 'Catalyst',
);

has content_type => (
    is      => 'ro',
    isa     => 'Str',
    default => 'text/html'
);

has charset => (
    is      => 'rw',
    isa     => 'Str',
    default => 'UTF-8'
);

has encode_body => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
);

has template_extension => (
    is      => 'ro',
    isa     => 'Str',
    default => '.mt',
);

has engine => (
    is         => 'ro',
    isa        => 'Text::MicroTemplate::DataSection',
    lazy_build => 1,
);


use Data::Dumper;

sub ACCEPT_CONTEXT {
    my ($self, $c) = @_; 
    $self->context($c);
    return $self;
}

sub _build_engine {
    my ($self) = @_;
    return Text::MicroTemplate::DataSection->new(package => $self->context->action->class);
}

sub render {
    my ($self, $c, $template) = @_;
    return $self->engine->render($template.$self->template_extension, $c->stash);
}

sub process {
    my ($self, $c) = @_;

    my $template = $c->stash->{template} || $c->action->name;
    my $body     = $self->render($c, $template);

    my $res = $c->response;
    if (! $res->content_type) {
        $res->content_type('text/html; charset=' . $self->charset);
    }   

    if ( $self->encode_body ) { 
        $res->body(encode($self->charset, $body));
    }   
    else {
        $res->body( $body );
    }   
}

__PACKAGE__->meta->make_immutable();


1;
__END__

=head1 NAME

Catalyst::View::MicroTemplate::DataSection - Text::MicroTemplate::DataSection View For Catalyst

=head1 SYNOPSIS


=head1 DESCRIPTION

    package MyApp::View::MicroTemplate::DataSection;
    use Moose;
    extends 'Catalyst::View::MicroTemplate::DataSection';

    1;

=head1 LICENSE

Copyright (C) Masaaki Saito.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Masaaki Saito E<lt>masakyst.public@gmail.comE<gt>

=cut

