(import nextcord [SlashOption :as opt]
        nextcord.ext [commands]
        hyrule [flatten]
        json [dumps :as dump-json
              loads :as load-json]
        random [choice :as random-choice]
        util [split-on pairs map-from-pairs map-from-dict
              write-to-file read-from-file append-to-file])
(require hyrule [defmain setv+ ->> ->] :readers [% /])

(setv+ {:strs [token guilds]} (load-json (read-from-file "env.json"))
       bot (commands.Bot :default-guild-ids guilds))

(defn/a [bot.event] on-ready []
  (await (.sync_all_application_commands bot))
  (print f"Logged in as {bot.user}"))

(defn/a [(bot.slash-command
           :description "Replies with pong!")]
        ping [interaction]
  (await (interaction.send "Pong!")))

(defn/a [(bot.slash-command
           :description "Definir livros a serem considerados para o sorteio")]
        definir-livros [interaction
                        [livros (opt :description "Livros a serem considerados")]]
  (await
    (interaction.send
      (do
        (->> livros
             (split-on " ")
             pairs
             map-from-pairs
             ._asdict
             dump-json
             (write-to-file "books.json"))
        (read-from-file "books.json")))))

(defn/a [(bot.slash-command
           :description "Definir alguem como escolhido para ter seu livro escolhido apos todos os restantes")]
        escolhido [interaction
                   [nome (opt :description "Nome do escolhido")]]
  (await
    (interaction.send
      (do
        (append-to-file "chosen.txt" nome)
        f"{nome} definido como escolhido"))))

; TODO: handle full chosen.txt
(defn/a [(bot.slash-command
           :description "Sortear proximo livro!")]
        sorteio [interaction]
  (await
    (interaction.send
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
        (do
          (append-to-file "chosen.txt" newly-chosen)
          (write-to-file "books.json" (-> new-collection ._asdict dump-json))
          f"Livro escolhido: {choice}")))))

(defmain [#* args]
  (bot.run token))
