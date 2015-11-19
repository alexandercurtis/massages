(ns massage-server.emailer
  (:require [hiccup.core :refer [html]]
            [hiccup.page :refer [doctype]]
            [postal.core :as postal]))


(defn massage-row
  [num time name]
  [:tr {:style "height:20px"}
   [:td {:style "padding:0px 3px;border-right-width:1px;border-right-style:solid;border-right-color:rgb(0,0,0);border-left-width:1px;border-left-style:solid;border-left-color:rgb(0,0,0);font-size:100%;vertical-align:bottom;text-align:right"} num]
   [:td {:style "padding:0px 3px;border-right-width:1px;border-right-style:solid;border-right-color:rgb(0,0,0);font-size:100%;vertical-align:bottom"} time]
   [:td {:style "padding:0px 3px;border-right-width:1px;border-right-style:solid;border-right-color:rgb(0,0,0);font-size:100%;vertical-align:bottom"} name]]
  )

(defn email [schedule]
  [:html {:lang "en"}
   [:head
    [:meta {:charset "utf-8"}]
    [:title "Massages"]
    ]
   [:body
    [:div
     [:table {:border "1" :cellpadding "0" :cellspacing "0" :dir "ltr" :style "table-layout:fixed;font-size:13px;font-family:Calibri;border-collapse:collapse;border:1px solid rgb(204,204,204)"}
      [:colgroup
       [:col {:width "71"}]
       [:col {:width "91"}]
       [:col {:width "118"}]]
      [:tbody
       [:tr {:style "height:20px"}
        [:td {:colspan "3" :rowspan "1" :style "padding:0px 3px;border:1px solid rgb(0,0,0);font-size:100%;font-weight:bold;color:rgb(255,0,0);vertical-align:bottom;text-align:center"} "16th November"]]
       [:tr {:style "height:20px"}
        [:td {:style "padding:0px 3px;border-right-width:1px;border-right-style:solid;border-right-color:rgb(0,0,0);border-bottom-width:1px;border-bottom-style:solid;border-bottom-color:rgb(0,0,0);border-left-width:1px;border-left-style:solid;border-left-color:rgb(0,0,0);font-size:100%;font-weight:bold;vertical-align:bottom;text-align:center"} "Slot"]
        [:td {:style "padding:0px 3px;border-right-width:1px;border-right-style:solid;border-right-color:rgb(0,0,0);border-bottom-width:1px;border-bottom-style:solid;border-bottom-color:rgb(0,0,0);font-size:100%;font-weight:bold;vertical-align:bottom;text-align:center"} "Time"]
        [:td {:style "padding:0px 3px;border-right-width:1px;border-right-style:solid;border-right-color:rgb(0,0,0);border-bottom-width:1px;border-bottom-style:solid;border-bottom-color:rgb(0,0,0);font-size:100%;font-weight:bold;vertical-align:bottom;text-align:center"} "Name"]]
       (massage-row "1" "11:20-11:40" (:name (nth schedule 0)))
       (massage-row "2" "11:20-11:40" (:name (nth schedule 1)))
       (massage-row "3" "11:20-11:40" (:name (nth schedule 2)))
       [:tr {:style "height:20px"}
        [:td {:colspan "3" :rowspan "1" :style "padding:0px 3px;border-right-width:1px;border-right-style:solid;border-right-color:rgb(0,0,0);border-left-width:1px;border-left-style:solid;border-left-color:rgb(0,0,0);font-size:100%;vertical-align:bottom;background-color:rgb(153,153,153)"} "BREAK"]]
       (massage-row "4" "11:20-11:40" (:name (nth schedule 3)))
       (massage-row "5" "11:20-11:40" (:name (nth schedule 4)))
       (massage-row "6" "11:20-11:40" (:name (nth schedule 5)))
       [:tr {:style "height:20px"}
        [:td {:colspan "3" :rowspan "1" :style "padding:0px 3px;border-right-width:1px;border-right-style:solid;border-right-color:rgb(0,0,0);border-left-width:1px;border-left-style:solid;border-left-color:rgb(0,0,0);font-size:100%;vertical-align:bottom;background-color:rgb(153,153,153)"} "LUNCH"]]
       (massage-row "7" "11:20-11:40" (:name (nth schedule 6)))
       (massage-row "8" "11:20-11:40" (:name (nth schedule 7)))
       (massage-row "9" "11:20-11:40" (:name (nth schedule 8)))

       [:tr {:style "height:20px"}
        [:td {:colspan "3" :rowspan "1" :style "padding:0px 3px;border-right-width:1px;border-right-style:solid;border-right-color:rgb(0,0,0);border-left-width:1px;border-left-style:solid;border-left-color:rgb(0,0,0);font-size:100%;vertical-align:bottom;background-color:rgb(153,153,153)"} "BREAK"]]

       (massage-row "10" "11:20-11:40" (:name (nth schedule 9)))
       (massage-row "11" "11:20-11:40" (:name (nth schedule 10)))
       (massage-row "12" "11:20-11:40" (:name (nth schedule 11)))
       (massage-row "13" "11:20-11:40" (:name (nth schedule 12)))

       [:tr {:style "height:20px"}
        [:td {:style "padding:0px 3px;vertical-align:bottom;border-right-width:1px;border-right-style:solid;border-right-color:rgb(0,0,0);border-bottom-width:1px;border-bottom-style:solid;border-bottom-color:rgb(0,0,0);border-left-width:1px;border-left-style:solid;border-left-color:rgb(0,0,0)"}]
        [:td {:style "padding:0px 3px;vertical-align:bottom;border-right-width:1px;border-right-style:solid;border-right-color:rgb(0,0,0);border-bottom-width:1px;border-bottom-style:solid;border-bottom-color:rgb(0,0,0)"}]
        [:td {:style "padding:0px 3px;vertical-align:bottom;border-right-width:1px;border-right-style:solid;border-right-color:rgb(0,0,0);border-bottom-width:1px;border-bottom-style:solid;border-bottom-color:rgb(0,0,0)"}]
        ]
       ]]] [:br]

    ]

   ])


(defn send-email
  [schedule]
  (prn "Emailing:" schedule)

  (prn (postal/send-message {:host "localhost"              ; mail server
                             :port 25
                             ;:user "user"
                             ;:pass "pass"
                             }
                            {:from       "massages@example.com"
                             :to         "massages@statenlogic.com"
                             :subject    "Massage Schedule"
                             :message-id #(postal.support/message-id "example.com")
                             :body       [:alternative
                                          {:type    "text/plain; charset=utf-8"
                                           :content "This is a test."}
                                          {:type    "text/html; charset=utf-8"
                                           :content (html (doctype :html5) (email schedule))}
                                          ]})))

