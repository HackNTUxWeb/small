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
//facebook
final fbAppID = "1691957414394781";
final fbAppSecret = "f32ba829b522d4edd5de8b404523801c";


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
  //setup mate
  MetaElement meta = new MetaElement();
  meta.attributes["og:description"] = "我的成績是${cnt}，房子已經${level*10}%損毀！快來試試你能頗壞到什麼程度！";
  meta.attributes["og:image"] = "http://hackntuxweb.github.io/small/Azalea/web/source/${level}.png";
  //show madal
  Element modal = querySelector("#myModal");
  modal.classes.toggle("hidden");
  //setup madal
  ImageElement resultImg = modal.querySelector(".result-picture");
  resultImg.src = "source/${level}.png";

  modal.querySelector(".result-score").text = "你按了${cnt}下";
  modal.querySelector("p").text = "你成功破壞房子${level*10}%！....";

  modal.querySelector("restart-btn").onClick.listen((MouseEvent) => window.location.reload()); 
}

int levelUp() => level*level + 5;

