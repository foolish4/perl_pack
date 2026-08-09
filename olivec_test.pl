#!/usr/bin/env perl

use strict;
use warnings;

require "./olivec.pl";

my $WIDTH=800;
my $HEIGHT=600;

my $pixels=[map{[(0)x$WIDTH]}(0..$HEIGHT-1)];

sub main{
	olivec_fill($pixels,$WIDTH,$HEIGHT,0xFF0000FF);
	olivec_save_to_ppm_file($pixels,$WIDTH,$HEIGHT,"output.ppm");
}
main();
