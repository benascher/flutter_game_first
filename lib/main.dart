import 'package:flutter/material.dart';

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

  // Obstacle position and size
  final double obstacleTop = 200.0;
  final double obstacleLeft = 100.0;
  final double obstacleWidth = 100.0;
  final double obstacleHeight = 100.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _controller.addListener(() {
      setState(() {
        // Update velocity based on acceleration
        velocityX += accelerationX;
        velocityY += accelerationY;

        top += velocityY;
        left += velocityX;

        // Apply friction
        velocityX *= 0.95;
        velocityY *= 0.95;

        // Stop the character when its speed is very low
        if (velocityX.abs() < 0.1) velocityX = 0;
        if (velocityY.abs() < 0.1) velocityY = 0;

        // Bounce when hitting the edge of the screen
        if (left < 0) {
          left = 0;
          velocityX = velocityX.abs();
        } else if (left + characterWidth > MediaQuery.of(context).size.width) {
          left = MediaQuery.of(context).size.width - characterWidth;
          velocityX = -velocityX.abs();
        }
        if (top < 0) {
          top = 0;
          velocityY = velocityY.abs();
        } else if (top + characterHeight > MediaQuery.of(context).size.height) {
          top = MediaQuery.of(context).size.height - characterHeight;
          velocityY = -velocityY.abs();
        }

        // Bounce when hitting the obstacle
        if (left + characterWidth > obstacleLeft && left < obstacleLeft + obstacleWidth &&
            top + characterHeight > obstacleTop && top < obstacleTop + obstacleHeight) {
          if (velocityX > 0) {
            left = obstacleLeft - characterWidth;
            velocityX = -velocityX.abs();
          } else if (velocityX < 0) {
            left = obstacleLeft + obstacleWidth;
            velocityX = velocityX.abs();
          }
          if (velocityY > 0) {
            top = obstacleTop - characterHeight;
            velocityY = -velocityY.abs();
          } else if (velocityY < 0) {
            top = obstacleTop + obstacleHeight;
            velocityY = velocityY.abs();
          }
        }
      });
    });
    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}