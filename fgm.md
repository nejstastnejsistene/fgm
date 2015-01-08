# Finite Galaxian Machine

The classic game Galaxian, implemented as a completely deterministic state machine. This way, a game can be replayed from the sequence of input states and some sort of backtracking AI could be made.

```haskell
data GalaxianState = ...

data JoystickState = TiltLeft | Neutral | TiltRight
type ButtonState Bool -- Edge triggered
data InputState = InputState JoystickState ButtonState

step :: GalaxianState -> InputState -> GalaxianState
```

### Playback format

A single input state has six possible combinations (3 joystick positions times 2 button states), which takes up 4 bits. Assuming 60fps, a recorded game would take up 30b/s, or 1.8kB/min, and would probably compress well if size becomes an issue. This could be stored with the version or hash of the game to solve backwards-incompatibility.