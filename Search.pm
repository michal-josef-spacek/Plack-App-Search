package Plack::App::Search;

use base qw(Plack::Component::Tags::HTML);
use strict;
use warnings;

use Plack::Util::Accessor qw(css generator image_link search_method search_title search_url tags title);
use Tags::HTML::Container;

our $VERSION = 0.01;

sub _prepare_app {
	my $self = shift;

	# Defaults which rewrite defaults in module which I am inheriting.
	if (! $self->generator) {
		$self->generator(__PACKAGE__.'; Version: '.$VERSION);
	}

	if (! $self->title) {
		$self->title('Search page');
	}

	# Inherite defaults.
	$self->SUPER::_prepare_app;

	# Defaults from this module.
	if (! $self->search_method) {
		$self->search_method('get');
	}

	if (! $self->search_title) {
		$self->search_title('SEARCH');
	}

	if (! $self->search_url) {
		$self->search_url('https://env.skim.cz');
	}

	$self->{'_container'} = Tags::HTML::Container->new(
		'css' => $self->css,
		'css_inner' => 'search',
		'tags' => $self->tags,
	);

	return;
}

sub _css {
	my $self = shift;

	$self->{'_container'}->process_css;
	if (defined $self->image_link) {
		$self->css->put(
			['s', '.search'],
			['d', 'display', 'flex'],
			['d', 'flex-direction', 'column'],
			['d', 'align-items', 'center'],
			['e'],

			['s', '.search img'],
			['d', 'margin-bottom', '20px'],
			['d', 'margin-left', 'auto'],
			['d', 'margin-right', 'auto'],
			['e'],
		);
	}
	$self->css->put(
		['s', '.search form'],
		['d', 'display', 'flex'],
		['d', 'align-items', 'center'],
		['e'],

		['s', '.search input[type="text"]'],
		['d', 'padding', '10px'],
		['d', 'border-radius', '4px'],
		['d', 'border', '1px solid #ccc'],
		['e'],

		['s', '.search button'],
		['d', 'margin-left', '10px'],
		['d', 'padding', '10px 20px'],
		['d', 'border-radius', '4px'],
		['d', 'background-color', '#4CAF50'],
		['d', 'color', 'white'],
		['d', 'border', 'none'],
		['d', 'cursor', 'pointer'],
		['e'],

		['s', '.search button:hover'],
		['d', 'background-color', '#45a049'],
		['e'],
	);

	return;
}

sub _tags_middle {
	my $self = shift;

	$self->{'_container'}->process(
		sub {
			$self->tags->put(
				$self->image_link ? (
					['b', 'img'],
					['a', 'src', $self->image_link],
					['e', 'img'],
				) : (),
				['b', 'form'],
				['a', 'method', $self->search_method],
				['a', 'action', $self->search_url],
				['b', 'input'],
				['a', 'type', 'text'],
				['a', 'autofocus', 'autofocus'],
				['e', 'input'],
				['b', 'button'],
				['a', 'type', 'submit'],
				['d', $self->search_title],
				['e', 'button'],
				['e', 'form'],
			);
		},
	);

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

L<Plack::Component::Tags::HTML>,
L<Plack::Util::Accessor>,
L<Tags::HTML::Container>.

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
