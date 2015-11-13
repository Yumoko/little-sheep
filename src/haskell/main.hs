import SDL
import Linear
import Linear.Affine
import qualified Data.Text as Text
import Foreign.C.Types
import GHC.Word
import qualified SDL.Image
import Control.Monad (unless, when)
import Data.List (find)
import Sdl2
import Types


screenWidth = 640
screenHeight = 400
initWindow = defaultWindow {windowInitialSize = V2 screenWidth screenHeight}

vsyncRendererConfig = 
  RendererConfig
   { SDL.rendererType = SDL.AcceleratedVSyncRenderer
   , SDL.rendererTargetTexture = False
   }

main :: IO ()
main = do
  initializeAll

  HintRenderScaleQuality $= ScaleLinear
  do renderQuality <- get HintRenderScaleQuality
     when (renderQuality /= ScaleLinear) $
       putStrLn "Warning: Linear texture filtering not enabled!"

  window <- createWindow (Text.pack "Little Sheep 0.1") initWindow
  renderer <- createRenderer window (-1) vsyncRendererConfig --defaultRenderer
  rendererDrawColor renderer $= V4 255 255 255 0

  back <- loadTexture renderer "../../images/background_sky.gif"
  islandT <- loadTexture renderer "../../images/island.gif"
  cloudT <- loadTexture renderer "../../images/cloud_back.gif"
  
  left <- loadTexture renderer "../../images/sheep_left.gif"
  right <- loadTexture renderer "../../images/sheep.gif"
  dLetf <- loadTexture renderer "../../images/sheep_down_left.gif"
  dRight <- loadTexture renderer "../../images/sheep_down_right.gif"

  let islandPos = slow 2 $ zip ([40,42..295] ++ [295,293..40]) (cycle (slow 2 $ [120,122..150]++[150,148..120]))
      island = Object (cycle islandPos) 350 240 islandT "Island"

      st = SheepTextures left right dLetf dRight
      sheepPos = map (\(x,y) -> (x+50,y)) islandPos
      sheep = Sheep (cycle sheepPos) Lefty 100 90 st
      
      cloud = Object (cycle [(0,0)]) screenWidth screenHeight cloudT "Cloud"
      world = World (Sys screenWidth screenHeight 60)
                    renderer
                    back
                    [cloud, island]
                    sheep

  appLoop world

  destroyRenderer renderer
  destroyWindow window
  quit

--------------------------------------------------------------------------
{- Game Loop -}

appLoop :: World -> IO ()
appLoop w = 
  do renderWorld w

     event <- pollEvent

     unless (isEventKey KeycodeQ event) 
            (appLoop $ updateWorld event w)

--------------------------------------------------------------------------
{- Rendering -}

renderWorld :: World -> IO ()
renderWorld w = 
  let r = render w
      b = background w
      os = objects w
      s = sheep w
  in do clear r
        renderTexture r b (0,0)
        sequence $ map (renderObject r) os
        renderSheep r s
        present r

renderObject :: Renderer -> Object -> IO ()
renderObject r o = 
  let t = objTexture o
      (p:ps) = objPos o
      w = objWidth o
      h = objHeight o in 
  renderSprite r t (0,0) p w h


renderSheep :: Renderer -> Sheep -> IO ()
renderSheep  r s =
  let p = head $ sheepPos s
      st = sheepTextures s
      t = case sheepDirect s of
           Lefty  -> stLeft st
           LDown  -> stDownLeft st
           Righty -> stRight st
           RDown  -> stDownRight st
  in renderSprite r t (0,0) p (sheepWidth s) (sheepHeight s) 

--------------------------------------------------------------------------
{- Updating -}

updateWorld :: Maybe Event -> World -> World
updateWorld e w = let os = objects w
                      s = sheep w
                      mb = getMaxBounds w
                      newObjects = map updateObject os
                      newSheep = updateSheep (eventToCommand e) mb s
                  in  w { objects = newObjects, sheep = newSheep } 

