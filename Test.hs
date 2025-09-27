{-# LANGUAGE OverloadedStrings #-}

import Test.Hspec
import Task (Task(..), initDB, insertTask, getAllTasks, getTaskById, updateTask, deleteTask)
import Database.SQLite.Simple
import Control.Exception (bracket)
import Data.Aeson (encode, decode)

withTestDB :: (Connection -> IO a) -> IO a
withTestDB action = bracket (open ":memory:") close $ \conn -> do
  initDB conn
  action conn

main :: IO ()
main = hspec $ do
  describe "Task JSON encoding/decoding" $ do
    it "encode and decode Task" $ do
      let task = Task 1 "Estudar Haskell" "desc" True "feito"
      (decode . encode) task `shouldBe` Just task

  describe "Task equality" $ do
    it "tasks with same fields are equal" $ do
      Task 1 "A" "desc" False "novo" `shouldBe` Task 1 "A" "desc" False "novo"
    it "tasks with different ids are not equal" $ do
      Task 1 "A" "desc" False "novo" `shouldNotBe` Task 2 "A" "desc" False "novo"

  describe "Funções auxiliares com SQLite" $ do
    it "insertTask e getTaskById" $ withTestDB $ \conn -> do
      let task = Task 0 "Teste" "desc" True "novo"
      newId <- insertTask conn task
      mtask <- getTaskById conn newId
      fmap (\t -> (title t, done t)) mtask `shouldBe` Just ("Teste", True)

    it "getAllTasks retorna todas as tarefas" $ withTestDB $ \conn -> do
      _ <- insertTask conn (Task 0 "A" "desc" False "novo")
      _ <- insertTask conn (Task 0 "B" "desc" True "feito")
      tasks <- getAllTasks conn
      length tasks `shouldBe` 2

    it "updateTask altera uma tarefa existente" $ withTestDB $ \conn -> do
      newId <- insertTask conn (Task 0 "Antigo" "desc" False "novo")
      updateTask conn newId (Task newId "Novo" "desc" True "feito")
      mtask <- getTaskById conn newId
      fmap (\t -> (title t, done t)) mtask `shouldBe` Just ("Novo", True)

    it "deleteTask remove uma tarefa" $ withTestDB $ \conn -> do
      newId <- insertTask conn (Task 0 "Apagar" "desc" False "novo")
      deleteTask conn newId
      mtask <- getTaskById conn newId
      mtask `shouldBe` Nothing
