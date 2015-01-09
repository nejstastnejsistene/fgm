module InputState where

import           Data.Bits
import           Data.Char

data InputState = InputState JoystickState ButtonState deriving Show
data JoystickState = TiltLeft | Neutral | TiltRight deriving Show
type ButtonState = Bool

encode :: [InputState] -> String
encode [] = [chr 0]
encode [x] = [chr $ encode' x `shift` 4]
encode (x:y:zs) = chr (encode' x `shift` 4 .|. encode' y) : encode zs

decode :: String -> [InputState]
decode [] = []
decode (x:xs) = y : z : decode xs
  where
      x' = ord x
      y = decode' (x' `shiftR` 4)
      z = decode' (x' .&. 7)

encode' :: InputState -> Int
encode' (InputState j b) = encodeJoystick j * encodeButton b
  where
      encodeJoystick Neutral = 0
      encodeJoystick TiltLeft = 1
      encodeJoystick TiltRight = 2
      encodeButton False = 0
      encodeButton True = 1

decode' :: Int -> InputState
decode' 0 = InputState Neutral False
decode' 1 = InputState TiltLeft False
decode' 2 = InputState TiltRight False
decode' 3 = InputState Neutral True
decode' 4 = InputState TiltLeft True
decode' 5 = InputState TiltRight True
decode' _ = error "invalid value"