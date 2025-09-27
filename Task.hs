{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Task
  ( Task(..)
  , initDB
  , getAllTasks
  , getTaskById
  , insertTask
  , updateTask
  , deleteTask
  , getAllCategories
  , getTasksByCategory
  , getTasksByDueDate
  ) where

import Data.Aeson (FromJSON(..), ToJSON(..), (.:), (.:?), (.=), object, withObject, (.!=))
import qualified Data.Aeson as Aeson
import GHC.Generics (Generic)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromRow
import Database.SQLite.Simple.ToRow

data Task = Task
  { taskId :: Int
  , title :: String
  , description :: String
  , done :: Bool
  , taskStatus :: String
  , category :: String
  , dueDate :: String
  } deriving (Show, Eq, Generic)

instance ToJSON Task where
  toJSON (Task tid t d o s c due) = object
    [ "taskId" .= tid
    , "title" .= t
    , "description" .= d
    , "done" .= o
    , "status" .= s
    , "category" .= c
    , "dueDate" .= due
    ]

instance FromJSON Task where
  parseJSON = withObject "Task" $ \v -> Task
    <$> v .:? "taskId" .!= 0
    <*> v .: "title"
    <*> v .: "description"
    <*> v .: "done"
    <*> v .: "status"
    <*> v .: "category"
    <*> v .: "dueDate"

instance FromRow Task where
  fromRow = Task <$> field <*> field <*> field <*> field <*> field <*> field <*> field

instance ToRow Task where
  toRow (Task tid t d o s c due) = toRow (tid, t, d, o, s, c, due)

initDB :: Connection -> IO ()
initDB conn = execute_ conn
  "CREATE TABLE IF NOT EXISTS tasks (id INTEGER PRIMARY KEY, title varchar(255), description TEXT, done BOOLEAN, status varchar(25), category varchar(50), dueDate varchar(20))"

getAllTasks :: Connection -> IO [Task]
getAllTasks conn = query_ conn "SELECT id, title, description, done, status, category, dueDate FROM tasks"

getTaskById :: Connection -> Int -> IO (Maybe Task)
getTaskById conn tid = do
  res <- query conn "SELECT id, title, description, done, status, category, dueDate FROM tasks WHERE id = ?" (Only tid)
  return $ case res of
    [task] -> Just task
    _      -> Nothing

insertTask :: Connection -> Task -> IO Int
insertTask conn (Task _ t d o s c due) = do
  execute conn "INSERT INTO tasks (title, description, done, status, category, dueDate) VALUES (?,?,?,?,?,?)" (t, d, o, s, c, due)
  rid <- lastInsertRowId conn
  return (fromIntegral rid)

updateTask :: Connection -> Int -> Task -> IO ()
updateTask conn tid (Task _ t d o s c due) =
  execute conn "UPDATE tasks SET title = ?, description = ?, done = ?, status = ?, category = ?, dueDate = ? WHERE id = ?" (t, d, o, s, c, due, tid)

deleteTask :: Connection -> Int -> IO ()
deleteTask conn tid =
  execute conn "DELETE FROM tasks WHERE id = ?" (Only tid)

getAllCategories :: Connection -> IO [String]
getAllCategories conn = do
  res <- query_ conn "SELECT DISTINCT category FROM tasks"
  return $ map fromOnly res

getTasksByCategory :: Connection -> String -> IO [Task]
getTasksByCategory conn cat =
  query conn "SELECT id, title, description, done, status, category, dueDate FROM tasks WHERE category = ?" (Only cat)

getTasksByDueDate :: Connection -> String -> IO [Task]
getTasksByDueDate conn date =
  query conn "SELECT id, title, description, done, status, category, dueDate FROM tasks WHERE dueDate = ?" (Only date)
