module Types where
import Foreign.C.Types
import SDL

data World = World { sys :: Sys
                   , render :: Renderer
                   , background :: Texture
                   , objects :: [Object]
                   , sheep :: Sheep
                   }

data Sys = Sys { width :: CInt
               , height :: CInt
               , fps :: CInt
               }

data Object = Object { objPos :: [(CInt,CInt)]
                     , objWidth :: CInt
                     , objHeight :: CInt
                     , objTexture :: Texture 
                     , name :: String
                     }

data Sheep = Sheep { sheepPos :: [(CInt,CInt)]
                   , sheepDirect :: Direction
                   , sheepWidth :: CInt
                   , sheepHeight :: CInt
                   , sheepTextures :: SheepTextures
                   }

data SheepTextures = SheepTextures { stLeft :: Texture
                                   , stRight :: Texture
                                   , stDownLeft :: Texture
                                   , stDownRight :: Texture
                                   }

data Direction = Lefty | Righty | LDown | RDown deriving Eq 

data Command = GoLeft | GoRight | Fly | Continue | Eat | Reset

type MaxBounds = (CInt, CInt)