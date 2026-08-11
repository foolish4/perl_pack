#!/usr/bin/env perl

use strict;
use warnings;

require "./olivec.pl";

my $WIDTH=800;
my $HEIGHT=600;

my $COLS=8;
my $ROWS=6;
my $CELL_WIDTH=($WIDTH/$COLS);
my $CELL_HEIGHT=($HEIGHT/$ROWS);
my $BACKGROUND_COLOR=0xFF202020; #STOP AT HERE 45:23

sub olivec_fill_rect{
	my ($pixels,$pixels_width,$pixels_height,$x0,$y0,$w,$h,$color)=@_;

	for my $dy (0..$h-1){
		my $y=$y0+$dy;
		if(0<=$y && $y<$pixels_height){
			for my $dx (0..$w-1){
				my $x=$x0+$dx;
				if(0<=$x && $x<$pixels_width){
					$pixels->[$y*$pixels_width+$x]=$color;
				}
			}
		}
	}
}

my $pixels;
for(0..($WIDTH*$HEIGHT)-1){
	$pixels->[$_]=0;
}

sub main{
	olivec_fill($pixels,$WIDTH,$HEIGHT,$BACKGROUND_COLOR);

	for my $y (0..$ROWS-1){
		for my $x (0..$COLS-1){
			my $color;
			if(($x+$y)%2==0){
				$color=0xFF0000FF;
			}
			else{
				$color=0xFF00FF00;
			}
			olivec_fill_rect($pixels,$WIDTH,$HEIGHT,$x*$CELL_WIDTH,$y*$CELL_HEIGHT,$CELL_WIDTH,$CELL_HEIGHT,$color)
		}
	}

	my $file_path="output.ppm";
	olivec_save_to_ppm_file($pixels,$WIDTH,$HEIGHT,$file_path);
}
main();
