# Finite Galaxian Machine

The classic game Galaxian, implemented as a completely deterministic state machine. This way, a game can be replayed from the sequence of input states and some sort of backtracking AI could be made.

```haskell
data GalaxianState = ...

data JoystickState = TiltLeft | Neutral | TiltRight
data ButtonState = Pressed | NotPressed
data InputState = InputState JoystickState ButtonState

step :: GalaxianState -> InputState -> GalaxianState
```

