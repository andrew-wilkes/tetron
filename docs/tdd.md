# Technical Design Document.

## Timers

Have a ticker that moves the shape downwards at a rate depending on the level.

period = 1 / level

Have a keyboard repeat delay timer (repeater) for moving when a key is held down.

Level up timer. Periodically increase the level until max level.

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

    Page Up pressed
        Increase level if not max

    Pause pressed
        Toggle pause flag

    Music On/Off button
        Toggle music player on/off

## Major functions

Check for valid move

Check for completed lines

Add shape to grid
