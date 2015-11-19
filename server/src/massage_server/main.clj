(ns massage-server.main
    (:require [ring.adapter.jetty :as jetty-adapter]
      [massage-server.handler :as handler])
    (:gen-class))


(defn -main [& args]
      (jetty-adapter/run-jetty handler/app {:port 3000}))
