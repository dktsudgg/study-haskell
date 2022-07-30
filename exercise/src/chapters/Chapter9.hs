module Chapter9
    (
    ) where

import Control.Concurrent (threadDelay)

sleepSecond :: Int -> IO ()
sleepSecond n = do threadDelay (n * 1000000)

cls :: IO ()
cls = putStr "\ESC[2J"

--

type Pos = (Int, Int)

goto :: Pos -> IO ()
goto (x, y) = putStr ("\ESC[" ++ show y ++ ";" ++ show x ++ "H")

--

writeat :: Pos -> String -> IO ()
writeat p xs = do goto p
                  putStr xs

seqn :: [IO a] -> IO ()
seqn [] = return ()
seqn (a:as) = do a
                 seqn as

-- 

width :: Int
width = 5

height :: Int
height = 5

type Board = [Pos]

glider :: Board
glider = [(4,2), (2,3), (4,3), (3,4), (4,4)]

showcells :: Board -> IO ()
showcells b = seqn [writeat p "0" | p <- b]

clscells :: Board -> IO ()
clscells b = seqn [writeat (px, py) " " | (px, py) <- concat [[(x, y) | y <- [1..height]] | x <- [1..width]]]

isAlive :: Board -> Pos -> Bool
isAlive b p = elem p b
isEmpty :: Board -> Pos -> Bool
isEmpty b p = not (elem p b)

neighbs :: Pos -> [Pos]
neighbs (x, y) = map wrap [(x-1, y-1),  (x, y-1),   (x+1, y-1),
                           (x-1, y),                (x+1, y),   
                           (x-1, y+1),  (x, y+1),   (x+1, y+1)]

wrap :: Pos -> Pos
wrap (x, y) = ((x - 1) `mod` width + 1,
               (y - 1) `mod` height + 1)

liveneighbs :: Board -> Pos -> Int
liveneighbs b = length . filter (isAlive b) . neighbs

survivors :: Board -> [Pos]
survivors b = [p | p <- b, elem (liveneighbs b p) [2, 3]]

births :: Board -> [Pos]
births b = [p | p <- rmdups (concat (map neighbs b)),
                isEmpty b p,
                liveneighbs b p == 3]

rmdups :: Eq a => [a] -> [a]
rmdups [] = []
rmdups (x:xs) = x : rmdups (filter (/= x) xs)

nextgen :: Board -> Board
nextgen b = survivors b ++ births b

life :: Board -> IO ()
life b = do clscells b
            showcells b
            sleepSecond 3
            life (nextgen b)

wait :: Int -> IO ()
wait n = seqn [return () | _ <- [1..n]]

startLifeGame :: IO ()
startLifeGame = do cls
                   life glider
