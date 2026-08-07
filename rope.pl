#!/usr/bin/env perl

#focus on "simp" coords today (decartes coords)

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

sub immediate_thicc_line{
	my ($p0,$p1,$t)=@_;

	my $v1=Vector2->new(0,0);
	$v1->{x}=$p1->{x}-$p0->{x};
	$v1->{y}=$p1->{y}-$p0->{y};

	my $v2=Vector2->new(-$v1->{y},$v1->{x});
	my $v2l=sqrt($v2->{x}**2+$v2->{y}**2);
	my $epsilon=0.000006;
	if($v2l<$epsilon){
		return;
	}
	$v2->{x}/=$v2l;
	$v2->{y}/=$v2l;

	my $nguyen=Vector2->new(0,0);
	$nguyen->{x}=$p0->{x}+$v2->{x}*($t/2);
	$nguyen->{y}=$p0->{y}+$v2->{y}*($t/2);

	my $vuong=Vector2->new(0,0);
	$vuong->{x}=$p0->{x}-$v2->{x}*($t/2);
	$vuong->{y}=$p0->{y}-$v2->{y}*($t/2);

	my $dinh=Vector2->new(0,0);
	$dinh->{x}=$p1->{x}-$v2->{x}*($t/2);
	$dinh->{y}=$p1->{y}-$v2->{y}*($t/2);

	my $bach=Vector2->new(0,0);
	$bach->{x}=$p1->{x}+$v2->{x}*($t/2);
	$bach->{y}=$p1->{y}+$v2->{y}*($t/2);

	simp_immediate_quad($nguyen,$vuong,$dinh,$bach);
}
sub immediate_circle{
	my ($center,$radius)=@_;

	my $STEP_ANGLE=(2*$PI)/($CIRCLE_RESOLUTION);

	for(0..$CIRCLE_RESOLUTION-1){
		my $p0=$center;

		my $p1=Vector2->new(cos($STEP_ANGLE*$_),sin($STEP_ANGLE*$_));
		$p1->{x}*=$radius;
		$p1->{y}*=$radius;
		$p1->{x}+=$center->{x};
		$p1->{y}+=$center->{y};

		my $p2=Vector2->new(cos($STEP_ANGLE*($_+1)),sin($STEP_ANGLE*($_+1)));
		$p2->{x}*=$radius;
		$p2->{y}*=$radius;
		$p2->{x}+=$center->{x};
		$p2->{y}+=$center->{y};
		simp_immediate_triangle($p0,$p1,$p2);
	}
}

sub update{
	my ($window,$dt)=@_;

	if(glfwGetKey($window,GLFW_KEY_ESCAPE) || glfwGetKey($window,GLFW_KEY_Q)){
		print("goodbye!\n");
		exit(0);
	}
}
sub render{
	my ($window)=@_;
	
	my $pad=100;
	
	glColor3f(1.0,0.0,0.0);
	my $p0=Vector2->new($pad,$pad);
	my $p1=Vector2->new($WINDOW_WIDTH-$pad,$WINDOW_HEIGHT-$pad);
	immediate_thicc_line($p0,$p1,20);
	immediate_circle($p0,30);
	immediate_circle($p1,30);
	
	glColor3f(0.0,1.0,0.0);
	my $p2=Vector2->new($WINDOW_WIDTH-$pad,$pad);
	my $p3=Vector2->new($pad,$WINDOW_HEIGHT-$pad);
	immediate_thicc_line($p2,$p3,20);
	immediate_circle($p2,30);
	immediate_circle($p3,30);

	my ($x,$y)=glfwGetCursorPos($window);
	immediate_circle(Vector2->new($x,$WINDOW_HEIGHT-$y),30);
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
		render($window);

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
sub simp_immediate_quad{
	my ($p0,$p1,$p2,$p3)=@_;
	simp_immediate_triangle($p0,$p1,$p2);
	simp_immediate_triangle($p0,$p2,$p3);
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
