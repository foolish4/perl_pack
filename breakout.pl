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
my $PLAYER_Y=$WINDOW_HEIGHT-$PLAYER_HEIGHT;
my $BALL_SIZE=$PLAYER_HEIGHT;
my $BALL_SPEED=400;
my $PLAYER_SPEED=$BALL_SPEED*1.7;
my $TARGET_ROWS=5;
my $TARGET_COLS=5;
my $TARGET_MAX=$TARGET_ROWS*$TARGET_COLS;
my $TARGET_WIDTH=$PLAYER_WIDTH;
my $TARGET_HEIGHT=$PLAYER_HEIGHT;
my $TARGET_GAP=20;

#state
sub td_rect{ #td is just "thanh duy" is my name
	my ($x,$y,$w,$h)=@_;
	return{
		x=>$x,
		y=>$y,
		w=>$w,
		h=>$h
	};
}
sub td_target{
	my ($x,$y,$dead)=@_;
	return{
		x=>$x,
		y=>$y,
		dead=>$dead
	};
}

my $player_x=$WINDOW_WIDTH/2-$PLAYER_WIDTH/2;
my $ball_x=$WINDOW_WIDTH/2-$BALL_SIZE/2;
my $ball_y=$PLAYER_Y-$PLAYER_HEIGHT;
my $ball_dx=1.0;
my $ball_dy=-1.0;
my $space_was_pressed=0;
my $pause=1;

my $target=[];

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
sub overlaps{
	my ($rect_a,$rect_b)=@_;
	return
	    ($rect_a->{x}+$rect_a->{w}>$rect_b->{x}) &&
	    ($rect_a->{x}<$rect_b->{x}+$rect_b->{w}) &&
	    ($rect_a->{y}+$rect_a->{h}>$rect_b->{y}) &&
	    ($rect_a->{y}<$rect_b->{y}+$rect_b->{h});
}

sub init{
	for(my $i=0;$i<$TARGET_MAX;$i++){
		$target->[$i]=td_target(0,0,1);
	}

	#
	#for(my $i=0;$i<$TARGET_COLS;$i++){  	
	#	$target->[$i]->{x}=100+($TARGET_WIDTH+$TARGET_GAP)*$i;
	#	$target->[$i]->{y}=100;
	#	$target->[$i]->{dead}=0;
	#}
	#

	for my $i (0..$TARGET_ROWS-1){
		for my $j (0..$TARGET_COLS-1){
			my $index=$i*$TARGET_COLS+$j;
			$target->[$index]->{x}=100+($TARGET_WIDTH+$TARGET_GAP)*$j;
			$target->[$index]->{y}=50+($TARGET_HEIGHT+$TARGET_GAP)*$i;
			$target->[$index]->{dead}=0;
		}
	}
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
		my $ball_rect=td_rect($ball_x,$ball_y,$BALL_SIZE,$BALL_SIZE);
		for my $i (0..$TARGET_MAX-1){
			my $target_rect=td_rect($target->[$i]->{x},$target->[$i]->{y},$TARGET_WIDTH,$TARGET_HEIGHT);
			if(overlaps($ball_rect,$target_rect) && !$target->[$i]->{dead}){
				my $hit_x=($ball_x+$BALL_SIZE/2)-($target->[$i]->{x}+$TARGET_WIDTH/2);
				my $hit_y=($ball_y+$BALL_SIZE/2)-($target->[$i]->{y}+$TARGET_HEIGHT/2);

				my $pi=3.14159;
				my $angle=atan2($hit_y,$hit_x);

				my $min_angle=(20*$pi)/180;
				my $max_angle=(160*$pi)/180;

				if(abs($angle)<$min_angle){
					$angle=($angle>=0 ? 1 : -1)*$min_angle;
				}
				if(abs($angle)>$max_angle && abs($angle)<$pi){
					$angle=($angle>=0 ? 1 : -1)*$max_angle;
				}

				#add randomness
				$angle+=(rand()-0.5)*0.3;

				$ball_dx=cos($angle)*1.5;
				$ball_dy=sin($angle)*1.5;
				
				$ball_x+=$ball_dx;
				$ball_y+=$ball_dy;

				$ball_rect=td_rect($ball_x,$ball_y,$BALL_SIZE,$BALL_SIZE); 
				
				$target->[$i]->{dead}=1;
				
				last; #this is like break in C/Java
			}
		}
		
	        

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

		my $player_rect=td_rect($player_x,$PLAYER_Y,$PLAYER_WIDTH,$PLAYER_HEIGHT);
		if(overlaps($ball_rect,$player_rect)){
		        #calculate where on paddle we hit (-1 to 1)
			my $hit_x=($ball_x+$BALL_SIZE/2)-($player_x+$PLAYER_WIDTH/2);
			my $normalized_hit=$hit_x/($PLAYER_WIDTH/2);
			$normalized_hit=clamp($normalized_hit, -1, 1);
			
			#map to dx: -0.8 (left) to 0.8 (right)
			$ball_dx=$normalized_hit*0.8;
			
			#always go up, but with some vertical component
			$ball_dy=-sqrt(1-$ball_dx**2)*1.5; #keep speed constant
			
			#push ball above paddle
			$ball_y=$PLAYER_Y-$BALL_SIZE-1;
		}
	}
}
sub render{
	glColor3f(0.3,0.3,1.0);
	fill_rect($player_x,$PLAYER_Y,$PLAYER_WIDTH,$PLAYER_HEIGHT);

	glColor3f(1.0,0.3,1.3);
	fill_rect($ball_x,$ball_y,$BALL_SIZE,$BALL_SIZE);

	glColor3f(0.3,1.0,0.3);
	for(my $i=0;$i<$TARGET_MAX;$i++){
		if(!$target->[$i]->{dead}){
			fill_rect($target->[$i]->{x},$target->[$i]->{y},$TARGET_WIDTH,$TARGET_HEIGHT);
		}
	}
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

	init();
	
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
