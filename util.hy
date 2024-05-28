(require std * :readers *) (import std *)

(import urllib.request [urlopen :as open-url])

(setv first (itemgetter 0)
      second (itemgetter 1))

(defn split-on [sep s]
  (.split s sep))

(defn pairs [xs]
  (pvector (zip (ncut xs ::2) (ncut xs 1::2))))

(defn pairs->map [xs]
  (let [keys (pset (map first xs))
        initial (pmap (map #%[%1 #v[]] keys))]
    (reduce (fn+ [acc [owner book]]
              (update acc #** {owner #%(.append %1 book)}))
            xs initial)))

(defn write-to-file [path data]
  (with [f (open path "w+")]
    (.write f data)))

(defn append-to-file [path data]
  (with [f (open path "a+")]
    (.write f (+ data "\n"))))

(defn read-from-file [path]
  (with [f (open path "r")]
    (.read f)))

(defn read-from-url [url]
  (with [page (open-url url)]
    (-> page .read (.decode "utf-8"))))
