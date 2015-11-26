(ns massage-server.db
  (:require [clojure.java.jdbc :as jdbc]))

(def db {:subprotocol "mysql"
               :subname "//127.0.0.1:3306/massages"
               :user "massages"
               :password "massages"})

(defn get-names
  []
  (->>
    (jdbc/query db "SELECT name FROM people ORDER BY name ASC")
    (map :name)))

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

(defn get-n-latest-dates
  [n]
  (->>
    (jdbc/query db ["SELECT DISTINCT massage_id FROM clients ORDER BY massage_id DESC LIMIT ?", n])
    (map :massage_id)))

(defn get-dates
  [name dates]
  (let [dates-clause (clojure.string/join "','" dates)]
    (->> (jdbc/query db [(format "SELECT massage_id FROM clients WHERE people_id = ? AND massage_id IN ('%s')" dates-clause) name])
         (map :massage_id))))