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

my @keyboard;
for(my $i=0;$i<GLFW_KEY_LAST+1;$i++){
	$keyboard[$i]=0;
}
sub key_callback{
	my ($window,$key,$scancode,$action,$mods)=@_;

	if($action==GLFW_PRESS){
		if($key==GLFW_KEY_ESCAPE || $key==GLFW_KEY_Q){
			print("goodbye!\n");
			exit(0);
		}

		$keyboard[$key]=1;
	}
	if($action==GLFW_RELEASE){
		$keyboard[$key]=0;
	}
}

#left mouse x,y,count
my $lmx=-50;
my $lmy=-50;
my $lmc=0;
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
			$lmx=$xpos;
			$lmy=$ypos;
			$lmc++;
		}
	}
}

sub v2{
	my ($x,$y)=@_;

	return{
		x=>$x,
		y=>$y
	};
}

#state
my $speed=500;
my $radius=69;
my $pos=v2($radius+10,$radius+10);
my $bullet_radius=23;
my $max_bullet=50;
my @bullets;
for(my $i=0;$i<$max_bullet;$i++){
	$bullets[$i]=v2(-50,-50);
}

sub init{
	print("wasd to move around.\n");
	print("left mouse press to shoot.\n");
}

sub update{
	my ($dt)=@_;

	if($keyboard[GLFW_KEY_A]){
		$pos->{x}-=$speed*$dt;
	}
	if($keyboard[GLFW_KEY_D]){
		$pos->{x}+=$speed*$dt;
	}
	if($keyboard[GLFW_KEY_W]){
		$pos->{y}-=$speed*$dt;
	}
	if($keyboard[GLFW_KEY_S]){
		$pos->{y}+=$speed*$dt;
	}

	$bullets[$lmc]->{x}=$lmx;
	$bullets[$lmc]->{y}=$lmy;
}

sub render{
	glColor3f(1.0,0.0,0.0);
	fill_circle($pos->{x},$pos->{y},$radius,$radius);

	#glColor3f(0.0,1.0,0.0);
	#fill_circle($lmx,$lmy,$bullet_radius);

	glColor3f(0.0,1.0,0.0);
	for(my $i=0;$i<$max_bullet;$i++){
		fill_circle($bullets[$i]->{x},$bullets[$i]->{y},$bullet_radius);
	}
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
