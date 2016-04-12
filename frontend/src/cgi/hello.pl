#!/usr/bin/perl
use CGI;
use Biocomp2::Middle;
$cgi = new CGI;
print $cgi->header();
my $x = Biocomp2::Middle::hello();
my %genes = Biocomp2::Middle::get_all_genes();

print <<__EOF;
<html>
<head>
   <title>Hello World!</title>
</head>
<body>
<h1>Hello World! $x</h1>
foreach my $key ( keys %genes )
{
  print "key: <a href="http://www.yahoo.com">$key</a>, \t value: $genes{$key} \n";
}

</body>
</html>
__EOF
