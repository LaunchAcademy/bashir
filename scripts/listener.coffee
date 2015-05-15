module.exports = (robot) ->
  contactableUsers = []
  question = null
  slackUsers = robot.adapter.client.users

  robot.hear /[1-9]|10/, (res) ->
    user = res.message.room
    if hasNotBeenContacted user
      console.log "Heard back from #{user}"
      res.send "Thank you for your input!"
      saveResponse res.message.rawText
      cleanup user

  robot.router.post '/checkup', (req, res) ->
    res.send {status: 200}
    data = extractData req
    question = "on a scale from 1-10 (10 being the best), how awesome was launch academy this week?"
    assembleContactableUsers()
    for user in contactableUsers
      ask user

  assembleContactableUsers = ->
    contactableUsers = ['dpickett']
    #contactableUsers = []
    #for k, v of slackUsers
      #name = slackUsers[k].name
      #contactableUsers.push name unless weIgnore name

  weIgnore = (name) ->
    ignoredUsers = ['slackbot', 'bashir', 'dtextra4', 'dtextra3']
    ignoredUsers.indexOf(name) > -1

  extractData = (req) ->
    if req.body.payload?
      JSON.parse req.body.payload
    else
      req.body

  saveResponse = (text) ->
    console.log "Saving response..."
    surveyResponse = buildResponse question, text
    recordSurveyResponse surveyResponse

  hasNotBeenContacted = (user) ->
    contactableUsers.indexOf(user) > -1

  cleanup = (user) ->
    index = contactableUsers.indexOf(user)
    contactableUsers.splice(index, 1)
    if contactableUsers.length == 0
      robot.shutdown()

  ask = (username) ->
    console.log("Asking #{username}...")
    robot.send({room: username}, question)

  buildResponse = (question, response) ->
    JSON.stringify
      bashir:
        auth:
          token: "frontier_medicine-aj-dr"

        info:
          team_id: null
          asked_at:  null
          answered_at:  null
          question:  question
          response: response
          responder_role:  "student"

  recordSurveyResponse = (surveyResponse) ->
    robot
      .http("http://localhost:3000/api/v1/survey_responses")
      .header('Content-Type', 'application/json')
      .post(surveyResponse) (err, res, body) ->
