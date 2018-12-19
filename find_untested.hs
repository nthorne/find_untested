#!/usr/bin/env stack
-- stack --resolver lts-12.22 script

{-# LANGUAGE OverloadedStrings #-}

import Turtle as Tu
import qualified Control.Foldl as Fold
import Control.Conditional
import qualified Data.Text as DT

-- Gives a stream of file names that matches a few hard coded patterns
srcs :: Shell Text
srcs = do
  p <- pwd
  s <- lstree p
  _:_ <- return (match (suffix ".c") (format fp s))
  _:_ <- return (match (invert (has "audio_utility")) (format fp s))
  _:_ <- return (match (invert (has "target_tools")) (format fp s))
  _:_ <- return (match (invert (has "vip_exeriment")) (format fp s))
  _:_ <- return (match (invert (has "testutils")) (format fp s))
  _:_ <- return (match (invert (has "manufacturing")) (format fp s))
  _:_ <- return (match (invert (has "_stub")) (format fp s))
  return $ format fp $ Tu.filename s

allMentioned :: Shell Line
allMentioned = do
  p <- pwd
  m <- Tu.find (suffix "CMakeLists.txt") p
  s <- srcs
  grep (suffix (text s)) (input m)

-- Gives a stream of all the files not mentioned in a makefile
notMentioned = do
  s <- srcs
  -- monadic bool that tells whether s is within any makefile or not..
  let mentioned = fold allMentioned $ Fold.any (\x -> DT.isSuffixOf s (lineToText x))
  -- if this Line was mentioned, then we fail this block
  ifM (mentioned) (empty) (return s)


main = view $ do
  echo "Untested files:"
  notMentioned
