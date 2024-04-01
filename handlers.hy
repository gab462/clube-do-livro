(import util *
        hyrule [flatten
        random [choice :as random-choice]
        json [dumps :as dump-json
              loads :as load-json])

(require hyrule [->> ->] :readers [%])

(defn/a ready [bot]
  (await (.sync-all-application-commands bot))
  (print f"Logged in as {bot.user}"))

(defn ping []
  "Pong!")

(defn define-books [books]
  (->> books
       (split-on " ")
       pairs
       map-from-pairs
       ._asdict
       dump-json
       (write-to-file "books.json"))
  (read-from-file "books.json"))

(defn chosen [name]
  (append-to-file "chosen.txt" name)
  f"{name} definido como escolhido")

; TODO: handle full chosen.txt
(defn draw []
  (let [collection (->> (read-from-file "books.json") load-json .items)
        chosen (->> (read-from-file "chosen.txt") (split-on "\n"))
        chooseable (filter #%(not-in (first %1) chosen) collection)
        books (->> chooseable (map second) flatten)
        choice (random-choice books)
        newly-chosen (->> collection
                          (filter #%(in choice (second %1)))
                          tuple first first)
        new-collection (-> collection
                           dict
                           map-from-dict
                           (update newly-chosen
                                   (fn [xs]
                                     (->> xs (filter #%(!= choice %1)) tuple))))]
    (append-to-file "chosen.txt" newly-chosen)
    (write-to-file "books.json" (-> new-collection ._asdict dump-json))
    f"Livro escolhido: {choice}"))
