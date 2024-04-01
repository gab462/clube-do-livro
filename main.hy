(import nextcord [SlashOption :as opt]
        nextcord.ext [commands]
        handlers :as handle
        json [loads :as load-json]
        util [read-from-file])

(require hyrule [defmain let+]
         runner [run-bot])

(defmain [#* args]
  (let+ [{:strs [token guilds]} (load-json (read-from-file "env.json"))]
    (run-bot
      token guilds handle.ready
      {:ping {:description "Replies with pong!"
              :args []
              :handler handle.ping}
       :definir-livros {:description "Definir livros a serem considerados para o sorteio"
                        :args [[livros (opt :description "Livros a serem considerados")]]
                        :handler handle.define-books}
       :escolhido {:description "Definir alguem como escolhido para ter seu livro escolhido apos todos os restantes"
                   :args [[nome (opt :description "Nome do escolhido")]]
                   :handler handle.chosen}
       :sorteio {:description "Sortear proximo livro!"
                 :args []
                 :handler handle.draw}})))
