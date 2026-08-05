#!/usr/bin/env perl

use strict;
use warnings;

my $fav=[1,3,5,7,9,11,13];
my $len_fav=scalar(@$fav);

for(my $i=0;$i<$len_fav;$i++){
	print($fav->[$i] . "\n");
}

print("***\n");

my $daf;
my $len_daf=5;

for(my $i=0;$i<$len_daf;$i++){
	$daf->[$i]=int(rand()*100);
}
for(my $i=0;$i<$len_daf;$i++){
	print($daf->[$i] . "\n");
}

print("***\n");

my $gah={
	x=>10,
	y=>20,
	z=>40
};

print($gah->{x} . "\n");
print($gah->{y} . "\n");
print($gah->{z} . "\n");

print("***\n");

sub Person{
	my ($name,$age,$job)=@_;

	return{
		name=>$name,
		age=>$age,
		job=>$job
	};
}
sub print_info{
	my ($person)=@_;

	print($person->{name} . "\n");
	print($person->{age} . "\n");
	print($person->{job} . "\n");
}

my $vu=Person("Nguyen Dai Vu",35,"Chicken Farm Owner");
print_info($vu);
