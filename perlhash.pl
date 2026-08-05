#!/usr/bin/env perl

use strict;
use warnings;

my %rect=(
	x=>1,
	y=>3,
	w=>5,
	h=>7
    );

print("x=" . $rect{x} . "\n");
print("y=" . $rect{y} . "\n");
print("w=" . $rect{w} . "\n");
print("h=" . $rect{h} . "\n");

print("***\n");

my $player_x=10;
my $player_y=20;
my $player_w=100;
my $player_h=50;

my $ball_x=100;
my $ball_y=200;
my $ball_w=20;
my $ball_h=20;

sub overlaps{
	my ($a_ref,$b_ref)=@_;

	my %a=%$a_ref;
	my %b=%$b_ref;

	return
	    ($a{x}+$a{w}>$b{x}) &&
	    ($a{x}<$b{x}+$b{w}) &&
	    ($a{y}+$a{h}>$b{y}) &&
	    ($a{y}<$b{y}+$b{h});
}

sub make_rect_hash{
	my ($x,$y,$w,$h)=@_;

	my %result=(
		x=>$x,
		y=>$y,
		w=>$w,
		h=>$h,
	    );

	return %result;
}

sub print_out{
	my ($rect_ref)=@_;

	my %rect=%$rect_ref;
	
	print("x=" . $rect{x} . "\n");
	print("y=" . $rect{y} . "\n");
	print("w=" . $rect{w} . "\n");
	print("h=" . $rect{h} . "\n");
}

my %player_hash=make_rect_hash($player_x,$player_y,$player_w,$player_h);
my %ball_hash=make_rect_hash($ball_x,$ball_y,$ball_w,$ball_h);

if(overlaps(\%player_hash,\%ball_hash)){
	print("yes, overlaps!\n");
}
else{
	print("nuh uh\n");
}

print_out(\%player_hash);
print("-\n");
print_out(\%ball_hash);
    