updateObject :: Object -> Object
updateObject o = o { objPos = tail $ objPos o }

updateSheep :: Command -> MaxBounds -> Sheep -> Sheep
updateSheep c mb = updateSheepPos c mb . updateSheepDir c

updateSheepPos :: Command -> MaxBounds -> Sheep -> Sheep
updateSheepPos Continue mb s = s {sheepPos = tail $ sheepPos s}
updateSheepPos Eat mb s = s {sheepPos = tail $ sheepPos s}
updateSheepPos Fly mb s = fly s
updateSheepPos c mb s = move c mb s  

move :: Command -> MaxBounds -> Sheep -> Sheep
move c (l,r) s = 
  let check GoLeft  (x,y) | x - 5 > l = \(x,y) -> (x - 5,y)
                          | otherwise = id
      check GoRight (x,y) | x + 5 < r = \(x,y) -> (x + 5,y)
                          | otherwise = id
      check _ _ = id

      f = check c (head $ sheepPos s)

  in s {sheepPos = tail $ map f (sheepPos s)}

fly :: Sheep -> Sheep
fly s =
  case sheepDirect s of
    Lefty  -> s { sheepPos = flyLeft } 
    LDown  -> s { sheepPos = flyLeft }
    Righty -> s { sheepPos = flyRight }
    RDown  -> s { sheepPos = flyRight }
  
  where (x,y) = head $ sheepPos s
        xMax = screenWidth + (sheepWidth s) 
        xMin = -1 * (sheepWidth s)
        yMax = screenWidth + (sheepHeight s)
        garage = cycle [((-1*sheepWidth s ),(-1*sheepHeight s ))]
        flyLeft = (zip [x, x-5..xMin] [y,y+5..yMax]) ++ garage
        flyRight = (zip [x, x+5..xMax] [y,y+5..yMax]) ++ garage

updateSheepDir :: Command -> Sheep -> Sheep
updateSheepDir GoLeft s = s {sheepDirect = Lefty}
updateSheepDir GoRight s = s {sheepDirect = Righty}
updateSheepDir Eat s 
 | sheepDirect s  == Lefty = s {sheepDirect = LDown}
 | sheepDirect s  == Righty = s {sheepDirect = RDown}
 | otherwise = s 
  
updateSheepDir Fly s = 
  let ((x1,y1):(x2,y2):ps) = sheepPos s
      d  = sheepDirect s
      d' = nextDir x1 y1 x2 y2 d 
  in s { sheepDirect = d' }
  
  where nextDir x y x' y' d
         | x == x'   = d
         | x > x'    = if y < y' 
                       then Lefty 
                       else if y > y' then LDown else Lefty
         | otherwise = if y < y' 
                       then Righty
                       else if y > y' then RDown else Righty
updateSheepDir _ s = s
--------------------------------------------------------------------------
{- Events -}

eventToCommand :: Maybe Event -> Command
eventToCommand Nothing = Continue
eventToCommand e 
 | isEventKey KeycodeRight e = GoRight
 | isEventKey KeycodeLeft e = GoLeft
 | isEventKey KeycodeDown e = Eat
 | isEventKey KeycodeSpace e = Fly
 | isEventKey KeycodeR e = Reset
 | otherwise = Continue




--------------------------------------------------------------------------
{- Helper functions -}

slow :: Int -> [a] -> [a]
slow 0 xs = xs
slow n [] = []
slow n (x:xs) = go n x [] ++ (slow n xs) 
  where go 0 _ xs = xs
        go n x xs = go (n-1) x (x:xs)

getObject :: World -> String -> Maybe Object
getObject w n = 
  case find (\o -> n == name o) (objects w) of
   Nothing -> Nothing
   Just o  -> Just o

getMaxBounds :: World -> MaxBounds
getMaxBounds w = 
 case getObject w "Island" of
  Nothing -> (0,0)
  Just (Object (p:ps) w _ _ _) -> (fst p, fst p + w - 100)   
