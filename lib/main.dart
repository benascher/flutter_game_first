import 'dart:math';

import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MaterialApp(
    home: DraggableCharacter(),
  ));
}

class DraggableCharacter extends StatefulWidget {
  const DraggableCharacter({Key? key}) : super(key: key);

  @override
  _DraggableCharacterState createState() => _DraggableCharacterState();
}

class _DraggableCharacterState extends State<DraggableCharacter> with SingleTickerProviderStateMixin {
  double top = 0;
  double left = 0;
  double velocityX = 0; // horizontal velocity
  double velocityY = 0; // vertical velocity
  double accelerationX = 0; // horizontal acceleration
  double accelerationY = 0.15; // vertical acceleration (gravity)
  late AnimationController _controller;
  final double characterWidth = 50.0;
  final double characterHeight = 50.0;
  final double characterMass = 1.0; // mass of the character

  // Obstacle position and size
  final double obstacleTop = 200.0;
  final double obstacleLeft = 100.0;
  final double obstacleWidth = 100.0;
  final double obstacleHeight = 100.0;
  final double obstacleMass = 10000.0; // mass of the obstacle


  // Second obstacle position and size
  final double obstacle2Top = 300.0;
  final double obstacle2Left = 200.0;
  final double obstacle2Width = 100.0;
  final double obstacle2Height = 100.0;

  // Air resistance
  final double airResistance = 0.01;

  int score = 0; // Add a score variable

  List<Bullet> bullets = [];

  int currentWorld = 1;

  // AudioCache audioCache = AudioCache(); // Add this line

