#!/usr/bin/env stack
-- stack --resolver lts-12.22 script

{-# LANGUAGE OverloadedStrings #-}

import Turtle as Tu
import qualified Control.Foldl as Fold
import Control.Conditional
import qualified Data.Text as DT


srcs :: Shell Text
srcs = do
  p <- pwd
  s <- Tu.find (suffix ".c") p
  return $ format fp $ Tu.filename s

allMentioned :: Shell Line
allMentioned = do
  p <- pwd
  m <- Tu.find (suffix "CMakeLists.txt") p
  s <- srcs
  grep (text s) (input m)

-- Gives a stream of all the files not mentioned in a makefile
notMentioned = do
  s <- srcs
  -- monadic bool that tells whether s is within any makefile or not..
  let mentioned = fold allMentioned $ Fold.any (\x -> (lineToText x) == s) 
  -- if this Line was mentioned, then we fail this block
  ifM (mentioned) (empty) (return s)


main = view $ do
  echo "Untested files:"
  notMentioned
