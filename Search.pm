package Plack::App::Search;

use base qw(Plack::Component);
use strict;
use warnings;

use CSS::Struct::Output::Raw;
use Plack::Util::Accessor qw(css generator image_link search_method search_title search_url tags title);
use Tags::HTML::Page::Begin;
use Tags::HTML::Page::End;
use Tags::Output::Raw;
use Unicode::UTF8 qw(decode_utf8 encode_utf8);

our $VERSION = 0.01;

sub call {
	my ($self, $env) = @_;

	$self->_tags;
	$self->tags->finalize;
	my $content = encode_utf8($self->tags->flush(1));

	return [
		200,
		[
			'content-type' => 'text/html; charset=utf-8',
		],
		[$content],
	];
}

sub prepare_app {
	my $self = shift;

	if (! $self->css || ! $self->css->isa('CSS::Struct::Output')) {
		$self->css(CSS::Struct::Output::Raw->new);
	}

	if (! $self->tags || ! $self->tags->isa('Tags::Output')) {
		$self->tags(Tags::Output::Raw->new(
#			'no_simple' => ['img'],
			'xml' => 1,
		));
	}

	if (! $self->generator) {
		$self->generator(__PACKAGE__.'; Version: '.$VERSION);
	}

	if (! $self->title) {
		$self->title('Search page');
	}

	if (! $self->search_method) {
		$self->search_method('get');
	}

	if (! $self->search_title) {
		$self->search_title('SEARCH');
	}

	if (! $self->search_url) {
		$self->search_url('https://env.skim.cz');
	}

	return;
}

sub _css {
	my $self = shift;

	$self->css->put(
		['s', '.outer'],
		['d', 'position', 'fixed'],
		['d', 'top', '50%'],
		['d', 'left', '50%'],
		['d', 'transform', 'translate(-50%, -50%)'],
		['e'],

		['s', '.search'],
		['d', 'text-align', 'center'],
		['d', 'background-color', 'blue'],
		['d', 'padding', '1em'],
		['e'],

		['s', '.search a'],
		['d', 'text-decoration', 'none'],
		['d', 'color', 'white'],
		['d', 'font-size', '3em'],
		['e'],
	);

	return;
}

sub _tags {
	my $self = shift;

	$self->_css;

	Tags::HTML::Page::Begin->new(
		'css' => $self->css,
		'generator' => $self->generator,
		'lang' => {
			'title' => $self->title,
		},
		'tags' => $self->tags,
	)->process;
	$self->tags->put(
		['a', 'class', 'outer'],

		['b', 'div'],
		['a', 'class', 'search'],
		$self->image_link ? (
			['b', 'img'],
			['a', 'src', $self->image_link],
			['e', 'img'],
		) : (),
		['b', 'form'],
		['a', 'method', $self->search_method],
		['b', 'input'],
		['a', 'type', 'text'],
		['e', 'input'],
		['b', 'button'],
		['a', 'href', $self->search_url],
		['d', $self->search_title],
		['e', 'button'],
		['e', 'form'],
		['e', 'div'],
	);
	Tags::HTML::Page::End->new(
		'tags' => $self->tags,
	)->process;

	return;
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Plack::App::Search - Plack search application.

=head1 SYNOPSIS

 use Plack::App::Search;

 my $obj = Plack::App::Search->new(%parameters);
 my $psgi_ar = $obj->call($env);
 my $app = $obj->to_app;

=head1 METHODS

=head2 C<new>

 my $obj = Plack::App::Search->new(%parameters);

Constructor.

Returns instance of object.

=over 8

=item * C<css>

Instance of CSS::Struct::Output object.

Default value is CSS::Struct::Output::Raw instance.

=item * C<generator>

HTML generator string.

Default value is 'Plack::App::Search; Version: __VERSION__'

=item * C<search_method>

Search method.

Default value is 'search'.

=item * C<search_title>

Search title.

Default value is 'SEARCH'.

=item * C<search_url>

Search URL.

Default value is 'https://env.skim.cz'.

=item * C<tags>

Instance of Tags::Output object.

Default value is Tags::Output::Raw->new('xml' => 1) instance.

=item * C<title>

Page title.

Default value is 'Login page'.

=back

=head2 C<call>

 my $psgi_ar = $obj->call($env);

Implementation of search page.

Returns reference to array (PSGI structure).

=head2 C<to_app>

 my $app = $obj->to_app;

Creates Plack application.

Returns Plack::Component object.

=head1 EXAMPLE

 use strict;
 use warnings;

 use CSS::Struct::Output::Indent;
 use Plack::App::Search;
 use Plack::Runner;
 use Tags::Output::Indent;

 # Run application.
 my $app = Plack::App::Search->new(
         'css' => CSS::Struct::Output::Indent->new,
         'tags' => Tags::Output::Indent->new(
                 'preserved' => ['style'],
                 'xml' => 1,
         ),
 )->to_app;
 Plack::Runner->new->run($app);

 # Output:
 # HTTP::Server::PSGI: Accepting connections at http://0:5000/

 # > curl http://localhost:5000/
 # TODO

=head1 DEPENDENCIES

L<CSS::Struct::Output::Raw>,
L<Plack::Util::Accessor>,
L<Tags::HTML::Page::Begin>,
L<Tags::HTML::Page::End>,
L<Tags::Output::Raw>,
L<Unicode::UTF8>.

=head1 REPOSITORY

L<https://github.com/michal-josef-spacek/Plack-App-Search>

=head1 AUTHOR

Michal Josef Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

© 2021-2023 Michal Josef Špaček

BSD 2-Clause License

=head1 VERSION

0.01

=cut
