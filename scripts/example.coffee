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
request = require('request')

airi_rules = JSON.parse(fs.readFileSync('rules/airi.json', 'utf8'))
chiharu_rules = JSON.parse(fs.readFileSync('rules/chiharu.json', 'utf8'))

favorite = 'airi'
foolreply_off_names = ['chiharu', 'airi']

bot_id_map = {
  "B2VTXSF0D": "airi",
  "B2VU35LA3": "chiharu",
  "B2VU24EDT": "riko"
}

module.exports = (robot) ->

  robot.hear /(.*)/i, (res) ->
    user = bot_id_map[res.envelope.user.id]

    room = res.envelope.room
    utt = res.match[1]

    if user is 'airi'
      rules = airi_rules
      candidate = rules[utt]
    else if user is 'chiharu'
      rules = chiharu_rules
      candidate = rules[utt]

    client = robot.adapter.client

    if candidate and user in foolreply_off_names

      responses = candidate[Math.floor(Math.random() * candidate.length)]

      series = responses.map (response) ->
        (callback) ->
          # console.log response
          client.web.chat.postMessage(room, response, {as_user: true} )
          setTimeout(callback, 1000)

      setTimeout ->
        async.series(series)
      , 3000
    else if user is 'riko'
      request.post
        url: 'https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue'
        qs:
          APIKEY: process.env.DOCOMO_API_KEY
        json:
          utt: utt
      ,(err,response,body) ->
        if response.statusCode is 200
          # SUCCESS
          setTimeout ->
            client.web.chat.postMessage(room, body.utt, {as_user: true} )
          , 6000
        else
          # ERROR

  robot.respond /foolreply only (.*)/i, (res) ->
    room = res.envelope.room
    foolreply_only_name = rules[res.match[1]]
    res.send foolreply_only_name + 'に対してFOOLREPLYがONになりました'

  # robot.hear /badger/i, (res) ->
  #   res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"
  #
  # robot.respond /open the (.*) doors/i, (res) ->
  #   doorType = res.match[1]
  #   if doorType is "pod bay"
  #     res.reply "I'm afraid I can't let you do that."
  #   else
  #     res.reply "Opening #{doorType} doors"
  #
  # robot.hear /I like pie/i, (res) ->
  #   res.emote "makes a freshly baked pie"
  #
  # lulz = ['lol', 'rofl', 'lmao']
  #
  # robot.respond /lulz/i, (res) ->
  #   res.send res.random lulz
  #
  # robot.topic (res) ->
  #   res.send "#{res.message.text}? That's a Paddlin'"
  #
  #
  # enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
  # leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  #
  # robot.enter (res) ->
  #   res.send res.random enterReplies
  # robot.leave (res) ->
  #   res.send res.random leaveReplies
  #
  # answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  #
  # robot.respond /what is the answer to the ultimate question of life/, (res) ->
  #   unless answer?
  #     res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
  #     return
  #   res.send "#{answer}, but what is the question?"
  #
  # robot.respond /you are a little slow/, (res) ->
  #   setTimeout () ->
  #     res.send "Who you calling 'slow'?"
  #   , 60 * 1000
  #
  # annoyIntervalId = null
  #
  # robot.respond /annoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #     return
  #
  #   res.send "Hey, want to hear the most annoying sound in the world?"
  #   annoyIntervalId = setInterval () ->
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #   , 1000
  #
  # robot.respond /unannoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "GUYS, GUYS, GUYS!"
  #     clearInterval(annoyIntervalId)
  #     annoyIntervalId = null
  #   else
  #     res.send "Not annoying you right now, am I?"
  #
  #
  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   data   = JSON.parse req.body.payload
  #   secret = data.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  # robot.error (err, res) ->
  #   robot.logger.error "DOES NOT COMPUTE"
  #
  #   if res?
  #     res.reply "DOES NOT COMPUTE"
  #
  # robot.respond /have a soda/i, (res) ->
  #   # Get number of sodas had (coerced to a number).
  #   sodasHad = robot.brain.get('totalSodas') * 1 or 0
  #
  #   if sodasHad > 4
  #     res.reply "I'm too fizzy.."
  #
  #   else
  #     res.reply 'Sure!'
  #
  #     robot.brain.set 'totalSodas', sodasHad+1
  #
  # robot.respond /sleep it off/i, (res) ->
  #   robot.brain.set 'totalSodas', 0
  #   res.reply 'zzzzz'
