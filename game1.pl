#!/usr/bin/env perl

use strict;
use warnings;
use OpenGL;
use OpenGL::GLFW qw(:all);
use Time::HiRes qw(usleep);

#configuration
my $width=800;
my $height=600;
my $fps=60.0;
my $delta_time_sec=1.0/60.0;

#handle
sub mod_x{
	my ($x)=@_;
	return ($x/$width)*2.0-1.0;
}
sub mod_y{
	my ($y)=@_;
	return -(($y/$height)*2.0-1.0);
}
sub mod_w{
	my ($w)=@_;
	return ($w/$width)*2.0;
}
sub mod_h{
	my ($h)=@_;
	return ($h/$height)*2.0;
}

sub draw_line{
	my ($x1,$y1,$x2,$y2)=@_;

	my $mx1=mod_x($x1);
	my $mx2=mod_x($x2);
	my $my1=mod_y($y1);
	my $my2=mod_y($y2);
	
	glBegin(GL_LINES);
	{
		glVertex2f($mx1,$my1);
		glVertex2f($mx2,$my2);
	}
	glEnd();
}
sub fill_circle{
	my ($cx,$cy,$r)=@_;

	my $mcx=mod_x($cx);
	my $mcy=mod_y($cy);
	my $mrx=mod_w($r);
	my $mry=mod_h($r);

	my $segments=30;

	glBegin(GL_TRIANGLE_FAN);
	{
		glVertex2f($mcx,$mcy);
		for(my $i=0;$i<=$segments;$i++){
			my $angle=(2.0*3.14159*$i)/$segments;
			my $x=$mcx+$mrx*cos($angle);
			my $y=$mcy+$mry*sin($angle);

			glVertex2f($x,$y);
		}
	}
	glEnd();
}
sub fill_rect_point{
	my ($x1,$y1,$x2,$y2)=@_;
	
	my $mx1=mod_x($x1);
	my $mx2=mod_x($x2);
	my $my1=mod_y($y1);
	my $my2=mod_y($y2);
	
	glBegin(GL_QUADS);
	{
		glVertex2f($mx1,$my1);
		glVertex2f($mx2,$my1);
		glVertex2f($mx2,$my2);
		glVertex2f($mx1,$my2);
	}
	glEnd();
}
sub fill_rect{
	my ($x,$y,$w,$h)=@_;
	fill_rect_point($x,$y,$x+$w,$y+$h);
}

#state
sub v2{
	my ($x,$y)=@_;

	return{
		x=>$x,
		y=>$y
	};
}

my $speed=500;
my $radius=69;
my $pos=v2($radius+10,$radius+10);
my $bullet_radius=23;
my $max_bullet=50;
my $bullet_speed=400;
my $e_bullets; #expected bullets
for(my $i=0;$i<$max_bullet;$i++){
	$e_bullets->[$i]=v2(-50,-50);
}
my $bullets; #bullets
for(my $i=0;$i<$max_bullet;$i++){
	$bullets->[$i]=v2(-50,-50);
}
my $bullets_dir; #dir x,y for bullets
for(my $i=0;$i<$max_bullet;$i++){
	$bullets_dir->[$i]=v2(0,0);
}
my $bullets_diff; #bullets and e_bullets difference
for(my $i=0;$i<$max_bullet;$i++){
	$bullets_diff->[$i]=v2(0,0);
}
my $bullets_dist; #bullets and e_bullets distances
for(my $i=0;$i<$max_bullet;$i++){
	$bullets_dist->[$i]=0;
}

my $enemy=v2(10,10);
my $enemy_dir=v2(1,1);
my $enemy_size=30;
my $enemy_speed=100;

my $keyboard;
for(my $i=0;$i<GLFW_KEY_LAST+1;$i++){
	$keyboard->[$i]=0;
}
sub key_callback{
	my ($window,$key,$scancode,$action,$mods)=@_;

	if($action==GLFW_PRESS){
		if($key==GLFW_KEY_ESCAPE || $key==GLFW_KEY_Q){
			print("goodbye!\n");
			exit(0);
		}

		$keyboard->[$key]=1;
	}
	if($action==GLFW_RELEASE){
		$keyboard->[$key]=0;
	}
}

