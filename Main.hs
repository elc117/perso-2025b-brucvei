{-# LANGUAGE OverloadedStrings #-}

import Web.Scotty
import Data.Aeson (FromJSON, ToJSON)
import qualified Data.Aeson as Aeson
import Data.Text.Lazy (Text, pack, unpack)
import Control.Monad.IO.Class (liftIO)
import Database.SQLite.Simple
import Network.HTTP.Types.Status (status404)
import Task

main :: IO ()
main = do
  conn <- open "tasks.db"
  initDB conn
  scotty 3000 $ do

    get "/tasks" $ do
      tasks <- liftIO $ getAllTasks conn
      json tasks

    get "/tasks/:id" $ do
      tid <- param "id"
      mt <- liftIO $ getTaskById conn tid
      case mt of
        Just task -> json task
        Nothing -> status status404 >> text "Tarefa não encontrada"

    get "/categories" $ do
      cats <- liftIO $ getAllCategories conn
      json cats

    get "/tasks/category/:category" $ do
      cat <- param "category"
      tasks <- liftIO $ getTasksByCategory conn (unpack cat)
      json tasks

    get "/tasks/due/:date" $ do
      date <- param "date"
      tasks <- liftIO $ getTasksByDueDate conn (unpack date)
      json tasks

    post "/tasks" $ do
      task <- jsonData
      newId <- liftIO $ insertTask conn task
      let taskWithId = task { taskId = newId }
      json taskWithId

    put "/tasks/:id" $ do
      tid <- param "id"
      updatedTask <- jsonData
      liftIO $ updateTask conn tid updatedTask
      text "Tarefa atualizada"

    delete "/tasks/:id" $ do
      tid <- param "id"
      liftIO $ deleteTask conn tid
      text "Tarefa removida"
