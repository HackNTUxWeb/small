import 'dart:html';
import 'dart:async';
import 'dart:math';
import 'dart:js' as js;

import 'comment.dart';

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
  level = 0;
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
        gameCanvas.querySelector(".gh-$level").classes.toggle("hidden");
        gameCanvas.querySelector(".gh-${++level}").classes.toggle("hidden");
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
    gameCanvas.classes.add('hammer-cursor');
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

  querySelector('.close-login-modal').onClick.listen((MouseEvent) {
      querySelector("#loginModal").classes.add("hidden");
    });
}

void showResult() {
  //show madal
  Element modal = querySelector("#myModal");
  modal.classes.toggle("hidden");
  //setup madal
  ImageElement resultImg = modal.querySelector(".result-picture");
  resultImg.src = "source/${level}.png";

  modal.querySelector(".result-score").text = "你點了${cnt}下";
  int commentIndex = min(cnt ~/ 5, comments.length);
  modal.querySelector(".commet").text = "你破壞了${level*10}%的房子！${comments[commentIndex]}";
  modal.querySelector(".ad").innerHtml = "棄舊才能換新，破壞才能重建<br>3/19, 20來城市設計黑客松，創造更好的新的城市！";

  modal.querySelector(".restart-btn").onClick.listen((MouseEvent) => window.location.reload()); 
  modal.querySelector(".share-btn").onClick.listen((MouseEvent) => js.context.callMethod("FBShareScore", [cnt, level])); 
  //save score and then show list of friend's scores
  uploadScore().then((_) {
    getFriendsScore().then((List scoreList) {
      scoreList.sort((a, b) => (-1) * (a['score'] - b['score']));
      for (Map record in scoreList) {
        //print("mk list: ${record['name']}, ${record['score']}");
        Element e = new Element.html('<li class="list-group-item">${record['name']}<span class="badge score">${record['score']}</span></li>');
        querySelector('.friends-sores-list').children.add(e);
      }
    });
  });
}

int levelUp() {
  switch(level) {
    case 0: return 5;
    case 1: return 15;
    case 2: return 30;
    case 3: return 40;
    case 4: return 55;
    case 5: return 70;
    case 6: return 80;
    case 7: return 90;
    case 8: return 95;
    case 9: return 100;
    default: return 150;
  }
  // (level+1) * (level+1) + 5;
  // return 10 * (level + 1);
}

Future downloadScore() {
  //print("download score");
  Completer cmpl = new Completer();
  var handler = (js.JsObject response) {
    if (response != null && response['error'] == null) {
      js.JsArray myScores = response['data'];
      int oldScore = myScores[1]['score'];
//print("recieve score: $oldScore");
      for (int i = 2; i < myScores.length; i++) {
        if (myScores[i]['score'] > oldScore)
          oldScore = myScores[i]['score'];
      }
      if (myScores.length <= 1 || cnt > oldScore) {
        //print('upload');
        cmpl.complete(true);
      } else {
        //print('do not upload');
        cmpl.complete(false);
      }
    } else {
      cmpl.completeError("load score failed");
    }
  };
  js.context.callMethod("FBGetOwnScore", [handler]);
  return cmpl.future;
}

Future uploadScore() {
  Completer cmpl = new Completer();
  downloadScore().then((shouldUpload) {
  //print("upload score");
    var handler = (js.JsObject response) {
      if (response != null && response['error'] == null) {
        //print('upload success');
        cmpl.complete();
      }
    };

    if (shouldUpload) {
      js.context.callMethod("FBupdateSore", ["$cnt", handler]);
    } else {
        //print('do not upload');
        cmpl.complete();
    }
  });
  return cmpl.future;
}

Future getFriendsScore() {
  Completer cmpl = new Completer();
  var handler = (response) {
    if (response != null && response['error'] == null) {
      js.JsArray records = response['data'];
        List<Map> scores = new List<Map>();
        for (var record in records) {
          Map score = new Map();
          score['name'] = record['user']['name'];
          score['score'] = record['score'];
          scores.add(score);
        }
        cmpl.complete(scores);
      } else {
        cmpl.completeError("response error");
      }
    };
  js.context.callMethod("FBAskfriendScores", [handler]);
  return cmpl.future;
}

