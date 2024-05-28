(require std * :readers *) (import std *)

(require runner [run-bot])

(import nextcord [SlashOption :as opt]
        nextcord.ext [commands]
        json [loads :as load-json]
        util [read-from-file]
        handlers :as handle)

(defmain [#* args]
  (let+ [{:strs [token guilds]} (load-json (read-from-file "env.json"))]
    (run-bot
      token guilds handle.ready
      #m{:ping #m{:description "Replies with pong!"
                  :args []
                  :handler 'handle.ping}
         :definir-livros #m{:description "Definir livros para o sorteio"
                            :args '[[livros (opt :description "Livros a serem adicionados")]]
                            :handler 'handle.define-books}
         :definir-escolhido #m{:description "Excluir pessoa dessa rodada de sorteios"
                               :args '[[nome (opt :description "Nome do escolhido")]]
                               :handler 'handle.define-chosen}
         :livros #m{:description "Visualizar livros restantes"
                    :args []
                    :handler 'handle.get-books}
         :escolhidos #m{:description "Visualizar escolhidos dessa rodada"
                        :args []
                        :handler 'handle.get-chosen}
         :sorteio #m{:description "Sortear proximo livro!"
                     :args []
                     :handler 'handle.draw}
         :frase #m{:description "Frase aleatoria"
                   :args []
                   :handler 'handle.phrase}})))
