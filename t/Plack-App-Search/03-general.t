use strict;
use warnings;

use CSS::Struct::Output::Indent;
use HTTP::Request;
use Plack::App::Search;
use Plack::Test;
use Tags::Output::Indent;
use Test::More 'tests' => 4;
use Test::NoWarnings;

# Test.
my $app = Plack::App::Search->new;
my $test = Plack::Test->create($app);
my $res = $test->request(HTTP::Request->new(GET => '/'));
my $right_ret = <<"END";
<!DOCTYPE html>
<html lang="en"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><meta name="generator" content="Plack::App::Search; Version: $Plack::App::Search::VERSION" /><meta name="viewport" content="width=device-width, initial-scale=1.0" /><title>Search page</title><style type="text/css">
*{box-sizing:border-box;margin:0;padding:0;}.container{display:flex;align-items:center;justify-content:center;height:100vh;}.search{text-align:center;background-color:blue;padding:1em;}.search a{text-decoration:none;color:white;font-size:3em;}
</style></head><body><div class="container"><div class="search"><form method="get"><input type="text" /><button href="https://env.skim.cz">SEARCH</button></form></div></div></body></html>
END
chomp $right_ret;
my $ret = $res->content;
is($ret, $right_ret, 'Get default main page in raw mode.');

# Test.
$app = Plack::App::Search->new(
	'css' => CSS::Struct::Output::Indent->new,
	'tags' => Tags::Output::Indent->new(
		'preserved' => ['style'],
		'xml' => 1,
	),
);
$test = Plack::Test->create($app);
$res = $test->request(HTTP::Request->new(GET => '/'));
$right_ret = <<"END";
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="generator" content="Plack::App::Search; Version: $Plack::App::Search::VERSION" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>
      Search page
    </title>
    <style type="text/css">
* {
	box-sizing: border-box;
	margin: 0;
	padding: 0;
}
.container {
	display: flex;
	align-items: center;
	justify-content: center;
	height: 100vh;
}
.search {
	text-align: center;
	background-color: blue;
	padding: 1em;
}
.search a {
	text-decoration: none;
	color: white;
	font-size: 3em;
}
</style>
  </head>
  <body>
    <div class="container">
      <div class="search">
        <form method="get">
          <input type="text" />
          <button href="https://env.skim.cz">
            SEARCH
          </button>
        </form>
      </div>
    </div>
  </body>
</html>
END
chomp $right_ret;
$ret = $res->content;
is($ret, $right_ret, 'Get default main page in indent mode.');

# Test.
$app = Plack::App::Search->new(
	'css' => CSS::Struct::Output::Indent->new,
	'generator' => 'Foo',
	'search_url' => 'https://example.com',
	'search_title' => 'Bar',
	'tags' => Tags::Output::Indent->new(
		'preserved' => ['style'],
		'xml' => 1,
	),
	'title' => 'Foo',
);
$test = Plack::Test->create($app);
$res = $test->request(HTTP::Request->new(GET => '/'));
$right_ret = <<'END';
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="generator" content="Foo" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>
      Foo
    </title>
    <style type="text/css">
* {
	box-sizing: border-box;
	margin: 0;
	padding: 0;
}
.container {
	display: flex;
	align-items: center;
	justify-content: center;
	height: 100vh;
}
.search {
	text-align: center;
	background-color: blue;
	padding: 1em;
}
.search a {
	text-decoration: none;
	color: white;
	font-size: 3em;
}
</style>
  </head>
  <body>
    <div class="container">
      <div class="search">
        <form method="get">
          <input type="text" />
          <button href="https://example.com">
            Bar
          </button>
        </form>
      </div>
    </div>
  </body>
</html>
END
chomp $right_ret;
$ret = $res->content;
is($ret, $right_ret, 'Get main page with changed values.');
