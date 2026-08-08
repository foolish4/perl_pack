#!/usr/bin/env perl

#focus on "simp" coords today (decartes coords)

use strict;
use warnings;
use OpenGL;
use OpenGL::GLFW qw(:all);
use Time::HiRes qw(usleep);

#configuration
my $PI=3.14159;
my $WINDOW_FACTOR=75;
my $WINDOW_WIDTH=16*$WINDOW_FACTOR;
my $WINDOW_HEIGHT=9*$WINDOW_FACTOR;
my $CIRCLE_RESOLUTION=30;
my $KNOT_RADIUS=30;
my $EPSILON=0.000001;
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
	if($v2l<=$EPSILON){
		return;
	}
	$v2->{x}/=$v2l;
	$v2->{y}/=$v2l;

	simp_immediate_quad(
		Vector2->new($p0->{x}+$v2->{x}*($t/2),$p0->{y}+$v2->{y}*($t/2)),
		Vector2->new($p0->{x}-$v2->{x}*($t/2),$p0->{y}-$v2->{y}*($t/2)),
		Vector2->new($p1->{x}-$v2->{x}*($t/2),$p1->{y}-$v2->{y}*($t/2)),
		Vector2->new($p1->{x}+$v2->{x}*($t/2),$p1->{y}+$v2->{y}*($t/2))
	    );
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
sub mouse_position{
	my ($window)=@_;
	my ($x,$y)=glfwGetCursorPos($window);
	return Vector2->new($x,$WINDOW_HEIGHT-$y);
}
sub compute_tail_velocity{
	my ($head,$tail)=@_;

	my $tail_velocity=Vector2->new(0,0);

	my $TARGET_DISTANCE=100;
	my $ELASTICITY=20;
	
	my $len=v2length(Vector2->new($tail->{x}-$head->{x},$tail->{y}-$head->{y}));
	my $target=Vector2->new(0,0);
	my $dir=Vector2->new(0,0);

	if($len>$EPSILON){
		$dir->{x}=($tail->{x}-$head->{x})/$len;
		$dir->{y}=($tail->{y}-$head->{y})/$len;
	}
	else{
		$dir->{x}=1;
		$dir->{y}=0;
	}
	$target->{x}=$head->{x}+($dir->{x})*$TARGET_DISTANCE;
	$target->{y}=$head->{y}+($dir->{y})*$TARGET_DISTANCE;

	$tail_velocity->{x}=($target->{x}-$tail->{x})*$ELASTICITY;
	$tail_velocity->{y}=($target->{y}-$tail->{y})*$ELASTICITY;

	return $tail_velocity;
}

#state
my $head=Vector2->new($WINDOW_WIDTH/2,$WINDOW_HEIGHT/2);
my $TAIL_LENGTH=20;
my $tail=[];
for(0..$TAIL_LENGTH-1){
	$tail->[$_]=Vector2->new(
		rand()*$WINDOW_WIDTH,
		rand()*$WINDOW_HEIGHT
	    );
}
my $tail_velocity=[];
for(0..$TAIL_LENGTH-1){
	$tail_velocity->[$_]=Vector2->new(0,0);
}
my $drag=0; #0=false
my $prev_left_mouse_button=GLFW_RELEASE; #release=0,press=1

sub update{
	my ($window,$dt)=@_;

	if(glfwGetKey($window,GLFW_KEY_ESCAPE) || glfwGetKey($window,GLFW_KEY_Q)){
		print("goodbye!\n");
		exit(0);
	}

	my $current_left_button=glfwGetMouseButton($window,GLFW_MOUSE_BUTTON_LEFT);
	if($current_left_button==GLFW_PRESS && $prev_left_mouse_button==GLFW_RELEASE){
		my $pass=mouse_position($window);
		$drag=v2length(Vector2->new($pass->{x}-$head->{x},$pass->{y}-$head->{y}))<=$KNOT_RADIUS;
	}
	elsif($current_left_button==GLFW_RELEASE && $prev_left_mouse_button==GLFW_PRESS){
		$drag=0;
	}
	$prev_left_mouse_button=$current_left_button;

	if($drag){
		$head=mouse_position($window);
	}

	$tail_velocity->[0]=compute_tail_velocity($head,$tail->[0]);
	for(1..$TAIL_LENGTH-1){
		$tail_velocity->[$_]=compute_tail_velocity($tail->[$_-1],$tail->[$_]);
	}

	for(0..$TAIL_LENGTH-1){
		$tail->[$_]->{x}+=$tail_velocity->[$_]->{x}*$dt;
		$tail->[$_]->{y}+=$tail_velocity->[$_]->{y}*$dt;
	}
}
sub render{
	glColor3f(0.5,0.5,0.5);
	immediate_thicc_line($head,$tail->[0],30);

	glColor3f(0.5,0.5,0.5);
	for(1..$TAIL_LENGTH-1){
		immediate_thicc_line($tail->[$_-1],$tail->[$_],$KNOT_RADIUS);
	}

	glColor3f(1.0,0.0,0.0);
	immediate_circle($head,$KNOT_RADIUS);

	glColor3f(0.0,1.0,0.0);
	for(0..$TAIL_LENGTH-1){
		immediate_circle($tail->[$_],$KNOT_RADIUS);
	}
}
sub main{
	glfwInit();
	my $window=glfwCreateWindow($WINDOW_WIDTH,$WINDOW_HEIGHT,"Here's Rope?",NULL,NULL);

	glfwMakeContextCurrent($window);
	glClearColor(0.1,0.1,0.1,1.0);
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
sub simp_immediate_quad{
	my ($p0,$p1,$p2,$p3)=@_;
	simp_immediate_triangle($p0,$p1,$p2);
	simp_immediate_triangle($p0,$p2,$p3);
}
sub v2length{
	my ($self)=@_;
	return sqrt(($self->{x}**2)+($self->{y}**2));
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
