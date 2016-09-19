{-# LANGUAGE OverloadedStrings #-}
module WebParsing.ParsecCombinators
    (getCourseFromTag,
     findCourseFromTag,
     getPostType,
     extractPostType,
     findPostType,
     getDepartmentName,
     isDepartmentName,
     parsingAlgoOne) where

import qualified Text.Parsec as P
import Text.Parsec ((<|>))
import qualified Data.Text as T
import Data.Functor.Identity
import Text.Parsec.String
import Data.List

getCourseFromTag courseTag = do
    let course = P.parse findCourseFromTag "(source)" courseTag
    case course of
        Right name -> name
        Left _ -> ""

findCourseFromTag :: Parser String
findCourseFromTag = do
    parseUntil (P.char '#')
    P.many1 P.anyChar

-- Post Parsing

getPostType :: T.Text -> String
getPostType postCode = 
    let codeSection = extractPostType (T.unpack postCode)
    in
        case codeSection of
            "SPE" -> "Specialist"
            "MAJ" -> "Major"
            "MIN" ->  "Minor"

extractPostType :: [Char] -> [Char]
extractPostType postCode = do
    let parsed = P.parse findPostType "(source)" postCode
    case parsed of 
        Right name -> name
        Left _ -> ""

findPostType :: Parser String
findPostType = do
   P.string "AS"
   P.many1 P.letter

getDepartmentName :: [Char] -> T.Text -> [Char]
getDepartmentName fullPostName postType = do
    let parsed = P.parse (isDepartmentName (T.unpack postType)) "(source)" fullPostName
    case parsed of 
        Right name -> name
        Left _ -> ""

isDepartmentName ::  [Char] -> Parser String
isDepartmentName postType = parseUntil (P.string postType)

-- Post Category Parsing

parsingAlgoOne :: Parser [String]
parsingAlgoOne = do
    getRequirements 
    splitPrereqText

getRequirements :: Parser String
getRequirements = 
    parseUntil (P.string "Program Course Requirements:")

parseNoteLine :: Parser String
parseNoteLine = do
    P.string "Note"
    parseUntil (P.char '\n')

parseNotes :: Parser String
parseNotes = (P.try (P.string "Notes")) <|> (P.try (P.string "NOTES"))

parseUntil :: Parser a -> Parser String
parseUntil parser = P.manyTill P.anyChar (P.try parser)

splitPrereqText :: Parser [String]
splitPrereqText = do
    parseUntil (P.string "First Year")
    P.manyTill ((P.try parseNoteLine) <|> (parseCategory False)) parseNotes

parseCategory :: Bool -> Parser String
parseCategory withinBracket = do
    left <- parseUpToSeperator
    nextChar <- P.anyChar
    if nextChar == ',' && (not withinBracket)
    then return $ left 
    else do
        mergeText left nextChar withinBracket

mergeText :: String -> Char -> Bool -> Parser String
mergeText left nextChar withinBracket = do
    case nextChar of
        '(' -> do
            right <- P.option " " (parseCategory True)
            return $ "(" ++ left ++ right
        ')' -> do
            right <- P.option " " (parseCategory False) 
            return $ left ++ ")" ++ right
        '/' -> do
            right <- P.option " " (parseCategory withinBracket)
            return $ left ++ " or " ++ right
        ',' -> do
            right <- P.option " " (parseCategory withinBracket)
            case withinBracket of
                True -> return $ left ++ " and " ++ right
                False -> return $ left
        other -> return $ left

parseUpToSeperator :: Parser String
parseUpToSeperator = do
    parseUntil (P.notFollowedBy (P.noneOf ",/();\r\n"))

-- For testing purposed in REPL
parseAll :: Parser [String]
parseAll = P.many (parseCategory False)




