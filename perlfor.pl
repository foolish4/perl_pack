#!/usr/bin/env perl

use strict;
use warnings;

my $foo;
for(my $i=0;$i<4;$i++){
	$foo->[$i]=int(rand()*11);
}
for(my $i=0;$i<4;$i++){
	print($foo->[$i] . "\n");
}

print("***\n");

my $bar; $bar->[$_]=int(rand(11)) for 0..3; #0,1,2,3 -> len=4
print($bar->[$_] . "\n") for 0..3;

print("***\n");

my $baz=[];
$baz->[$_]=int(rand(11)) for 0..3; #0,1,2,3
print($baz->[$_] . "\n") for 0..3;

print("***\n");

my $daf=[map{int(rand(11))} 0..3];
print($daf->[$_] . "\n") for 0..3;

#for array's length naming
#use:
#_n,_size,_count,_len

