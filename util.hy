(import operator [methodcaller itemgetter]
        functools [reduce]
        collections [namedtuple])
(require hyrule [fn+ -> ->>] :readers [%])

(setv first (itemgetter 0)
      second (itemgetter 1))

(defn split-on [sep s]
  (let [f (methodcaller "split" sep)]
    (f s)))

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
  (list (zip (cut xs None None 2) (cut xs 1 None 2))))

(defn assoc [nt #** kwargs]
  (._replace nt #** kwargs))

(defn update [nt k f]
  (assoc nt #** {k (->> k (getattr nt) f)}))

(defn map-from-pairs [xs]
  (let [keys (set (map first xs))
        make-map (namedtuple "books" keys)
        initial (make-map #* (* #(#()) (len keys)))]
    (reduce (fn+ [acc [owner book]]
              (update acc owner #%(+ %1 #(book))))
            xs initial)))

(defn map-from-dict [d]
  (let [make-map (namedtuple "books" (.keys d))]
    (make-map #** d)))
