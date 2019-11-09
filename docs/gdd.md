# Game Design Document

Tetron is a Tetris clone.

The game mechanics and shapes will be based on the classic Tetris game as described in this [Wikipedia Article](https://en.wikipedia.org/wiki/Tetris).

## Controls

* Space bar - Hard drop
* Down arrow - Soft drop
* Left arrow - move left
* Right arrow - move right
* Up arrow - rotate clockwise
* Shift + Up arrow - rotate anti-clockwise
* Page Up - increase level on each press
* New Game button
* Pause button
* Music On/Off button
* About button - pop's up a window to show the above info. about the game controls

## Scene Elements

10 col x 20 row grid of squares to contain the game pieces.

Statistics:
* High score
* Level
* Score
* Lines

Next shape.

Game Over banner.

New Game button.

Pause button.

Music On/Off button.

About button.

## Shapes

These will be textures arranged in a grid that have a grid map, color, and a probability of occurence.

## Scoring

Single line 100 points

2 lines 200 points

3 lines 400 points

4 lines 800 points

## Saving/Loading

When the game is loaded, try to load a high score file.

When the game ends, save any new high score to a high score file.

## Sounds

Play a background music loop if enabled when the game is being played.

Play a bleep when shape is placed.

Play a jingle when clearing lines.

## Animations

Have a visual effect when clearing lines.
