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

airi_rules = JSON.parse(fs.readFileSync('rules/airi.json', 'utf8'))
chiharu_rules = JSON.parse(fs.readFileSync('rules/chiharu.json', 'utf8'))

favorite = 'airi'

bot_id_map = {
  "B2VTXSF0D": "airi",
  "B2VU35LA3": "chiharu",
  "B2VU24EDT": "riko"
}

module.exports = (robot) ->

  robot.hear /(.*)/i, (res) ->
    user = bot_id_map[res.envelope.user.id]
    return if user is favorite

    room = res.envelope.room

    if user is 'airi'
      rules = airi_rules
    else if user is 'chiharu'
      rules = chiharu_rules

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
