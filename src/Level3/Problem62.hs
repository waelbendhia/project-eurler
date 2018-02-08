module Level3.Problem62
  ( problem
  ) where

import Data.List

import Problem

problem :: Problem Integer
problem =
  Problem
  { ind = 62
  , name = "Cubic permutations"
  , solution =
      case findCubicPermutationsOfLength 5 of
        Just l -> head l
        Nothing -> 0
  }

findCubicPermutationsOfLength :: Int -> Maybe [Integer]
findCubicPermutationsOfLength l = helper [] (cubes)
  where
    helper list cubs
      | length list == l = Just list
      | isEmpty cubs = Nothing
      | isEmpty list =
        firstJust $ map (\c -> helper [c] $ findCubeWithSameDigits c c) cubs
      | otherwise =
        firstJust $
        map
          (\c -> helper (c : list) $ findCubeWithSameDigits (head list) c)
          cubs

isEmpty :: [a] -> Bool
isEmpty [] = True
isEmpty (_:_) = False

findCubeWithSameDigits :: Integer -> Integer -> [Integer]
findCubeWithSameDigits a lowerBound =
  filter (sameDigits a) $
  takeWhile ((== numDigits a) . numDigits) $ dropWhile (<= lowerBound) $ cubes

sameDigits :: Show a => a -> a -> Bool
sameDigits a b = getDigits a == getDigits b
  where
    getDigits = sort . show

numDigits :: Show a => a -> Int
numDigits = length . show

cubes :: [Integer]
cubes = map (^ 3) [1 ..]

firstJust :: [Maybe a] -> Maybe a
firstJust [] = Nothing
firstJust (x:xs) =
  case x of
    Nothing -> firstJust xs
    y -> y
