#!/usr/bin/env perl

use strict;
use warnings;
use OpenGL;
use OpenGL::GLFW qw(:all);
use Time::HiRes qw(usleep);

#configuration
my $WINDOW_WIDTH=1366;
my $WINDOW_HEIGHT=768;
my $FPS=60.0;
my $DELAY=1000/$FPS;
my $DELTA_TIME_SEC=1.0/$FPS;
my $RECT_SIZE=30;
my $MAX_RECTS=500;

#state
sub make_wrect{ #weird rect
	my ($x,$y,$w,$h,$dx,$dy,$r,$g,$b,$life)=@_;
	return{
		x=>$x,
		y=>$y,
		w=>$w,
		h=>$h,
		dx=>$dx,
		dy=>$dy,
		r=>$r,
		g=>$g,
		b=>$b,
		life=>$life
	};
}
sub get_random_dir{
	return (rand()<0.5) ? 1 : -1;
}
sub get_life{
	return 10+int(rand()*200);
}
sub get_custom_wrects{
	my $rects;
	for(0..$MAX_RECTS-1){
		$rects->[$_]=make_wrect(
			$WINDOW_WIDTH/2-$RECT_SIZE/2,
			$WINDOW_HEIGHT/2-$RECT_SIZE/2,
			$RECT_SIZE,
			$RECT_SIZE,
			int((rand()*15)+1)*get_random_dir(),
			int((rand()*15)+1)*get_random_dir(),
			rand(),
			rand(),
			rand(),
			get_life()
		    );
	}
	return $rects;
}
my $rects=get_custom_wrects();
my $rects_appear=0;
sub all_rects_die{
	my ($rects)=@_;

	#check: all rects die if the rect with the most "life" frames <= 0
	#this is a "just in case" or "just to make sure" moment
	#yes, this is ridiculous if you knows Math...
	#i'm stupid...
	
	my $max_val=$rects->[0]->{life};
	for(1..$MAX_RECTS-1){
		if($max_val<$rects->[$_]->{life}){
			$max_val=$rects->[$_]->{life};
		}
	}

	return $max_val<=0;
}

sub init{
	print("press the spacebar!\n");
}
my $prev_key_space=0;
sub update{
	my ($window,$dt)=@_;

	if(glfwGetKey($window,GLFW_KEY_ESCAPE) || glfwGetKey($window,GLFW_KEY_Q)){
		print("goodbye!\n");
		exit(0);
	}

	my $key_space=glfwGetKey($window,GLFW_KEY_SPACE);
	if($key_space && !$prev_key_space){
		if(!$rects_appear){
			$rects_appear=1;
		}
	}
	elsif(!$key_space && $prev_key_space){
		#nothing for now
	}
	$prev_key_space=$key_space;

	if($rects_appear){
		for(0..$MAX_RECTS-1){
			$rects->[$_]->{x}+=$rects->[$_]->{dx};
			$rects->[$_]->{y}+=$rects->[$_]->{dy};

			if($rects->[$_]->{x}<0 || $rects->[$_]->{x}>$WINDOW_WIDTH-$RECT_SIZE){
				$rects->[$_]->{dx}*=-1;
			}
			if($rects->[$_]->{y}<0 || $rects->[$_]->{y}>$WINDOW_HEIGHT-$RECT_SIZE){
				$rects->[$_]->{dy}*=-1;
			}

			$rects->[$_]->{life}--;
		}
	}
	if(all_rects_die($rects) && $rects_appear){
	        $rects=get_custom_wrects();
		$rects_appear=0;
	}
}
sub render{
	if($rects_appear){
		for(0..$MAX_RECTS-1){
			if($rects->[$_]->{life}>0){
				glColor3f(
					$rects->[$_]->{r},
					$rects->[$_]->{g},
					$rects->[$_]->{b},
				    );
				
				swing_fill_rect(
					$rects->[$_]->{x},
					$rects->[$_]->{y},
					$RECT_SIZE,
					$RECT_SIZE
				    );
			}
		}
	}
}
sub main{
        glfwInit();
	my $window=glfwCreateWindow($WINDOW_WIDTH,$WINDOW_HEIGHT,"hello",NULL,NULL);
	glfwMakeContextCurrent($window);
	glClearColor(0.0,0.0,0.0,1.0);
	glfwSwapInterval(1);

	init();
	while(!glfwWindowShouldClose($window)){
		glClear(GL_COLOR_BUFFER_BIT);
		
		update($window,$DELTA_TIME_SEC);
		render();

		usleep($DELAY*1000);
		
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
sub fill_rect_points{
	my ($x0,$y0,$x1,$y1)=@_;

	$x0=to_opengl_x($x0);
	$x1=to_opengl_x($x1);
	$y0=to_opengl_y($y0);
	$y1=to_opengl_y($y1);

	glBegin(GL_QUADS);
	{
		glVertex2f($x0,$y0);
		glVertex2f($x1,$y0);
		glVertex2f($x1,$y1);
		glVertex2f($x0,$y1);
	}
	glEnd();
}
sub swing_fill_rect{
	my ($x,$y,$w,$h)=@_;
	fill_rect_points($x,$y,$x+$w,$y+$h);
}
