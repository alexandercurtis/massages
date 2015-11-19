(ns massage-server.planner
  (:require
    [massage-server.db :as db]
    ))

(defn plan
  []
  (db/get-n-oldest 13))

(defn resolve-schedules
  [schedules]
  )
