#!/usr/bin/env perl

use strict;
use warnings;
use Tk;
use Time::HiRes qw(time);

#configuration
my $WINDOW_WIDTH=800.0;
my $WINDOW_HEIGHT=600.0;
my $FPS=60.0;
my $DELAY=1000.0/60.0;
my $DELTA_MAX=1.0/$FPS;
my $BALL_SIZE=26.0;
my $BALL_SPEED=400.0;
my $PLAYER_WIDTH=100.0;
my $PLAYER_HEIGHT=$BALL_SIZE;
my $PLAYER_Y=$WINDOW_HEIGHT-$PLAYER_HEIGHT-100;
my $PLAYER_SPEED=$BALL_SPEED*1.5;

#state
my $ball_id;
my $ball_x=0.0;
my $ball_y=0.0;
my $ball_dx=1.0;
my $ball_dy=1.0;
my $player_id;
my $player_x=$WINDOW_WIDTH/2-$PLAYER_WIDTH/2;
my $score_text_id;
my $score=0;
my $score_text="SCORE $score";

my $last_time=time();

my %keys=(
	"Left"=>0,
	"Right"=>0,
	"Escape"=>0,
	"q"=>0,
	"c"=>0,
    );

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
	#0,1,2,3 --- x,y,w,h
	my ($a_ref,$b_ref)=@_;

	my @a=@$a_ref;
	my @b=@$b_ref;

	return
	    ($a[0]+$a[2]>$b[0]) &&
	    ($a[0]<$b[0]+$b[2]) &&
	    ($a[1]+$a[3]>$b[1]) &&
	    ($a[1]<$b[1]+$b[3]);
}

sub init{
	my ($canvas)=@_;

	$ball_id=$canvas->createRectangle(
		$ball_x,
		$ball_y,
		$ball_x+$BALL_SIZE,
		$ball_y+$BALL_SIZE,
		-fill=>"#FF3030",
		-outline=>''
	    );
	
	$player_id=$canvas->createRectangle(
		$player_x,
		$PLAYER_Y,
		$player_x+$PLAYER_WIDTH,
		$PLAYER_Y+$PLAYER_HEIGHT,
		-fill=>"#40FF40",
		-outline=>''
	    );

	$score_text_id=$canvas->createText(
		100,
		50,
		-text=>$score_text,
		-fill=>"#FFFFFF",
		-font=>"{Free Mono} {20}"
	    );
}

sub update{
	my ($canvas,$dt)=@_;

	$ball_x+=$ball_dx*$BALL_SPEED*$dt;
	$ball_y+=$ball_dy*$BALL_SPEED*$dt;

	if($ball_x<0 || $ball_x>$WINDOW_WIDTH-$BALL_SIZE){
		$ball_dx*=-1;
	}
	if($ball_y<0){
		$ball_dy*=-1;
	}
	if($ball_y>$WINDOW_HEIGHT-$BALL_SIZE){
		$ball_dy*=-1;
		$score--;
	}

	if($keys{"Left"}){
		$player_x-=$PLAYER_SPEED*$dt;
	}
	if($keys{"Right"}){
		$player_x+=$PLAYER_SPEED*$dt;
	}

	$player_x=clamp($player_x,0,$WINDOW_WIDTH-$PLAYER_WIDTH);

	my @player_arr=($player_x,$PLAYER_Y,$PLAYER_WIDTH,$PLAYER_HEIGHT);
	my @ball_arr=($ball_x,$ball_y,$BALL_SIZE,$BALL_SIZE);

	if(overlaps(\@player_arr,\@ball_arr)){
		my $ball_center_x=$ball_x+$BALL_SIZE/2;
		my $ball_center_y=$ball_y+$BALL_SIZE/2;
		my $player_center_x=$player_x+$PLAYER_WIDTH/2;
		my $player_center_y=$PLAYER_Y+$PLAYER_HEIGHT/2;

		if($ball_center_y<$player_center_y){
			$ball_dy=-abs($ball_dy);
			$ball_y=$PLAYER_Y-$BALL_SIZE-1; #place above player

			my $hit_pos=($ball_center_x-$player_center_x)/($PLAYER_WIDTH/2);
			$ball_dx=$hit_pos*1.5;
		}
		else{
			$ball_dy=abs($ball_dy);
			$ball_y=$PLAYER_Y+$PLAYER_HEIGHT+1; #place below player

			my $hit_pos=($ball_center_x-$player_center_x)/($PLAYER_WIDTH/2);
			$ball_dx=$hit_pos*1.5;		
		}

		$score++;
	}
	
	$canvas->coords(
		$ball_id,
		$ball_x,
		$ball_y,
		$ball_x+$BALL_SIZE,
		$ball_y+$BALL_SIZE
	    );
	$canvas->coords(
		$player_id,
		$player_x,
		$PLAYER_Y,
		$player_x+$PLAYER_WIDTH,
		$PLAYER_Y+$PLAYER_HEIGHT
	    );
	$canvas->itemconfigure(
		$score_text_id,
		-text=>"SCORE $score"
	    );
}  

sub main{
	my $window=MainWindow->new();
	$window->title("PingPong!!");
	$window->geometry($WINDOW_WIDTH . "x" . $WINDOW_HEIGHT);

	my $canvas=$window->Canvas(
		-width=>$WINDOW_WIDTH,
		-height=>$WINDOW_HEIGHT,
		-background=>"#303030"
	    )->pack();

	$window->focus();
	$canvas->focus();

	init($canvas);

	my $counting=0;

	$window->bind(
		"<KeyPress-c>"=>sub{
			$counting++;
			print("uh oh! the counting=${counting}!\n");
		}
	    );

	$window->bind(
		"<KeyPress-q>"=>sub{
			print("goodbye!\n");
			exit;
		}
	    );
	$window->bind(
		"<KeyPress-Escape>"=>sub{
			print("goodbye!\n");
			exit;
		}
	    );

	
	$window->bind(
		"<KeyPress-Left>"=>sub{
			$keys{"Left"}=1;
		}
	    );
	$window->bind(
		"<KeyRelease-Left>"=>sub{
			$keys{"Left"}=0;
		}
	    );
	$window->bind(
		"<KeyPress-Right>"=>sub{
			$keys{"Right"}=1;
		}
	    );
	$window->bind(
		"<KeyRelease-Right>"=>sub{
			$keys{"Right"}=0;
		}
	    );
	
	$window->repeat(
		$DELAY=>sub{
			my $now=time();
			my $dt=($now-$last_time);
			$last_time=$now;

			if($dt>$DELTA_MAX){
				$dt=$DELTA_MAX;
			}

			#print("dt=${dt}\n");

			update($canvas,$dt);
		}
	    );
	
	MainLoop();
}

main();
