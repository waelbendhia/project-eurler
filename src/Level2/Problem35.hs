module Level2.Problem35
  ( problem
  ) where

import Data.Numbers.Primes
import Problem

problem :: Problem Integer
problem =
  Problem
  { ind = 35
  , name = "Circular primes"
  , solution = toInteger $length $ circularPrimesUnder 1000000
  }

circularPrimesUnder :: Int -> [Int]
circularPrimesUnder n = filter isCircularPrime $ takeWhile (<= n) primes

isCircularPrime :: Int -> Bool
isCircularPrime = all' isPrime . loop

all' :: Foldable t => (a -> Bool) -> t a -> Bool
all' f l = length l /= 0 && all f l

containsZero :: Int -> Bool
containsZero = any ((==) '0') . show

loop :: Int -> [Int]
loop n =
  if containsZero n
    then []
    else loop' n []
  where
    loop' x [] = loop' x [x]
    loop' x l@(x':_) =
      if shift x' == x
        then l
        else loop' x (shift x' : l)

shift :: Int -> Int
shift n = read $ last sn : init sn
  where
    sn = show n
