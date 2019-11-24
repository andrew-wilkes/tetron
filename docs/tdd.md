# Technical Design Document

## Shapes

All shapes exist inside a bounding square and rotate about the center of this square unless obstructed. Shapes of width 3 (J, L, S, T, Z) are placed in the top two rows of the bounding square and (for J, L, and T) with the flat side down. I is placed in the top middle row.

All shapes spawn in 2 usually hidden rows at the top of the playfield. They are placed in the center of these rows, rounding to the left. Once a shape lands, it does not lock until the lock delay expires. The lock delay behavior, called Infinity by the Tetris Company, resets the lock delay whenever the shape is moved or rotated.

### Shape Patterns
![Shape Patterns](https://github.com/andrew-wilkes/tetron/blob/master/docs/shapes-grid.png)

### Local grid coordinates
![3x3 grid](https://github.com/andrew-wilkes/tetron/blob/master/docs/3x3.png)

![4x4 grid](https://github.com/andrew-wilkes/tetron/blob/master/docs/4x4.png)

### Shape rotation
Clockwise rotation: x = -y, y = x

Anti-clockwise rotation: x = y, y = -x

## Timers

Have a ticker that moves the shape downwards at a rate depending on the level.

period = 1 / level

Have a keyboard repeat delay timer (repeater) for moving when a key is held down.

Level up timer. Periodically increase the level until max level.

Lock Timer - to delay locking of shape into grid.

## State

The game will be *stopped* or *playing* (*paused* or *not paused*).

The states are so simple that we may use *playing* and *paused* booleans to store the current state.

## Event processing

The game will be driven by events from user input or timers.

    New game button pressed
        Reset game
        Start ticker
        playing = true

    Ticker ticked
        Try to move shape down
        If stuck:
            Add shape to grid
            Check lines
            Remove lines
            Update score
        If end of game:
            Stop ticker
            playing = false
            Display "Game Over"
            Save new high score
        else:
            Add shape

    Left pressed
        Try to move left

    Right pressed
        Try to move right

    Rotate pressed
        Try to rotate

    Down just pressed
        Set ticker period to soft drop speed

    Down released
        Reset ticker period

    Space just pressed
        Set ticker period to hard drop speed

    Page Up pressed or Level-up timer expired
        Increase level if not max

    Pause pressed
        Toggle pause flag

    Music On/Off button
        Toggle music player on/off

## Major functions

Check for valid move

Check for completed lines

Add shape to grid
