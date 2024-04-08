(require std * :readers *) (import std *)

(import os.path [isfile]
        json [dumps :as dump-json
              loads :as load-json]
        random [choice :as random-choice]
        util [first second split-on pairs pairs->map
              write-to-file append-to-file read-from-file])

(defn/a ready [bot]
  (print "Refreshing application commands...")
  (await (.sync-all-application-commands bot))
  (when (not (isfile "chosen.txt")) (write-to-file "chosen.txt" ""))
  (print f"Logged in as {bot.user}"))

(defn ping []
  "Pong!")

(defn define-books [books]
  (->> books (split-on " ") pairs pairs->map thaw dump-json (write-to-file "books.json"))
  (read-from-file "books.json"))

(defn define-chosen [name]
  (append-to-file "chosen.txt" name)
  f"{name} definido como escolhido")

(defn get-books []
  (read-from-file "books.json"))

(defn get-chosen []
  (read-from-file "chosen.txt"))

(defn draw []
  (let [collection (->> (read-from-file "books.json") load-json .items)
        chosen (->> (read-from-file "chosen.txt") (split-on "\n"))
        chooseable (filter #%(not-in (first %1) chosen) collection)
        choice (random-choice (->> chooseable (map second) flatten))
        newly-chosen (->> collection (filter #%(in choice (second %1))) next first)
        new-collection (-> collection
                           pmap
                           (update #** {newly-chosen
                                        (fn [xs]
                                          (->> xs (filter #%(!= choice %1)) pvector))}))]
    (if (>= (+ (len (list (filter bool chosen))) 1)
            (len (list (map first collection))))
      (write-to-file "chosen.txt" "")
      (append-to-file "chosen.txt" newly-chosen))
    (write-to-file "books.json" (dump-json (thaw new-collection)))
    f"Livro escolhido: {choice}"))
