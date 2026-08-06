#!/usr/bin/env perl

use strict;
use warnings;
use OpenGL;
use OpenGL::GLFW qw(:all);
use Time::HiRes qw(usleep);

#configuration
my $WINDOW_WIDTH=800;
my $WINDOW_HEIGHT=600;
my $FPS=60.0;
my $DELAY=1000.0/$FPS;
my $DELTA_TIME_SEC=1.0/$FPS;

sub mod_x{
	my ($x)=@_;
	return ($x/$WINDOW_WIDTH)*2.0-1.0;
}
sub mod_y{
	my ($y)=@_;
	return (($y/$WINDOW_HEIGHT)*2.0-1.0)*(-1);
}
sub mod_w{
	my ($w)=@_;
	return ($w/$WINDOW_WIDTH)*2.0;
}
sub mod_h{
	my ($h)=@_;
	return ($h/$WINDOW_HEIGHT)*2.0;
}
sub make_vector2{
	my ($x,$y)=@_;
	return{
		x=>$x,
		y=>$y
	};
}
sub fill_triangle{
	my ($v2a,$v2b,$v2c)=@_;
	my $ax=mod_x($v2a->{x});
	my $bx=mod_x($v2b->{x});
	my $cx=mod_x($v2c->{x});
	my $ay=mod_y($v2a->{y});
	my $by=mod_y($v2b->{y});
	my $cy=mod_y($v2c->{y});
	#bot-left -> bot-right -> top
	glBegin(GL_TRIANGLES);
	{
		glVertex2f($ax,$ay);
		glVertex2f($bx,$by);
		glVertex2f($cx,$cy);
	}
	glEnd();
}
sub simp_immediate_triangle{
	my ($v2a,$v2b,$v2c)=@_;
	my $ax=mod_x($v2a->{x});
	my $bx=mod_x($v2b->{x});
	my $cx=mod_x($v2c->{x});
	my $ay=mod_y($v2a->{y});
	my $by=mod_y($v2b->{y});
	my $cy=mod_y($v2c->{y});

	#f-flipped
	my $fay=-$ay;
	my $fby=-$by;
	my $fcy=-$cy;

	glBegin(GL_TRIANGLES);
	{
		glVertex2f($ax,$fay);
		glVertex2f($bx,$fby);
		glVertex2f($cx,$fcy);
	}
	glEnd();
}

sub update{
	my ($window,$dt)=@_;

	if(glfwGetKey($window,GLFW_KEY_ESCAPE) || glfwGetKey($window,GLFW_KEY_Q)){
		print("goodbye!\n");
		exit(0);
	}
}
sub render{
	my $p0=make_vector2(0,0);
	my $p1=make_vector2($WINDOW_WIDTH,0);
	my $p2=make_vector2($WINDOW_WIDTH/2,$WINDOW_HEIGHT);
	simp_immediate_triangle($p0,$p1,$p2);
}
sub main{
	glfwInit();
	print("init glfw.\n");

	my $window=glfwCreateWindow($WINDOW_WIDTH,$WINDOW_HEIGHT,"hello",NULL,NULL);
	print("create window.\n");

	glfwMakeContextCurrent($window);
	glfwSwapInterval(1);

	glClearColor(0.08,0.08,0.08,1.0);
	    
	while(!glfwWindowShouldClose($window)){
		glClear(GL_COLOR_BUFFER_BIT);

		update($window,$DELTA_TIME_SEC);
		render();
		
		glfwSwapBuffers($window);
		glfwPollEvents();
	}

	glfwDestroyWindow($window);
	glfwTerminate();
}

main();
