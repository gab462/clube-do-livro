(require std * :readers *) (import std *)

(defmacro run-bot [token guilds handle-ready command-map]
  (let [cmds (.items (hy.eval command-map))]
    `(let [bot (commands.Bot :default-guild-ids ~guilds)]
       (defn/a [bot.event] on-ready []
         (await (~handle-ready bot)))
       ~@(->> cmds
              (map (fn+ [[k {:strs [description args handler]}]]
                     `(defn/a [(bot.slash-command)]
                              ~(hy.models.Symbol k) [interaction ~@args]
                        ~description
                        (await (interaction.send (~handler ~@(->> args (map #%(get %1 0))))))))))
       (bot.run ~token))))
