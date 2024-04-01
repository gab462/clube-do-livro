(import hy)
(require hyrule [fn+ ->>] :readers [%])

(defmacro run-bot [token guilds handle-ready command-map]
  (let [cmds (.items command-map)]
    `(let [bot (commands.Bot :default-guild-ids ~guilds)]
       (defn/a [bot.event] on-ready []
         (await (~handle-ready bot)))
       ~@(->> cmds
              (map (fn+ [[k d]] [k (dict (.items d))])) ; FIXME: ?????
              (map (fn+ [[k {:keys [description args handler]}]]
                     `(defn/a [(bot.slash-command)]
                              ~(hy.models.Symbol (getattr k "name")) [interaction ~@args]
                        ~description
                        (await (interaction.send (~handler ~@(->> args (map #%(get %1 0)) list)))))))
              list)
       (bot.run ~token))))
