(ns massage-server.config)


(def env
  (keyword (get (System/getenv)
                "APP_ENV"
                "dev")))

(def production? (= :production env))

(def development? (not production?))


