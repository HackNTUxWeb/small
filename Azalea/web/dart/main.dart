import 'dart:html';
import 'dart:math';
import 'dart:async';

import 'dart:js' as js;

//elements
Element target;
Element scoreBoard;
Element startBtn;
Element timdDisplay;
//score
int cnt;
//timer
RequestAnimationFrameCallback _callback;
num _whenStarted;


void main() {
	initGame();
	initEvent();


}

void initGame() {
	target = querySelector('.game-canvas img');
	scoreBoard = querySelector('.score-band');
	startBtn = querySelector('.start-button');
	timdDisplay = querySelector('.time-display');
	cnt = 0;

    _callback = (num now) {
      //get now
      if (_whenStarted == null) {
        _whenStarted = now;
      }
      now -= _whenStarted;
      //update time
      if (now % 100 == 0) {

      }
      //update picture

      //update score

      //request again
      window.requestAnimationFrame(_callback);
    };
  }

void initEvent() {
	startBtn.onMouseUp.listen((MouseEvent) {
		//start requestAnimationFrame
		//hide start and display time
		startBtn.classes.add("hidden");
		timdDisplay.classes.remove("hidden");
	});
}

void show() {

}