#left mouse x,y,count
my $lmx=-50;
my $lmy=-50;
my $lmc=0;
my $click_fired;
sub mouse_callback{
	my ($window,$xpos,$ypos)=@_;
	#print("x=${xpos},y=${ypos}\n");
}
sub mouse_button_callback{
	my ($window,$button,$action,$mods)=@_;

	if($action==GLFW_PRESS){
		if($button==GLFW_MOUSE_BUTTON_LEFT){
			my ($xpos,$ypos)=glfwGetCursorPos($window);
			#print("press:x=${xpos},y=${ypos}\n");
			#$lmc++;
			$lmx=$xpos;
			$lmy=$ypos;
			$click_fired=1;
		}
	}
}

sub init{
	print("wasd to move around.\n");
	print("left mouse press to shoot.\n");
}

sub update{
	my ($dt)=@_;

	if($keyboard->[GLFW_KEY_A]){
		$pos->{x}-=$speed*$dt;
	}
	if($keyboard->[GLFW_KEY_D]){
		$pos->{x}+=$speed*$dt;
	}
	if($keyboard->[GLFW_KEY_W]){
		$pos->{y}-=$speed*$dt;
	}
	if($keyboard->[GLFW_KEY_S]){
		$pos->{y}+=$speed*$dt;
	}

	if($click_fired && $lmc<$max_bullet){
		$e_bullets->[$lmc]->{x}=$lmx;
		$e_bullets->[$lmc]->{y}=$lmy;

		$bullets->[$lmc]->{x}=$pos->{x};
		$bullets->[$lmc]->{y}=$pos->{y};

		$bullets_diff->[$lmc]->{x}=$e_bullets->[$lmc]->{x}-$bullets->[$lmc]->{x};
		$bullets_diff->[$lmc]->{y}=$e_bullets->[$lmc]->{y}-$bullets->[$lmc]->{y};

		$bullets_dist->[$lmc]=sqrt(($bullets_diff->[$lmc]->{x}**2)+($bullets_diff->[$lmc]->{y}**2));

		if($bullets_dist->[$lmc]>0){
			$bullets_dir->[$lmc]->{x}=$bullets_diff->[$lmc]->{x}/$bullets_dist->[$lmc];
			$bullets_dir->[$lmc]->{y}=$bullets_diff->[$lmc]->{y}/$bullets_dist->[$lmc];
		}
	}

	#increment after shooting
	$lmc++;
	if($lmc>=$max_bullet){
		$lmc=0;
	}

	$click_fired=0;

	for(my $i=0;$i<$max_bullet;$i++){
		$bullets->[$i]->{x}+=$bullets_dir->[$i]->{x}*$bullet_speed*$dt;
		$bullets->[$i]->{y}+=$bullets_dir->[$i]->{y}*$bullet_speed*$dt;
	}

	$enemy->{x}+=$enemy_dir->{x}*$enemy_speed*$dt;
	$enemy->{y}+=$enemy_dir->{y}*$enemy_speed*$dt;
}

sub render{
	#glColor3f(0.0,1.0,0.0);
	#fill_circle($lmx,$lmy,$bullet_radius);

	#glColor3f(0.0,1.0,0.0);
	#for(my $i=0;$i<$max_bullet;$i++){
	#	fill_circle($e_bullets->[$i]->{x},$e_bullets->[$i]->{y},$bullet_radius);
	#}

	glColor3f(1.0,1.0,1.0);
	for(my $i=0;$i<$max_bullet;$i++){
		fill_circle($bullets->[$i]->{x},$bullets->[$i]->{y},$bullet_radius);
	}

	glColor3f(0.0,1.0,1.0);
	fill_rect($enemy->{x},$enemy->{y},$enemy_size,$enemy_size);

	glColor3f(1.0,0.0,0.0);
	fill_circle($pos->{x},$pos->{y},$radius,$radius);
}

sub main{
	if(!glfwInit()){
		print("error: can not init glfw.\n");
		exit(-1);
	}

	my $window=glfwCreateWindow($width,$height,"game1",NULL,NULL);
	if($window==0){
		print("error: can not create window.\n");
		exit(-1);
	}

	glfwMakeContextCurrent($window);
	glfwSwapInterval(1);

	glfwSetKeyCallback($window,\&key_callback);
	glfwSetCursorPosCallback($window,\&mouse_callback);
	glfwSetMouseButtonCallback($window,\&mouse_button_callback);
	
	glClearColor(0.0,0.0,0.0,0.0);

	init();
	
	while(!glfwWindowShouldClose($window)){
		glClear(GL_COLOR_BUFFER_BIT);

		update($delta_time_sec);
		render();
		
		glfwSwapBuffers($window);
		glfwPollEvents();

		usleep(int(1000/$fps)*1000);
	}

	glfwDestroyWindow($window);
	glfwTerminate();
}

main();
