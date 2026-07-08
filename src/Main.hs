module Main where

import Data.List (intercalate)
import Options.Applicative
import System.Random (randomRIO)

-- Comment ---------------------------------------------------------------------

commentDescription :: String -> String
commentDescription desc = "c description: " ++ desc

commentGenerator :: String
commentGenerator = "c generator: cnf-gen (0.1.0)"

commentCopyright :: String
commentCopyright = "c copyright: (C) 2026 Robert Coffey"

-- TODO
--commentCommand :: String -> String
--commentCommand cmd =

commentHeader :: String -> String
commentHeader desc =
  let comments =
        [ commentDescription desc
        , commentGenerator
        , commentCopyright
        ]
  in unlines $ comments

-- CNF -------------------------------------------------------------------------

type Literal = Int
type Clause = [Literal]
data CNF = CNF
  { cnf_n :: Int  -- number of variables
  , cnf_m :: Int  -- number of clauses
  , cnf_clauses :: [Clause]
  } deriving (Show)

-- Convert CNF ADT into a string in DIMACS CNF format.
cnfToDimacs :: CNF -> String
cnfToDimacs (CNF n m clauses) =
  let header_line = concat $ ["p cnf ", show n, " ", show m]
      clause_lines = map (\c -> intercalate " " $ (map show c ++ ["0"])) clauses
  in unlines $ header_line : clause_lines

-- Random k-CNF ----------------------------------------------------------------

-- Generate a random literal s.t. 1 <= abs literal <= n, with a random sign.
genRandLit :: Int -> IO Literal
genRandLit n = do
  var <- randomRIO (1, n) :: IO Int
  prob <- randomRIO (0.0, 1.0) :: IO Double
  let sign = if prob < 0.5 then (-1) else (1)
  pure $ var * sign

-- Generate random clause of width k. Selects from n variables with no repeats.
-- k must be <= n, otherwise not enough variables.
genRandKClause :: Int -> Int -> IO Clause
genRandKClause k n = mapM (\_ -> genRandLit n) [1..k]

genRandKCnf :: Int -> Int -> Int -> IO (CNF, String)
genRandKCnf k n m = do
  clauses <- mapM (\_ -> genRandKClause k n) [1..m]
  let desc = concat ["Random ", show k, "-CNF over ", show n, " variables and ",
                     show m, " clauses."]
  pure $ (CNF n m clauses, desc)

-- Main ------------------------------------------------------------------------

data Config = Config
  { conf_formula :: String
  , conf_rest :: [String]
  } deriving (Show)

configParser :: Parser Config
configParser = Config
  <$> strArgument
  ( metavar "<formula>"
    <> help "name of formula family" )
  <*> many
    ( strArgument
      ( metavar "<args>"
        <> help "rest of arguments" ) )

cmdRandKCnf :: [String] -> IO (CNF, String)
cmdRandKCnf rest = do
  let knm = map read rest :: [Int]
  case knm of
    [k,n,m] -> genRandKCnf k n m
    _       -> error "error: invalid arguments"

main :: IO ()
main = do
  conf <- execParser opts

  (cnf, desc) <-
    case (conf_formula conf) of
      "randkcnf" -> cmdRandKCnf (conf_rest conf)
      formula    -> error $ "error: unknown formula family: " ++ formula

  putStr $ commentHeader desc ++ cnfToDimacs cnf

  where opts = info (configParser <**> helper)
               ( fullDesc
                 <> header "cnf-gen - CNF formula generator" )
