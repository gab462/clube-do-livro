(require hyrule * :readers *)

(import hyrule *
        itertools *
        functools *
        operator *
        math *
        pyrsistent [pvector pset pmap thaw]
        random [choice :as random-choice]
        json [dumps :as dump-json
              loads :as load-json])

(eval-and-compile (del (get _hy_macros "assoc")))

(setv nil None
      first (itemgetter 0)
      second (itemgetter 1))

(defreader v
  (assert (= (.getc &reader) "["))
  (let [args (->> (.parse-forms-until &reader "]")
                  (map (fn [a]
                         (if (is (type a) hy.models.Keyword)
                           `(hy.models.Keyword ~(getattr a "name"))
                           a))))]
    `(hy.I.pyrsistent.v ~@args)))

(defreader m
  (assert (= (.getc &reader) "{"))
  (let [args (.parse-forms-until &reader "}")]
    `(hy.I.pyrsistent.m ~@args)))

(defn assoc [m #** kwargs]
  (.update m kwargs))

(defn update [m #** kwargs]
  (let [args (->> kwargs
                  .items
                  (map (fn+ [[k f]]
                         #(k (f (get m k)))))
                  dict)]
    (.update m args)))

(defmacro get-in [m keys]
  `(-> ~m ~@keys))

(defn split-on [sep s]
  (.split s sep))

(defn write-to-file [path data]
  (with [f (open path "w+")]
    (.write f data)))

(defn append-to-file [path data]
  (with [f (open path "a+")]
    (.write f (+ data "\n"))))

(defn read-from-file [path]
  (with [f (open path "r")]
    (.read f)))

(defn pairs [xs]
  (pvector (zip (ncut xs ::2) (ncut xs 1::2))))

(defn pairs->map [xs]
  (let [keys (pset (map first xs))
        initial (pmap (map #%[%1 #v[]] keys))]
    (reduce (fn+ [acc [owner book]]
              (update acc #** {owner #%(.append %1 book)}))
            xs initial)))
