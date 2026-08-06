#!/usr/bin/env perl

use strict;
use warnings;
use OpenGL;
use OpenGL::GLFW qw(:all);
use Time::HiRes qw(usleep);

#configuration
my $WINDOW_WIDTH=800.0;
my $WINDOW_HEIGHT=600.0;
my $FPS=60.0;
my $DELAY=1000.0/$FPS;
my $DELTA_TIME_SEC=1.0/$FPS;
my $PLAYER_WIDTH=100.0;
my $PLAYER_HEIGHT=30.0;
my $PLAYER_Y=$WINDOW_HEIGHT-$PLAYER_HEIGHT-50.0;
my $BALL_SIZE=$PLAYER_HEIGHT;
my $BALL_SPEED=400;
my $PLAYER_SPEED=$BALL_SPEED*1.7;

#state
my $player_x=$WINDOW_WIDTH/2-$PLAYER_WIDTH/2;
my $ball_x=$WINDOW_WIDTH/2-$BALL_SIZE/2;
my $ball_y=$PLAYER_Y-$PLAYER_HEIGHT;
my $ball_dx=1;
my $ball_dy=-1;
my $space_was_pressed=0;
my $pause=1;

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
sub fill_rect_point{
	my ($x1,$y1,$x2,$y2)=@_;
	my $mx1=mod_x($x1);
	my $my1=mod_y($y1);
	my $mx2=mod_x($x2);
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

sub update{
	my ($window,$dt)=@_;

	my $space_pressed=glfwGetKey($window,GLFW_KEY_SPACE)==GLFW_TRUE;
	if($space_pressed && !$space_was_pressed){
		$pause=!$pause;
	}
	$space_was_pressed=$space_pressed;

	if(glfwGetKey($window,GLFW_KEY_LEFT)==GLFW_TRUE){
		if($pause){
			$pause=0;
		}
	}
	if(glfwGetKey($window,GLFW_KEY_RIGHT)==GLFW_TRUE){
		if($pause){
			$pause=0;
		}
	}
	
	if(!$pause){
		$ball_x+=$ball_dx*$BALL_SPEED*$dt;
		$ball_y+=$ball_dy*$BALL_SPEED*$dt;

		if($ball_x<0 || $ball_x>$WINDOW_WIDTH-$BALL_SIZE){
			$ball_dx*=-1;
		}
		if($ball_y<0 || $ball_y>$WINDOW_HEIGHT-$BALL_SIZE){
			$ball_dy*=-1;
		}

		if(glfwGetKey($window,GLFW_KEY_LEFT)==GLFW_TRUE){
			$player_x-=$PLAYER_SPEED*$dt;
		}
		if(glfwGetKey($window,GLFW_KEY_RIGHT)==GLFW_TRUE){
			$player_x+=$PLAYER_SPEED*$dt;
		}

		$player_x=clamp($player_x,0,$WINDOW_WIDTH-$PLAYER_WIDTH);
	}
}
sub render{
	glColor3f(0.3,0.3,1.0);
	fill_rect($player_x,$PLAYER_Y,$PLAYER_WIDTH,$PLAYER_HEIGHT);

	glColor3f(1.0,0.3,1.3);
	fill_rect($ball_x,$ball_y,$BALL_SIZE,$BALL_SIZE);
}
sub main{
	if(!glfwInit()){
		print("error: can not init glfw.\n");
		exit(-1);
	}

	my $window=glfwCreateWindow($WINDOW_WIDTH,$WINDOW_HEIGHT,"Breakout",NULL,NULL);
	if($window==0){
		print("error: can not create window.\n");
		exit(-1);
	}

	glfwMakeContextCurrent($window);
	glfwSwapInterval(1);

	glClearColor(0.3,0.3,0.3,1.0);

	while(!glfwWindowShouldClose($window)){
		glClear(GL_COLOR_BUFFER_BIT);

		update($window,$DELTA_TIME_SEC);
		render();
		
		usleep($DELAY*1000);
		
		glfwSwapBuffers($window);
		glfwPollEvents();
	}

	glfwDestroyWindow($window);
	glfwTerminate();
}

main();
