import 'dart:html';
import 'dart:async';

//elements
Element gameCanvas;
Element scoreBoard;
Element startBtn;
Element timeDisplay;
//score
int cnt;
int cntForAnimate;
int level;
bool going;
//timer
RequestAnimationFrameCallback _callback;
num _whenStarted;


void main() {
	initGame();
	initEvent();
}

void initGame() {
  gameCanvas = querySelector('.game-canvas');
	scoreBoard = querySelector('.score-band');
	startBtn = querySelector('.start-button');
	timeDisplay = querySelector('.time-dispaly');
	cnt = 0;
  cntForAnimate = 0;
  level = 1;
  going = false;

  _callback = (num now) {
    //get now
    if (_whenStarted == null) {
      _whenStarted = now;
    }
    now -= _whenStarted;
    cntForAnimate++;

    if (cntForAnimate == 5) {
      cntForAnimate = 0;
      //update time
      if ((now~/100)%10 == 0)
        timeDisplay.text = "${10-(now~/1000)}.0s";
      else
        timeDisplay.text = "${9-(now~/1000)}.${10-((now~/100)%10)}s";
      //update picture
      if (level < 10 && cnt > levelUp()) {
        print("in");
        gameCanvas.querySelector(".gh-$level").classes.toggle("hidden");
        gameCanvas.querySelector(".gh-${level+1}").classes.toggle("hidden");
        level += 1;
        print("level: $level");
      }
      //update score
      scoreBoard.text = "$cnt";
    }

    //request again
    if (now / 1000 >= 10) {
      timeDisplay.text = "0.0s";
      going = false;
      showResult();
    } else {
      window.requestAnimationFrame(_callback);
    }
  };
}

void initEvent() {
	startBtn.onMouseUp.listen((MouseEvent) {
    going = true;
    new Timer(const Duration(milliseconds:100), () {
  		//start requestAnimationFrame
      _whenStarted = null;
      window.requestAnimationFrame(_callback);
  		//hide start button and display time
  		startBtn.classes.add("hidden");
  		timeDisplay.classes.toggle("hidden");
    });
	});

  gameCanvas.onMouseUp.listen((MouseEvent) {
    if (going) {
      cnt++;
    }
  });
}

void showResult() {

}

int levelUp() => level*level + 5;

