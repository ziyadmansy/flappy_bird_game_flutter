import 'dart:async';

import 'package:cool_alert/cool_alert.dart';
import 'package:flappy_bird/barriers.dart';
import 'package:flappy_bird/bird.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  static const String ROUTE_NAME = '/homePageScreen';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String HIGH_SCORE_KEY = 'highScore';
  static double birdYAxis = 0;
  double time = 0;
  double height = 0;
  double initialHeight = birdYAxis;

  double upperbarrierOneHeight = 0.0;
  double lowerBarrierOneHeight = 0.0;

  double upperbarrierTwoHeight = 0.0;
  double lowerBarrierTwoHeight = 0.0;

  static double barrierXOne = -2.5;
  double barrierXTwo = barrierXOne + 1.75; // 0.75

  int score = 0;
  int highScore = 0;

  bool gameStarted = false;

  Timer scoreTimer;

  void setInitialValues() {
    setState(() {
      birdYAxis = 0;
      time = 0;
      height = 0;
      initialHeight = birdYAxis;
      barrierXOne = -2.5;
      barrierXTwo = barrierXOne + 1.75;
      score = 0;
    });
  }

  Future<void> getHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt(HIGH_SCORE_KEY) ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    getHighScore();
    setInitialValues();
  }

  Future<void> showLoseDialog() async {
    await CoolAlert.show(
      context: context,
      type: CoolAlertType.info,
      title: 'Game Over',
      text: score <= 0 ? 'Hard Luck 😂' : 'Great! you got $score points! 🤩',
      confirmBtnText: 'Retry',
      cancelBtnText: 'Exit',
      confirmBtnColor: Colors.cyan,
      cancelBtnTextStyle: TextStyle(
        color: Colors.red[900],
      ),
      showCancelBtn: true,
      barrierDismissible: false,
      animType: CoolAlertAnimType.rotate,
      backgroundColor: Colors.lightBlueAccent,
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        setInitialValues();
      },
      onCancelBtnTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
  }

  void jump() {
    setState(() {
      time = 0;
      initialHeight = birdYAxis;
    });
  }

  void startGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    gameStarted = true;
    setState(() {
      birdYAxis = 0;
      time = 0;
      height = 0;
      initialHeight = birdYAxis;
      barrierXOne = -2.5;
      barrierXTwo = barrierXOne + 1.75;
      score = 0;
    });
    scoreTimer = Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        if (gameStarted) {
          setState(() {
            score++;
          });
        }
      },
    );
    Timer.periodic(Duration(milliseconds: 50), (timer) async {
      time += 0.05;
      height = -4.9 * time * time + 2.0 * time;
      setState(() {
        birdYAxis = initialHeight - height;
        if (barrierXOne > 2) {
          barrierXOne -= 3.5;
        } else {
          barrierXOne += 0.04;
        }
        if (barrierXTwo > 2) {
          barrierXTwo -= 3.5;
        } else {
          barrierXTwo += 0.04;
        }
      });
      if (birdYAxis > 1.1) {
        timer.cancel();
        scoreTimer.cancel();
        if (score > highScore) {
          highScore = score;
          await prefs.setInt(HIGH_SCORE_KEY, highScore);
        }
        setState(() {});
        gameStarted = false;
      }

      if (barrierXOne >= -0.25 && barrierXOne <= 0.25) {
        if (birdYAxis <= -0.2 || birdYAxis >= 0.6) {
          timer.cancel();
          scoreTimer.cancel();
          gameStarted = false;
          if (score > highScore) {
            highScore = score;
            await prefs.setInt(HIGH_SCORE_KEY, highScore);
          }
          setState(() {});
          await showLoseDialog();
        }
      }

      if (barrierXTwo >= -0.25 && barrierXTwo <= 0.25) {
        if (birdYAxis <= -0.6 || birdYAxis >= 0.2) {
          timer.cancel();
          scoreTimer.cancel();
          gameStarted = false;
          if (score > highScore) {
            highScore = score;
            await prefs.setInt(HIGH_SCORE_KEY, highScore);
          }
          setState(() {});
          showLoseDialog();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    upperbarrierOneHeight = screenHeight / 2.5;
    lowerBarrierOneHeight = screenHeight / 5;

    upperbarrierTwoHeight = screenHeight / 5;
    lowerBarrierTwoHeight = screenHeight / 2.5;
    return GestureDetector(
      onTap: () {
        if (gameStarted) {
          jump();
        } else {
          startGame();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            AnimatedContainer(
              alignment: Alignment(0, birdYAxis),
              duration: Duration(milliseconds: 0),
              child: MyBird(),
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage(
                    'assets/images/game_wallpaper.jpg',
                  ),
                ),
              ),
            ),
            gameStarted
                ? Container()
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 120,
                        ),
                        Text(
                          'Tap to play',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 24.0,
                            letterSpacing: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
            AnimatedContainer(
              alignment: Alignment(barrierXOne, -1.1),
              duration: Duration(seconds: 0),
              child: MyBarrier(
                size: upperbarrierOneHeight,
              ),
            ),
            AnimatedContainer(
              alignment: Alignment(barrierXOne, 1.1),
              duration: Duration(seconds: 0),
              child: MyBarrier(
                size: lowerBarrierOneHeight,
              ),
            ),
            AnimatedContainer(
              alignment: Alignment(barrierXTwo, -1.1),
              duration: Duration(seconds: 0),
              child: MyBarrier(
                size: upperbarrierTwoHeight,
              ),
            ),
            AnimatedContainer(
              alignment: Alignment(barrierXTwo, 1.1),
              duration: Duration(seconds: 0),
              child: MyBarrier(
                size: lowerBarrierTwoHeight,
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                width: screenWidth / 2.5,
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    width: 2,
                    color: Colors.white,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          score.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          'Game\nScore'.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                width: screenWidth / 2.5,
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    width: 2,
                    color: Colors.white,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          highScore.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          'Highest\nScore'.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