  @override
  void initState() {
    super.initState();
    // audioCache.play('short.mp3');
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _controller.addListener(() {
      setState(() {
        // Update velocity based on acceleration
        velocityX += accelerationX;
        velocityY += accelerationY;

        // Apply air resistance
        velocityX -= airResistance * velocityX;
        velocityY -= airResistance * velocityY;

        

        // Apply friction
        velocityX *= 0.95;
        velocityY *= 0.95;

        // Stop the character when its speed is very low
        if (velocityX.abs() < 0.1) velocityX = 0;
        if (velocityY.abs() < 0.1) velocityY = 0;

        top += velocityY;
        left += velocityX;

        // Bounce when hitting the edge of the screen
        if (left < 0) {
          left = 0;
          velocityX = velocityX.abs();}
        // } else if (left + characterWidth > MediaQuery.of(context).size.width) {
        //   left = MediaQuery.of(context).size.width - characterWidth;
        //   velocityX = -velocityX.abs();
        // }
        if (top < 0) {
          top = 0;
          velocityY = velocityY.abs();
        } else if (top + characterHeight > MediaQuery.of(context).size.height-50) {
          top = MediaQuery.of(context).size.height - characterHeight -50;
          velocityY = -velocityY.abs();
        }

        // Bounce when hitting the obstacle
        if (left + characterWidth > obstacleLeft && left < obstacleLeft + obstacleWidth &&
            top + characterHeight > obstacleTop && top < obstacleTop + obstacleHeight) {
          // Calculate the total momentum before the collision
          double totalMomentumX = characterMass * velocityX + obstacleMass * 0; // assuming the obstacle is stationary
          double totalMomentumY = characterMass * velocityY + obstacleMass * 0; // assuming the obstacle is stationary

          // After the collision, the character's velocity is the total momentum divided by the character's mass
          velocityX = totalMomentumX / characterMass;
          velocityY = totalMomentumY / characterMass;

          // Reverse the direction of the velocity to simulate a bounce
          velocityX = -velocityX;
          velocityY = -velocityY;

          top += velocityY;
          left += velocityX;

          if (velocityX.abs() >= 0.1 || velocityY.abs() >= 0.4) {
            score++; // Increase the score when the character hits the obstacle
          }
          // score++; // Increase the score when the character hits the obstacle
        
          // audioCache.play('short.mp3'); // Play the sound effect
        }
      });

          // Move the bullets
    bullets.forEach((bullet) {
      bullet.left += bullet.velocityX;
      bullet.top += bullet.velocityY;
    });

    // Remove bullets that are off-screen
    bullets.removeWhere((bullet) => bullet.left < 0 || bullet.left > MediaQuery.of(context).size.width);

    if (left + characterWidth > MediaQuery.of(context).size.width) {
      currentWorld++;
      left = 0; // Reset the character's position to the left edge of the screen
    }

        // Bounce when hitting the second obstacle (only in the second world)
    if (currentWorld == 2 &&
        left + characterWidth > obstacle2Left && left < obstacle2Left + obstacle2Width &&
        top + characterHeight > obstacle2Top && top < obstacle2Top + obstacle2Height) {
      // Calculate the total momentum before the collision
      double totalMomentumX = characterMass * velocityX + obstacleMass * 0; // assuming the obstacle is stationary
      double totalMomentumY = characterMass * velocityY + obstacleMass * 0; // assuming the obstacle is stationary

      // After the collision, the character's velocity is the total momentum divided by the character's mass
      velocityX = totalMomentumX / characterMass;
      velocityY = totalMomentumY / characterMass;

      // Reverse the direction of the velocity to simulate a bounce
      velocityX = -velocityX;
      velocityY = -velocityY;

      top += velocityY;
      left += velocityX;

      if (velocityX.abs() >= 0.1 || velocityY.abs() >= 0.4) {
        score++; // Increase the score when the character hits the obstacle
      }
    }

    });
    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: (details) {
          shoot(details.globalPosition);
        },
        child:Scaffold(
          backgroundColor: Colors.white38,
      body:  Stack(
          children: <Widget>[
            Positioned(
              top: top,
              left: left,
              child: Draggable(
                child: Container(width: characterWidth, height: characterHeight, color: Colors.red),
                feedback: Container(width: characterWidth, height: characterHeight, color: Colors.red.withOpacity(0.5)),
                onDragEnd: (details) {
                  setState(() {
                    // Set the initial velocities based on the drag speed
                    velocityX = details.velocity.pixelsPerSecond.dx / 60;
                    velocityY = details.velocity.pixelsPerSecond.dy / 60;
                  });
                },
              ),
            ),
            Positioned(
              top: obstacleTop,
              left: obstacleLeft,
              child: Container(width: obstacleWidth, height: obstacleHeight, color: Colors.blue),
            ),
            Positioned( // Add a Text widget to display the score
              top: 20,
              right: 20,
              child: Text('Score: $score', style: TextStyle(fontSize: 24)),
            ),
                    // Draw the bullets
          ...bullets.map((bullet) => Positioned(
            top: bullet.top,
            left: bullet.left,
            child: Container(width: 10, height: 10, color: Colors.yellow), // adjust size and color as needed
          )),
        
          // Add a button to shoot
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: shootButton,
              child: Text('Shoot'),
            ),
          ),
          Positioned( // Add a Text widget to display the current world
            top: 20,
            left: 20,
            child: Text('World: $currentWorld', style: TextStyle(fontSize: 24)),
          ),
                  if (currentWorld == 2) Positioned( // Add a second obstacle in the second world
          top: obstacle2Top,
          left: obstacle2Left,
          child: Container(width: obstacle2Width, height: obstacle2Height, color: Colors.blue),
        ),
          ],
        ),
      ),
    );
  }

  void shootButton() {
    setState(() {
      bullets.add(Bullet(top: top, left: left, velocityX: 5, velocityY: 0)); // adjust velocityX and velocityY as needed
    });
  }

  void shoot(Offset tapPosition) {
    double dx = tapPosition.dx - left;
    double dy = tapPosition.dy - top;
    double magnitude = sqrt(dx * dx + dy * dy);
    double velocityX = 5 * dx / magnitude; // 5 is the speed of the bullet
    double velocityY = 5 * dy / magnitude; // 5 is the speed of the bullet

    setState(() {
      bullets.add(Bullet(top: top, left: left, velocityX: velocityX, velocityY: velocityY));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Bullet {
  double top;
  double left;
  double velocityX;
  double velocityY;

  Bullet({required this.top, required this.left, required this.velocityX, required this.velocityY});
}