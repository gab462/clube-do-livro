(require std * :readers *) (import std *)

(require runner [run-bot])

(import nextcord [SlashOption :as opt]
        nextcord.ext [commands]
        handlers :as handle)

(defmain [#* args]
  (let+ [{:strs [token guilds]} (load-json (read-from-file "env.json"))]
    (run-bot
      token guilds handle.ready
      #m{:ping #m{:description "Replies with pong!"
                  :args []
                  :handler 'handle.ping}
         :definir-livros #m{:description "Definir livros a serem considerados para o sorteio"
                            :args '[[livros (opt :description "Livros a serem considerados")]]
                            :handler 'handle.define-books}
         :escolhido #m{:description "Definir alguem como escolhido para ter seu livro escolhido apos todos os restantes"
                       :args '[[nome (opt :description "Nome do escolhido")]]
                       :handler 'handle.chosen}
         :sorteio #m{:description "Sortear proximo livro!"
                     :args []
                     :handler 'handle.draw}})))
