{Crawler} = require 'crawler'
Mongoose  = require 'mongoose'

QuestSchema = Mongoose.Schema {
    _id: Number
    title: String
    summary: String
    detail: String
    requirements: [String]
    start: String
    over: String
    level: Number
    min_level: Number


}

Quest = Mongoose.model "Quest", QuestSchema

REQ_PATTERN       = /<a href=".*?.html">(.*?)<\/a> x (\d+)/
START_PATTERN     = /开始:<a href=".*?">(.*?)<\/a>/
OVER_PATTERN      = /结束:<a href=".*?">(.*?)<\/a>/
LEVEL_PATTERN     = /任务等级: (\d+)/
MIN_LEVEL_PATTERN = /需要等级: (\d+)/

trim = (str) ->
    return str.replace(/^(\r\n)+/, "").replace(/(\r\n)+$/, "").trim()

Mongoose.connect "mongodb://localhost/vanilla_wow_quests"
db = Mongoose.connection
db.on "error", console.error.bind(console, "connection error:")
db.once "open", ->

    errHandler = (err) ->
        console.log err

    PROCESSED = {}

    c = new Crawler {
        maxConnections: 20

        # this will be called for each crawled page
        callback: (err, result, $) ->
            return errHandler err if err

            $('#PagerBottom a').each (index, a) ->
                return if PROCESSED[a.href]?
                PROCESSED[a.href] = yes
                c.queue a.href

            $('#Panel_Main .itemtd a').each (index, a) ->
                return if not /quest-/.test a.href
                return if PROCESSED[a.href]?
                PROCESSED[a.href] = yes
                c.queue {
                    uri: a.href
                    jQuery: yes
                    callback: (err, result, $) ->
                        try
                            quest = new Quest()
                            quest._id = this.uri.match(/quest-(\d+)/)[1]

                            quest.title = trim $('h1#itemtitle').html().match(/<div.*<\/div>(.*)/)[1]
                            quest.summary = trim $('.quest1 .quest').html()

                            detail = []
                            $('.info .quest2').each -> detail.push trim $(this).html()
                            quest.detail = detail.join "\n"

                            quest.requirements = []
                            $('.killlist').each ->
                                $(this).find('span').each ->
                                    if REQ_PATTERN.test $(this).html()
                                        m = $(this).html().match REQ_PATTERN
                                        if m[2] != "0"
                                            quest.requirements.push "#{trim m[1]} x #{m[2]}"

                            $(".baseinfo li").each ->
                                html = $(this).html()
                                if START_PATTERN.test html
                                    quest.start = html.match(START_PATTERN)[1]
                                else if OVER_PATTERN.test html
                                    quest.over = html.match(OVER_PATTERN)[1]
                                else if LEVEL_PATTERN.test html
                                    quest.level = html.match(LEVEL_PATTERN)[1]
                                else if MIN_LEVEL_PATTERN.test html
                                    quest.min_level = html.match(MIN_LEVEL_PATTERN)[1]

                            quest.save()

                        catch err
                            console.log err

                }
    }

    c.queue "http://wowdb.games.sina.com.cn/quest.aspx?page=375"
