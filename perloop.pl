#!/usr/bin/env perl

use strict;
use warnings;

package Rect;
sub new{
	my $class=shift;
	my $self={};
	bless $self,$class;

	if(@_==4){
		my ($x,$y,$w,$h)=@_;
		$self->{x}=$x;
		$self->{y}=$y;
		$self->{w}=$w;
		$self->{h}=$h;		
	}
	else{
		$self->{x}=0;
		$self->{y}=0;
		$self->{w}=0;
		$self->{h}=0;		
	}

	return $self;
}

sub area{
	my $self=shift;
	return $self->{w}*$self->{h};
}

package Main;
sub main{
	print("hello, world\n");

	my $rect1=Rect->new();
	$rect1->{x}++;
	$rect1->{w}=20;
	print("Rect1\n");
	print("x=" . $rect1->{x} . "\n");
	print("y=" . $rect1->{y} . "\n");
	print("w=" . $rect1->{w} . "\n");
	print("h=" . $rect1->{h} . "\n");

	my $rect2=Rect->new(1,3,5,7);
	print("Rect2\n");
	print("x=" . $rect2->{x} . "\n");
	print("y=" . $rect2->{y} . "\n");
	print("w=" . $rect2->{w} . "\n");
	print("h=" . $rect2->{h} . "\n");

	print("Rect2's area: " . $rect2->area() . "\n");
}

main();
