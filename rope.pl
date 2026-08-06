#!/usr/bin/env perl

use strict;
use warnings;
use OpenGL;
use OpenGL::GLFW qw(:all);
use Time::HiRes qw(usleep);

#configuration
my $PI=3.14159;
my $WINDOW_WIDTH=800;
my $WINDOW_HEIGHT=600;
my $CIRCLE_RESOLUTION=30;
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
sub simp_immediate_triangle{
	my ($v2a,$v2b,$v2c)=@_;
	
	my $ax=$v2a->{x};
	my $bx=$v2b->{x};
	my $cx=$v2c->{x};
	my $ay=$v2a->{y};
	my $by=$v2b->{y};
	my $cy=$v2c->{y};

	$ay=$WINDOW_HEIGHT-$ay;
	$by=$WINDOW_HEIGHT-$by;
	$cy=$WINDOW_HEIGHT-$cy;

	$ax=mod_x($ax);
	$bx=mod_x($bx);
	$cx=mod_x($cx);
	$ay=mod_y($ay);
	$by=mod_y($by);
	$cy=mod_y($cy);

	glBegin(GL_TRIANGLES);
	{
		glVertex2f($ax,$ay);
		glVertex2f($bx,$by);
		glVertex2f($cx,$cy);
	}
	glEnd();
}
sub immediate_circle{
	my ($center,$radius)=@_;

	my $STEP_ANGLE=(2*$PI)/$CIRCLE_RESOLUTION;

	for(my $i=0;$i<$CIRCLE_RESOLUTION;$i++){
		my $p0=$center;
		
		my $foo_p1=make_vector2(cos($STEP_ANGLE*$i),sin($STEP_ANGLE*$i));
		$foo_p1->{x}*=$radius;
		$foo_p1->{y}*=$radius;
		$foo_p1->{x}+=$center->{x};
		$foo_p1->{y}+=$center->{y};
		my $p1=make_vector2($foo_p1->{x},$foo_p1->{y});

		my $foo_p2=make_vector2(cos($STEP_ANGLE*($i+1)),sin($STEP_ANGLE*($i+1)));
		$foo_p2->{x}*=$radius;
		$foo_p2->{y}*=$radius;
		$foo_p2->{x}+=$center->{x};
		$foo_p2->{y}+=$center->{y};
		my $p2=make_vector2($foo_p2->{x},$foo_p2->{y});

		simp_immediate_triangle($p0,$p1,$p2);
	}
}
sub simp_immediate_quad{
	my ($p0,$p1,$p2,$p3)=@_;
	simp_immediate_triangle($p0,$p1,$p2);
	simp_immediate_triangle($p0,$p2,$p3);
}
sub immediate_thicc_line{
	my ($p0,$p1,$t)=@_;

	my $v1=make_vector2(0,0);
	$v1->{x}=$p1->{x}-$p0->{x};
	$v1->{y}=$p1->{y}-$p0->{y};

	my $v2=make_vector2(-$v1->{y},$v1->{x});
	my $v2l=sqrt($v2->{x}**2+$v2->{y}**2);
	my $epsilon=0.000001;
	if($v2l<$epsilon){
		return;
	}
	$v2->{x}/=$v2l;
	$v2->{y}/=$v2l;

	#fi-finish
	my $fi1=make_vector2(0,0);
	$fi1->{x}=$p0->{x}+$v2->{x}*($t/2);
	$fi1->{y}=$p0->{y}+$v2->{y}*($t/2);

	my $fi2=make_vector2(0,0);
	$fi2->{x}=$p0->{x}-$v2->{x}*($t/2);
	$fi2->{y}=$p0->{y}-$v2->{y}*($t/2);

	my $fi3=make_vector2(0,0);
	$fi3->{x}=$p1->{x}-$v2->{x}*($t/2);
	$fi3->{y}=$p1->{y}-$v2->{y}*($t/2);

	my $fi4=make_vector2(0,0);
	$fi4->{x}=$p1->{x}+$v2->{x}*($t/2);
	$fi4->{y}=$p1->{y}+$v2->{y}*($t/2);
	
	simp_immediate_quad($fi1,$fi2,$fi3,$fi4);
}

sub update{
	my ($window,$dt)=@_;

	if(glfwGetKey($window,GLFW_KEY_ESCAPE) || glfwGetKey($window,GLFW_KEY_Q)){
		print("goodbye!\n");
		exit(0);
	}
}
sub render{
	my $pad=100;
	glColor3f(1.0,0.0,0.0);
	immediate_thicc_line(make_vector2($pad,$pad),make_vector2($WINDOW_WIDTH-$pad,$WINDOW_HEIGHT-$pad),20);

	#STOP AT HERE: 53:45
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
