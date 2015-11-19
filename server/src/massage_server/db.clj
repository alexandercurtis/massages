(ns massage-server.db
  (:require [clojure.java.jdbc :as jdbc]))

(def db {:subprotocol "mysql"
               :subname "//127.0.0.1:3306/massages"
               :user "massages"
               :password "massages"})

(defn get-people
  []
  (jdbc/query db "SELECT p.name AS name, max(c.massage_id) AS date FROM people p LEFT JOIN clients c ON p.name = c.people_id WHERE p.active = 1 GROUP BY p.name"))

(defn create-person
  [name]
  (jdbc/execute! db ["INSERT INTO people(name) VALUES(?)" name]))


(defn add-schedule
  [creation-date schedule-date slots]
  (jdbc/with-db-transaction
    [tx db]
    (jdbc/execute! tx ["DELETE FROM clients WHERE massage_id=?" schedule-date])
    (doseq [{:keys [type name time num]} slots]
      (jdbc/execute! tx ["INSERT INTO clients(massage_id,people_id,slot) VALUES (?,?,?)" schedule-date name num]))))

(defn get-schedule
  [schedule-date]
  (jdbc/query db ["SELECT c.people_id AS name, c.slot AS num FROM clients c WHERE c.massage_id = ? ORDER BY c.slot ASC" schedule-date]))

(defn delete-person
  [name]
  (jdbc/execute! db ["UPDATE people SET active=0 WHERE name=?" name])
  )

(defn get-n-oldest
  [n]
  (jdbc/query db ["SELECT p.name AS name, max(c.massage_id) AS date FROM people p LEFT JOIN clients c ON p.name = c.people_id WHERE p.active = 1 GROUP BY p.name ORDER BY date LIMIT ?" n]))

