#!/usr/bin/env perl

use strict;
use warnings;

sub olivec_fill{
	my ($pixels,$width,$height,$color)=@_;

	for(0..($width*$height)-1){
		$pixels->[$_]=$color;
	}
}
sub olivec_save_to_ppm_file{
	my ($pixels,$width,$height,$file_path)=@_;

	open(my $fh,">:raw",$file_path) or die("can not open file: $!");

	print($fh "P6\n"); 
	print($fh "$width $height\n");
	print($fh "255\n");

	for(0..($width*$height)-1){
		my $pixel=$pixels->[$_];
		my $bytes=[
			($pixel>>8*0)&(0xFF),
			($pixel>>8*1)&(0xFF),
			($pixel>>8*2)&(0xFF)
		    ];
		print($fh pack("C3",$bytes->[0],$bytes->[1],$bytes->[2]));
	}

	close($fh);
}

1;
