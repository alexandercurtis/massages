(ns massage-server.handler
    (:require [compojure.core :refer :all]
      [compojure.route :as route]
      [ring.middleware.json :refer [wrap-json-body]]
      [ring.middleware.cors :as cors]
      [ring.middleware.params :refer [wrap-params]]
      [ring.util.response :as response]
      ; [ring.middleware.reload :refer [wrap-reload]]
      [clj-time.core :as t]
      [clj-time.coerce :as tc]
      [clj-time.format :as tf]

      [clojure.data.json :as json]

      [ns-tracker.core :as ns-tracker]
      [massage-server.db :as db]
      [massage-server.emailer :as emailer]
      [massage-server.planner :as planner]
      ))





(defn- emit-json
       [x & [status]]
       (let [json-data (json/json-str x)]
            {:headers {"Content-Type"   "application/json"
                       "Vary"           "Accept-Encoding"
                       "Content-Length" (str (.length json-data))}
             :status  (or status 200)
             :body    json-data}))


(defn present
      [{:keys [name date]}]

      {:name name :last-date (if (nil? date) "never" (tf/unparse (tf/formatters :year-month-day) (tc/to-date-time date)))}
      )

(defn pad [n] (if (< (count n) 2) (str "0" n) n))

(defn convert-date
      [d]
      (if-let [[a d m y] (re-matches #"(\d{1,2})/(\d{1,2})/(\d{4})" d)]
              (format "%s-%s-%s" y (pad m) (pad d))
              d)
      )

(defroutes app-routes
           (GET "/" [] (response/redirect "/index.html"))
           (GET "/api/v1/people" [] (emit-json (map present (db/get-people))))
           (GET "/api/v1/fill" [] (emit-json (map present (planner/plan))))
           (POST "/api/v1/people" [] (fn [{{n :name} :body}]
                                         (prn "Got name" n)
                                         (db/create-person n)
                                         (emit-json {:name n :last-date "never"})))
           (POST "/api/v1/schedules" [] (fn [{{d :date, slots :slots} :body}]
                                            (let [cd (convert-date d)]
                                                 (db/add-schedule (t/now) cd slots)
                                                 (emailer/send-email (db/get-schedule cd))
                                                 (emit-json {:success true}
                                                            #_(db/get-schedule d)))))
           (PUT "/api/v1/people" [] (fn [{{n :name d :deleted} :body}]
                                        (prn "Put name" n)
                                        (when d
                                              (db/delete-person n))
                                        (emit-json {:name n :last-date "deleted"})))
           (route/resources "/")
           (route/not-found "Not Found"))

(defn wrap-logging
      [handler]
      (fn [request]
          (prn (str (:remote-addr request) " " (.toUpperCase (name (:request-method request))) " " (:uri request)))
          ;   (prn request)
          (handler request)))

(defn wrap-reload
      "Reload namespaces of modified files before the request is passed to the
      supplied handler.

      Takes the following options:
        :dirs - A list of directories that contain the source files.
                Defaults to [\"src\"]."
      [handler & [options]]
      (let [source-dirs (:dirs options ["src"])
            modified-namespaces (ns-tracker/ns-tracker source-dirs)]
           (fn [request]
               (doseq [ns-sym (modified-namespaces)]
                      (prn "Reloading" ns-sym)
                      (require ns-sym :reload))
               (handler request))))

(def app
  (-> app-routes

      (cors/wrap-cors :access-control-allow-origin [#".*"]
                      :access-control-allow-methods [:get :put :post :delete])
      wrap-params

      wrap-logging
      (wrap-json-body {:keywords? true :bigdecimals? true})
      wrap-reload
      ))
