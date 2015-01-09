module FGM where

import           Data.Default
import           Data.List
import           Data.VectorSpace
import           InputState

class HitBox a where
    intersects :: a -> Vector -> Bool

withinRadius :: Double -> Vector -> Vector -> Bool
withinRadius r pos pos' = magnitude (pos ^-^ pos') < r

class Ticker a where
    tick :: a -> InputState -> a

type Vector = (Double, Double)

data Timer = Finished | Ticking Int deriving Show

instance Ticker Timer where
    tick Finished _ = error "unhandled finished timer"
    tick (Ticking 0) _ = Finished
    tick (Ticking n) _ = Ticking (n - 1)

data GameState = GameState
    { galaxip :: Galaxip
    , bombs   :: [Bomb]
    } deriving Show

instance Default GameState where
    def = GameState
        { galaxip = def
        , bombs = def
        }

instance Ticker GameState where
    tick s i = s
        { galaxip = galaxip''
        , bombs = bombs''
        }
      where
        galaxip' = tick (galaxip s) i
        bombs' = [tick b i | b <- bombs s]
        bombCollisions = case galaxipState galaxip' of
            Flying -> filter (intersects galaxip' . bombPos) bombs'
            _      -> []
        (galaxip'', bombs'') = case bombCollisions of
          -- Galaxip is not hit.
          [] -> (galaxip', bombs')
          -- Galaxip collides with the first intersecting bomb.
          x:_ ->
              ( galaxip' { galaxipState = Exploding (Ticking 50) }
              , delete x bombs'
              )

data Galaxip = Galaxip
    { shipsRemaining :: Int
    , galaxipState   :: GalaxipState
    , galaxipPos     :: Vector
    , missile        :: Missile
    } deriving Show

instance Default Galaxip where
    def = Galaxip
        { shipsRemaining = 3
        , galaxipState = def
        , galaxipPos = def
        , missile = def
        }

instance HitBox Galaxip where
    intersects g = withinRadius 10 p
      where p = galaxipPos g

instance Ticker Galaxip where
    -- Handle movement and firing.
    tick g@(Galaxip _ Flying pos miss) (InputState joystick button) = g
      { galaxipPos = move joystick
      , missile = updateMissile miss button
      }
      where
        -- Move the galaxip.
        move TiltLeft  = pos ^-^ delta
        move TiltRight = pos ^+^ delta
        move Neutral   = pos
        -- How much the galaxip moves per tick.
        delta = (1,0)
        -- Update the missile.
        updateMissile Loaded False = Loaded
        updateMissile Loaded True  = Firing (pos ^+^ missileStartOffset)
        updateMissile (Firing p) _ = Firing (p ^+^ missileDelta)
        -- How far above the ship the missile starts from.
        missileStartOffset = (0,10)
        -- How much the missile moves per tick.
        missileDelta = (0,-1)
    -- Count down the timer, setting to destroyed once complete.
    tick g@(Galaxip _ (Exploding t) _ _) i = case tick t i of
        Finished -> g { galaxipState = Destroyed }
        t'       -> g { galaxipState = Exploding t' }
    -- Ship is destroyed; do nothing.
    tick g _ = g

data GalaxipState = Flying | Exploding Timer | Destroyed deriving Show

instance Default GalaxipState where
    def = Flying

data Missile = Loaded | Firing Vector deriving Show

instance Default Missile where
    def = Loaded

data Bomb = Bomb { bombPos :: Vector } deriving (Eq, Show)

instance Ticker Bomb where
    tick (Bomb pos) _ = Bomb (pos ^+^ delta)
      where delta = (0,1) -- How much the bomb moves per tick.