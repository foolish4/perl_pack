#!/usr/bin/env perl

#focus on "simp" coords today (decartes coords)

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

sub update{
	my ($window,$dt)=@_;
}
sub render{
	simp_immediate_triangle(
		Vector2->new(0,0),
		Vector2->new($WINDOW_WIDTH,0),
		Vector2->new($WINDOW_WIDTH/2,$WINDOW_HEIGHT)
	    );
}
sub main{
	glfwInit();
	my $window=glfwCreateWindow($WINDOW_WIDTH,$WINDOW_HEIGHT,"hello",NULL,NULL);

	glfwMakeContextCurrent($window);
	glClearColor(0.0,0.0,0.0,1.0);
	glfwSwapInterval(1);
	
	while(!glfwWindowShouldClose($window)){
		glClear(GL_COLOR_BUFFER_BIT);

		update($window,$DELTA_TIME_SEC);
		render();

		glfwSwapBuffers($window);
		glfwPollEvents();
	}
}
main();

sub to_opengl_x{
	my ($x)=@_;
	return ($x/$WINDOW_WIDTH)*2.0-1.0;
}
sub to_opengl_y{
	my ($y)=@_;
	return (($y/$WINDOW_HEIGHT)*2.0-1.0)*(-1);
}
sub to_simp_y{
	my ($y)=@_;
	return ($WINDOW_HEIGHT-$y);
}
sub swing_fill_triangle{
	my ($v2a,$v2b,$v2c)=@_;

	my $ax=$v2a->{x};
	my $bx=$v2b->{x};
	my $cx=$v2c->{x};
	my $ay=$v2a->{y};
	my $by=$v2b->{y};
	my $cy=$v2c->{y};

	$ax=to_opengl_x($ax);
	$bx=to_opengl_x($bx);
	$cx=to_opengl_x($cx);
	$ay=to_opengl_y($ay);
	$by=to_opengl_y($by);
	$cy=to_opengl_y($cy);

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

	my $ax=$v2a->{x};
	my $bx=$v2b->{x};
	my $cx=$v2c->{x};
	my $ay=$v2a->{y};
	my $by=$v2b->{y};
	my $cy=$v2c->{y};

	$ay=to_simp_y($ay);
	$by=to_simp_y($by);
	$cy=to_simp_y($cy);

	swing_fill_triangle(
		Vector2->new($ax,$ay),
		Vector2->new($bx,$by),
		Vector2->new($cx,$cy),
	    );
}

package Vector2;
sub new{
	my ($class,$x,$y)=@_;
	my $self={
		x=>$x,
		y=>$y
	};
	bless($self,$class);
	return $self;
}
