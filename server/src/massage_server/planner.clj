(ns massage-server.planner
  (:require
    [massage-server.db :as db]
    ))

(defn plan
  []
  (db/get-n-oldest 13))

(defn history
  []
  (let [recent-dates (db/get-n-latest-dates 6)
        people (db/get-names)]
    {:dates recent-dates
     :history (for [person people]
       {:name     person
        :bookings (db/get-dates person recent-dates)})}))

(defn resolve-schedules
  [schedules]
  )
