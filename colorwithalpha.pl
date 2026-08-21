#!/usr/bin/env perl

#note: this is transparent for the background color only!
#if you want truly alpha, do for other objects' colors as well!

use strict;
use warnings;
use OpenGL;
use OpenGL::GLFW qw(:all);

#configuration
my $WINDOW_WIDTH=800;
my $WINDOW_HEIGHT=600;
my $BACKGROUND_COLOR=make_color(0.2,0.2,0.2,1.0);
my $RED=make_color(1.0,0.0,0.0,1.0);

sub render{
	color3($RED);
	fill_rect(20,20,50,50);
	
	color4(make_color(1.0,0.0,0.0,0.5));
	fill_rect(100,20,50,50);
	
	color4(make_color(1.0,0.0,0.0,0.25));
	fill_rect(180,20,50,50);
}
sub main{
	glfwInit();
	my $window=glfwCreateWindow($WINDOW_WIDTH,$WINDOW_HEIGHT,"hello",NULL,NULL);
	
	glfwMakeContextCurrent($window);
	glfwSwapInterval(1);
	
	clear_color($BACKGROUND_COLOR);
	
	while(!glfwWindowShouldClose($window)){
		glClear(GL_COLOR_BUFFER_BIT);
		
		if(glfwGetKey($window,GLFW_KEY_Q)){
			die("goodbye!\n");
		}
		
		render();
	
		glfwPollEvents();
		glfwSwapBuffers($window);
	}
}
main();

sub make_color{
	my ($r,$g,$b,$a)=@_; #color:0->1
	return{
		r=>$r,
		g=>$g,
		b=>$b,
		a=>$a
	};
}
sub clear_color{
	my ($color)=@_;
	glClearColor($color->{r},$color->{g},$color->{b},1.0);
}
sub color3{
	my ($color)=@_;
	glColor3f($color->{r},$color->{g},$color->{b});
}
sub clamp{
	my ($x,$low,$high)=@_;
	if($x<$low){
		return $low;
	}
	if($x>$high){
		return $high;
	}
	return $x;
}
sub color4{
	my ($color)=@_;
	$color->{r}=clamp($color->{r},0.0,1.0);
	$color->{g}=clamp($color->{g},0.0,1.0);
	$color->{b}=clamp($color->{b},0.0,1.0);
	$color->{a}=clamp($color->{a},0.0,1.0);
	my $result_r=($color->{r}*$color->{a})+($BACKGROUND_COLOR->{r}*(1.0-$color->{a}));
	my $result_g=($color->{g}*$color->{a})+($BACKGROUND_COLOR->{g}*(1.0-$color->{a}));
	my $result_b=($color->{b}*$color->{a})+($BACKGROUND_COLOR->{b}*(1.0-$color->{a}));
	glColor3f($result_r,$result_g,$result_b);
}
sub opengl_x{
	my ($x)=@_;
	return ($x/$WINDOW_WIDTH)*2.0-1.0;
}
sub opengl_y{
	my ($y)=@_;
	return (($y/$WINDOW_HEIGHT)*2.0-1.0)*(-1);
}
sub fill_rect_points{
	my ($x0,$y0,$x1,$y1)=@_;
	$x0=opengl_x($x0);
	$y0=opengl_y($y0);
	$x1=opengl_x($x1);
	$y1=opengl_y($y1);
	glBegin(GL_QUADS);
	{
		glVertex2f($x0,$y0);
		glVertex2f($x1,$y0);
		glVertex2f($x1,$y1);
		glVertex2f($x0,$y1);
	}
	glEnd();
}
sub fill_rect{
	my ($x,$y,$w,$h)=@_;
	fill_rect_points($x,$y,$x+$w,$y+$h);
}

