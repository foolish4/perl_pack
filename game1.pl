#!/usr/bin/env perl

use strict;
use warnings;
use OpenGL;
use OpenGL::GLFW qw(:all);
use Time::HiRes qw(usleep);

#configuration
my $width=800;
my $height=600;

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

sub update{
}

sub render{
	glColor3f(1.0,0.0,0.0);
	draw_line(0,0,$width,$height);

	glColor3f(0.0,1.0,0.0);
	fill_circle($width/2,$height/2,69);
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
	
	glClearColor(0.0,0.0,0.0,0.0);
	
	while(!glfwWindowShouldClose($window)){
		glClear(GL_COLOR_BUFFER_BIT);

		update();
		render();
		
		glfwSwapBuffers($window);
		glfwPollEvents();

		usleep(int(1000/60)*1000);
	}

	glfwDestroyWindow($window);
	glfwTerminate();
}

main();
