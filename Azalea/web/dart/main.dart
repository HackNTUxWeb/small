import 'dart:html';
import 'dart:async';
import 'dart:js' as js;

//elements
Element gameCanvas;
Element scoreBoard;
Element startBtn;
Element timeDisplay;
Element loginBtn;
//score
int cnt;
int cntForAnimate;
int level;
bool going;
//timer
RequestAnimationFrameCallback _callback;
num _whenStarted;
//facebook
final fbAppID = "1691957414394781";
final fbAppSecret = "f32ba829b522d4edd5de8b404523801c";


void main() {
  // initFacebook();
	initGame();
	initEvent();
}

void initGame() {
  loginBtn = querySelector('.login-btn');
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
  loginBtn.onMouseUp.listen((MouseEvent) {
    new Timer(const Duration(milliseconds:500), (){
      querySelector("#loginModal").classes.add("hidden");
    });
  });
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
  //show madal
  Element modal = querySelector("#myModal");
  modal.classes.toggle("hidden");
  //setup madal
  ImageElement resultImg = modal.querySelector(".result-picture");
  resultImg.src = "source/${level}.png";

  modal.querySelector(".result-score").text = "你按了${cnt}下";
  modal.querySelector("p").text = "你成功破壞房子${level*10}%！....";

  modal.querySelector(".restart-btn").onClick.listen((MouseEvent) => window.location.reload()); 
  //save score
  js.context.callMethod("FBupdateSore", ["$cnt"]);
}

int levelUp() => level*level + 5;

void initFacebook() {
    querySelector('.login-btn').click();
}

