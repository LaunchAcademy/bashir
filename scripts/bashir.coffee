module.exports = (robot) ->
  users = null

  robot.router.post '/checkup', (req, res) ->
    res.send {status: 200}
    data = extractData req
    question = "on a scale from 1-10 (10 being the best), how awesome was launch academy this week?"
    #users = data.users
    users = ['jarvis']
    step = 0
    interval = setInterval ->
      user = users[step]
      step++
      if user == undefined
        clearInterval interval
      else
        ask question, user
    , 1000

  ask = (question, username) ->
    console.log("Asking #{username}...")
    robot.send({room: username}, question)

  extractData = (req) ->
    if req.body.payload?
      JSON.parse req.body.payload
    else
      req.body

  robot.hear /[1-9]|10/, (res) ->
    user = res.message.room
    return null if users.length == 0
    if hasNotBeenContacted user
      console.log "Heard back from #{user}"
      res.send "Thank you for your input!"
      saveResponse res.message.rawText

  saveResponse = (text) ->
    console.log "Saving response..."
    surveyResponse = buildResponse text
    recordSurveyResponse surveyResponse

  hasNotBeenContacted = (user) ->
    users.indexOf(user) > -1

  buildResponse = (response) ->
    JSON.stringify
      bashir:
        auth:
          token: "frontier_medicine-aj-dr"

        info:
          survey_id: null
          response: response

  recordSurveyResponse = (surveyResponse) ->
    robot
      .http("http://localhost:3000/api/v1/survey_responses")
      .header('Content-Type', 'application/json')
      .post(surveyResponse) (err, res, body) ->
