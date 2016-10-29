# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

fs = require('fs')
async = require('async')

rules = JSON.parse(fs.readFileSync('rules/example.json', 'utf8'))

favorite = 'airi'

bot_id_map = {
  "airi": "B2VTXSF0D",
  "chiharu": "B2VU35LA3",
  "riko": "B2VU24EDT"
}

module.exports = (robot) ->

  robot.hear /(.*)/i, (res) ->
    return if res.envelope.user.id is bot_id_map[favorite]

    room = res.envelope.room

    candidate = rules[res.match[1]]

    if candidate
      responses = candidate[Math.floor(Math.random() * candidate.length)]

      client = robot.adapter.client

      series = responses.map (response) ->
        (callback) ->
          # console.log response
          client.web.chat.postMessage(room, response, {as_user: true} )
          setTimeout(callback, 1000)

      async.series(series)

  robot.hear /favorite (.*)/i, (res) ->
    room = res.envelope.room
    favorite = res.match[1]
    res.send '本命を' + favorite + 'に変更しました。悪い男！'
