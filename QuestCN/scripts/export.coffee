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

filter = (str) ->
    return "" if not str?
    return str.replace(/"/g, "\\\"").replace(/\n/g, " ")

Mongoose.connect "mongodb://localhost/wow"
db = Mongoose.connection
db.on "error", console.error.bind(console, "connection error:")
db.once "open", ->

    errHandler = (err) ->
        console.log err

    Quest.find().stream().on "data", (quest) ->
        return if not quest.title_en?
        return if /UNUSED/.test quest.title_en
        console.log "QuestCN_QUESTS[\"#{filter quest.title_en}\"] = \"#{filter quest.title}\\n\\n#{filter quest.summary}\\n\\n开始:#{filter quest.start} | 结束:#{filter quest.over}\\n\\n#{filter quest.detail}\\n\\n任务需求:\\n#{(filter(line) for line in quest.requirements).join "\\n"}\""
