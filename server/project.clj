(defproject massage-server "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :min-lein-version "2.0.0"
  :dependencies [[org.clojure/clojure "1.6.0"]
                 [compojure "1.3.1"]
                 [org.clojure/data.json "0.1.3"]
                 [ring/ring-json "0.4.0"]
                 [ring-cors "0.1.7"]
                 [clj-time "0.11.0"]
                 [com.draines/postal "1.11.3"]
                 [org.clojure/java.jdbc "0.4.2"]
                 [mysql/mysql-connector-java "5.1.26"]
                 [hiccup "1.0.5"]
                 [ring/ring-devel "1.2.2"] ;; For ring-reload

                 ]
  :plugins [[lein-ring "0.8.13"]]
  :ring {:handler massage-server.handler/app}
  :profiles
  {:dev {:dependencies [[javax.servlet/servlet-api "2.5"]
                        [ring-mock "0.1.5"]
                        ]}})
