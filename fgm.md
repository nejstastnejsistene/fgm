# Finite Galaxian Machine

The classic game Galaxian, implemented as a completely deterministic state machine. This way, a game can be replayed from the sequence of input states and some sort of backtracking AI could be made.

```haskell
data GalaxianState = ...

data JoystickState = TiltLeft | Neutral | TiltRight
type ButtonState Bool -- Edge triggered
data InputState = InputState JoystickState ButtonState

step :: GalaxianState -> InputState -> GalaxianState
```

### Why?

* I like the determinism of arcade games, [particularly in pacman](http://www.mameworld.info/net/pacman/patterns.html).
* I learned to program by programming arcade games in Java, and I'm familiar with the messiness of mixing logic and graphics. This is inspired by my desire (cool rhyme!) to completely separate the two.
* I like the idea that the game could be simulated separately from playing it, which could be used for verifying high scores or for smarter AI.
* I'm always looking for an excuse to use haskell and think functionally.
* I've been looking for something interesting to use as the 404 page for my website, and this could do.

### Playback format

A single input state has six possible combinations (3 joystick positions times 2 button states), which takes up 4 bits. Assuming 60fps, a recorded game would take up 30b/s, or 1.8kB/min, and would probably compress well if size becomes an issue. This could be stored with the version or hash of the game to solve backwards-incompatibility.