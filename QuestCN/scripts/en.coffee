{Crawler} = require 'crawler'
Mongoose  = require 'mongoose'

QuestSchema = Mongoose.Schema {
    _id: Number
    title: String
    title_en: String
    summary: String
    detail: String
    requirements: [String]
    start: String
    over: String
    level: Number
    min_level: Number


}

Quest = Mongoose.model "Quest", QuestSchema

trim = (str) ->
    return str.replace(/^(\r\n)+/, "").replace(/(\r\n)+$/, "").trim()

Mongoose.connect "mongodb://localhost/wow"
db = Mongoose.connection
db.on "error", console.error.bind(console, "connection error:")
db.once "open", ->

    errHandler = (err) ->
        console.log err

    c = new Crawler {
        maxConnections: 20

        callback: (err, result, $) ->
            return errHandler err if err

            try
                title_en = trim($(".main-contents h1").html().replace("[DEPRECATED]", "").replace(/&lt;.*?&gt;/g, ""))
                return if title_en == ""
                quest_id = this.uri.match(/quest=(\d+)/)[1]

                Quest.update {_id: parseInt(quest_id)}, {title_en: title_en}, (err) ->
                    return errHandler err if err
                    console.log "Quest ##{quest_id}: #{title_en}"

            catch err
                errHandler err
    }

    Quest.find().stream().on "data", (quest) ->
        c.queue "http://www.wowhead.com/quest=#{quest._id}"
