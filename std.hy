(require hyrule * :readers *)

(import hyrule *
        itertools *
        functools *
        operator *
        pyrsistent [pvector pset pmap freeze thaw])

(eval-and-compile (del (get _hy_macros "assoc")))

(setv nil None)

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
