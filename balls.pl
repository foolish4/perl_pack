#!/usr/bin/env perl

#by the way, i'm coding in leafpad :)
#back to leafpad! emacs is too complicated!

use strict;
use warnings;
use OpenGL qw(:all);
use OpenGL::GLFW qw(:all);

#configuration
my $WINDOW_WIDTH=800;
my $WINDOW_HEIGHT=600;
my $FPS=60.0;
my $DELAY=1000.0/$FPS;
my $DELTA_TIME_SEC=1.0/$FPS;
my $GROUND_Y=$WINDOW_HEIGHT-50;
my $GRAVITY=1;
my $BOUNCE_DAMPING=85/100; #percentage
my $MIN_VELOCITY=2;

sub get_rand{
	my ($n)=@_;
	return int(rand()*$n);
}

sub make_ball{
	my ($x,$y,$r,$vx,$vy)=@_;
	return{
		x=>$x,
		y=>$y,
		r=>$r,
		vx=>$vx,
		vy=>$vy
	};
}

#state
my $total_balls=50;
my $balls=[];
for(0..$total_balls-1){
	$balls->[$_]=make_ball(
		get_rand($WINDOW_WIDTH),
		get_rand($WINDOW_HEIGHT/3),
		get_rand(40)+10,
		get_rand(15)+1,
		get_rand(15)+1
		);
}

sub update{
	my ($dt)=@_;
	
	for(0..$total_balls-1){
		$balls->[$_]->{x}+=$balls->[$_]->{vx};
		
		if($balls->[$_]->{x}<$balls->[$_]->{r}){
			$balls->[$_]->{x}=$balls->[$_]->{r};
			$balls->[$_]->{vx}*=$BOUNCE_DAMPING*(-1);
		}
		elsif($balls->[$_]->{x}>$WINDOW_WIDTH-$balls->[$_]->{r}){
			$balls->[$_]->{x}=$WINDOW_WIDTH-$balls->[$_]->{r};
			$balls->[$_]->{vx}*=$BOUNCE_DAMPING*(-1);
		}
		
		
		$balls->[$_]->{vy}+=$GRAVITY;
		$balls->[$_]->{y}+=$balls->[$_]->{vy};
		
		if($balls->[$_]->{y}+$balls->[$_]->{r}>=$GROUND_Y){
			$balls->[$_]->{y}=$GROUND_Y-$balls->[$_]->{r};
			$balls->[$_]->{vy}*=$BOUNCE_DAMPING*(-1);
			if(abs($balls->[$_]->{vy})<$MIN_VELOCITY){
				$balls->[$_]->{vy}=0;
				$balls->[$_]->{vx}=0;
			}
		}
	}
}
sub render{
	for(0..$total_balls-1){
		set_color(rand(),rand(),rand());
		fill_circle($balls->[$_]->{x},$balls->[$_]->{y},$balls->[$_]->{r});
	}
	
	set_color(1.0,1.0,1.0);
	draw_line(0,$GROUND_Y,$WINDOW_WIDTH,$GROUND_Y);
}
sub main{
	if(!glfwInit()){
		die("can not init glfw.\n");
	}
	my $window=glfwCreateWindow($WINDOW_WIDTH,$WINDOW_HEIGHT,"balls are balling",NULL,NULL);
	if($window==0){
		die("can not create window.\n");
	}
	
	glfwMakeContextCurrent($window);
	glfwSwapInterval(1);
	
	glClearColor(0.0,0.0,0.0,1.0);
	
	while(!glfwWindowShouldClose($window)){
		glClear(GL_COLOR_BUFFER_BIT);
		
		if(glfwGetKey($window,GLFW_KEY_Q)){
			printf("goodbye!\n");
			exit(0);
		}
		
		update($DELTA_TIME_SEC);
		render();
		
		select(undef,undef,undef,$DELAY/1000);
		
		glfwPollEvents();
		glfwSwapBuffers($window);
	}
	
	glfwDestroyWindow($window);
	glfwTerminate();
}
main();

sub opengl_x{
	my ($x)=@_;
	return ($x/$WINDOW_WIDTH)*2.0-1.0;
}
sub opengl_y{
	my ($y)=@_;
	return (($y/$WINDOW_HEIGHT)*2.0-1.0)*(-1);
}
sub set_color{
	my ($r,$g,$b)=@_;
	glColor3f($r,$g,$b);
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
sub fill_circle{
	my ($cx,$cy,$r)=@_;
	
	for(my $x=-$r;$x<=$r;$x++){
		my $y=int(sqrt(($r**2)-($x**2)));
		fill_rect($cx+$x,$cy-$y,1,$y);
		fill_rect($cx+$x,$cy,1,$y);
	}
}
sub draw_line{
	my ($x0,$y0,$x1,$y1)=@_;
	
	$x0=opengl_x($x0);	
	$y0=opengl_y($y0);
	$x1=opengl_x($x1);
	$y1=opengl_y($y1);
	
	glBegin(GL_LINES);
	{
		glVertex2f($x0,$y0);
		glVertex2f($x1,$y1);
	}
	glEnd();
}

