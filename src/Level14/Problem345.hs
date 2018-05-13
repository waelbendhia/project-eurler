{-# LANGUAGE FlexibleContexts #-}

module Level14.Problem345
  ( problem
  ) where

import Control.Monad
import Control.Monad.LPMonad
import Data.Array
import Data.Bits
import Data.LinearProgram.Common
import Data.LinearProgram.GLPK
import Data.List
import Data.Map
import Data.Maybe
import System.IO.Silently
import System.IO.Unsafe

import Problem

-- Algorithm is basically compose a linear program describing the matrix and
-- solve it using GLPK. Easy-peasy.
-- On a whole I like this program because I get to use something I learned from
-- school and I do monad things which I don't quite understand. Also it prints
-- things to 
problem :: Problem Integer
problem =
  Problem {ind = 345, name = "Matrix Sum", solution = solveMatrix problemMatrix}

indexMatrix :: [[a]] -> [[(a, [Char])]]
indexMatrix m = uncurry indexLine <$> addI m
  where
    addI = zip [1 ..]
    indexLine i = fmap (uncurry $ indexVal i) . addI
    indexVal i j v = (v, "x" ++ show i ++ show j)

matrixToObjectiveFunction :: Additive r => [[r]] -> LinFunc [Char] r
matrixToObjectiveFunction = linCombination . concat . indexMatrix

linearConstraintsFromMatrix m =
  flip forM_ (flip leqTo 1) $ linCombination <$> indexedM ++ transpose indexedM
  where
    indexedM = fmap (\(_, s) -> (1, s)) <$> indexMatrix m

varConstrainsFromMatrix m = forM_ (indexMatrix m >>= fmap snd) (flip varGeq 0)

varKindsFromMatrix m =
  forM_ (indexMatrix m >>= fmap snd) (flip setVarKind IntVar)

linProbFromMatrix :: (Ord c, Group c, Num c) => [[c]] -> LP [Char] c
linProbFromMatrix m =
  execLPM $ do
    setDirection Max
    setObjective $ matrixToObjectiveFunction m
    linearConstraintsFromMatrix m
    varConstrainsFromMatrix m
    varKindsFromMatrix m

solveMatrix :: (Prelude.Integral p, Group c, Real c) => [[c]] -> p
solveMatrix m = fromMaybe 0 max
  where
    max = truncate <$> (\(a, _, _c) -> a) <$> solution
    solution =
      snd $
      unsafePerformIO $ silence $ glpSolveAll mipDefaults $ linProbFromMatrix m

problemMatrix :: [[Integer]]
problemMatrix =
  [ [7, 53, 183, 439, 863, 497, 383, 563, 79, 973, 287, 63, 343, 169, 583]
  , [627, 343, 773, 959, 943, 767, 473, 103, 699, 303, 957, 703, 583, 639, 913]
  , [447, 283, 463, 29, 23, 487, 463, 993, 119, 883, 327, 493, 423, 159, 743]
  , [217, 623, 3, 399, 853, 407, 103, 983, 89, 463, 290, 516, 212, 462, 350]
  , [960, 376, 682, 962, 300, 780, 486, 502, 912, 800, 250, 346, 172, 812, 350]
  , [870, 456, 192, 162, 593, 473, 915, 45, 989, 873, 823, 965, 425, 329, 803]
  , [973, 965, 905, 919, 133, 673, 665, 235, 509, 613, 673, 815, 165, 992, 326]
  , [322, 148, 972, 962, 286, 255, 941, 541, 265, 323, 925, 281, 601, 95, 973]
  , [445, 721, 11, 525, 473, 65, 511, 164, 138, 672, 18, 428, 154, 448, 848]
  , [414, 456, 310, 312, 798, 104, 566, 520, 302, 248, 694, 976, 430, 392, 198]
  , [184, 829, 373, 181, 631, 101, 969, 613, 840, 740, 778, 458, 284, 760, 390]
  , [821, 461, 843, 513, 17, 901, 711, 993, 293, 157, 274, 94, 192, 156, 574]
  , [34, 124, 4, 878, 450, 476, 712, 914, 838, 669, 875, 299, 823, 329, 699]
  , [815, 559, 813, 459, 522, 788, 168, 586, 966, 232, 308, 833, 251, 631, 107]
  , [813, 883, 451, 509, 615, 77, 281, 613, 459, 205, 380, 274, 302, 35, 805]
  ]
