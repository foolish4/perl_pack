#!/usr/bin/env perl

use strict;
use warnings;
use OpenGL::GLFW qw(:all);
use OpenGL qw(:all);
use Time::HiRes qw(time usleep);

#configuration
my $WINDOW_WIDTH=800.0;
my $WINDOW_HEIGHT=600.0;
my $FPS=60.0;
my $MAX_DT=1.0/$FPS;
my $PLAYER_WIDTH=30;
my $PLAYER_HEIGHT=100;
my $L_PLAYER_X=80;
my $R_PLAYER_X=$WINDOW_WIDTH-$PLAYER_WIDTH-$L_PLAYER_X;
my $BALL_SIZE=$PLAYER_WIDTH;
my $BALL_SPEED=500;
my $PLAYER_SPEED=$BALL_SPEED*1.5;

#state
my $l_player_y=$WINDOW_HEIGHT/2-$PLAYER_HEIGHT/2;
my $r_player_y=$WINDOW_HEIGHT/2-$PLAYER_HEIGHT/2;
my $ball_x=$WINDOW_WIDTH/2-$BALL_SIZE/2;
my $ball_y=$WINDOW_HEIGHT/2-$BALL_SIZE/2;
my $ball_dx=1.0;
my $ball_dy=1.0;
my $pause=0;

my $last_time=time();

my @keys;
for(my $i=0;$i<348;$i++){
	$keys[$i]=0;
}

sub key_callback{
	my ($window,$key,$scancode,$action,$mods)=@_;

	if($action==GLFW_PRESS){
		if($key==GLFW_KEY_ESCAPE){
			print("goodbye!\n");
			exit(0);
		}
		if($key==GLFW_KEY_SPACE){
			$pause=!$pause;
		}
	}

	if($action==GLFW_PRESS){
		$keys[$key]=1;
	}
	elsif($action==GLFW_RELEASE){
		$keys[$key]=0;
	}
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

sub make_rect{
	my ($x,$y,$w,$h)=@_;

	my %rect=(
		x=>$x,
		y=>$y,
		w=>$w,
		h=>$h,
	    );

	return %rect;
}

sub overlaps{
	#rect a, rect b
	my ($a_ref,$b_ref)=@_;

	my %a=%$a_ref;
	my %b=%$b_ref;
	
	return
	    ($a{x}+$a{w}>$b{x}) &&
	    ($a{x}<$b{x}+$b{w}) &&
	    ($a{y}+$a{h}>$b{y}) &&
	    ($a{y}<$b{y}+$b{h})
}	

sub update{
	my ($dt)=@_;

	if(!$pause){
		$ball_x+=$ball_dx*$BALL_SPEED*$dt;
		$ball_y+=$ball_dy*$BALL_SPEED*$dt;

		if($ball_x<0){
			$ball_x=$WINDOW_WIDTH/2-$BALL_SIZE/2;
			$ball_y=$WINDOW_HEIGHT/2-$BALL_SIZE/2;
		}
		if($ball_x>$WINDOW_WIDTH-$BALL_SIZE){
			$ball_x=$WINDOW_WIDTH/2-$BALL_SIZE/2;
			$ball_y=$WINDOW_HEIGHT/2-$BALL_SIZE/2;
		}
		
		if($ball_y<0 || $ball_y>$WINDOW_HEIGHT-$BALL_SIZE){
			$ball_dy*=-1;
		}

		if($keys[GLFW_KEY_W]){
			$l_player_y-=$PLAYER_SPEED*$dt;
		}
		if($keys[GLFW_KEY_S]){
			$l_player_y+=$PLAYER_SPEED*$dt;
		}

		if($keys[GLFW_KEY_UP]){
			$r_player_y-=$PLAYER_SPEED*$dt;
		}
		if($keys[GLFW_KEY_DOWN]){
			$r_player_y+=$PLAYER_SPEED*$dt;
		}

		$l_player_y=clamp($l_player_y,0,$WINDOW_HEIGHT-$PLAYER_HEIGHT);
		$r_player_y=clamp($r_player_y,0,$WINDOW_HEIGHT-$PLAYER_HEIGHT);

		my %l_player_rect=make_rect($L_PLAYER_X,$l_player_y,$PLAYER_WIDTH,$PLAYER_HEIGHT);
		my %r_player_rect=make_rect($R_PLAYER_X,$r_player_y,$PLAYER_WIDTH,$PLAYER_HEIGHT);
		my %ball_rect=make_rect($ball_x,$ball_y,$BALL_SIZE,$BALL_SIZE);
		
		if(overlaps(\%l_player_rect,\%ball_rect)){
			$ball_dx=abs($ball_dx);
			$ball_x=$L_PLAYER_X+$PLAYER_WIDTH+1;
		}

		if(overlaps(\%r_player_rect,\%ball_rect)){
			$ball_dx=-abs($ball_dx);
			$ball_x=$R_PLAYER_X-$PLAYER_WIDTH-1;
		}
	}
}

sub render{
	glColor3f(0.2,1.0,0.2);
	glRectf(
		$L_PLAYER_X,
		$l_player_y,
		$L_PLAYER_X+$PLAYER_WIDTH,
		$l_player_y+$PLAYER_HEIGHT
	    );
	
	glColor3f(0.2,0.2,1.0);
	glRectf(
		$R_PLAYER_X,
		$r_player_y,
		$R_PLAYER_X+$PLAYER_WIDTH,
		$r_player_y+$PLAYER_HEIGHT
	    );

	glColor3f(0.75,0.75,0.75);
	glRectf(
		$ball_x,
		$ball_y,
		$ball_x+$BALL_SIZE,
		$ball_y+$BALL_SIZE
	    );
}

sub main{
	if(!glfwInit()){
		print("error: can not init glfw.\n");
		exit(-1);
	}

	my $window=glfwCreateWindow($WINDOW_WIDTH,$WINDOW_HEIGHT,"the pong game!",NULL,NULL);
	if(!$window){
		print("error: can not create window.\n");
		exit(-1);
	}

	glfwMakeContextCurrent($window);
	glfwSwapInterval(1);

	glfwSetKeyCallback($window,\&key_callback);

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0,$WINDOW_WIDTH,$WINDOW_HEIGHT,0,-1,1);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	glClearColor(0.2,0.2,0.2,1.0);

	while(!glfwWindowShouldClose($window)){
		my $now=time();
		my $dt=$now-$last_time;
		$last_time=$now;
		
		if($dt>$MAX_DT){
			$dt=$MAX_DT;
		}

		glClear(GL_COLOR_BUFFER_BIT);

		update($dt);
		render();
		
		glfwSwapBuffers($window);
		glfwPollEvents();
	}
	
	glfwDestroyWindow($window);
	glfwTerminate();
}

main();
