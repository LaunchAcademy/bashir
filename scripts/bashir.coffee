module.exports = (robot) ->
  ehAuthToken = "frontier_medicine-aj-dr"
  surveyReceptorUrl = "http://localhost:3000/api/v1/survey_responses"

  robot.router.post '/checkup', (req, res) ->
    res.send {status: 200}
    data = extractData req

    robot.brain.set "users", data.users
    robot.brain.set "question", data.question
    robot.brain.set "surveyId", data.survey_id

    deliverMessages()

  deliverMessages = ->
    step = 0
    interval = setInterval ->
      user = users()[step]
      step++
      if user == undefined
        clearInterval interval
      else
        ask user
    , 1000

  ask =  (username) ->
    console.log("Asking #{username}...")
    robot.send({room: username}, question())

  extractData = (req) ->
    if req.body.payload?
      JSON.parse req.body.payload
    else
      req.body

  question = ->
    robot.brain.get 'question'

  users = ->
    robot.brain.get "users"

  surveyId = ->
    robot.brain.get "surveyId"

  robot.hear /[1-9]|10/, (res) ->
    return null if users().length == 0
    user = res.message.room
    if hasNotBeenContacted user
      crossNameOff user
      res.send "Thank you for your input!"
      saveResponse res.message.rawText

  crossNameOff = (user)->
    index = users().indexOf user
    users().splice(index, 1)

  saveResponse = (text) ->
    console.log "Saving response..."
    surveyResponse = buildResponse text
    recordSurveyResponse surveyResponse

  hasNotBeenContacted = (user) ->
    users().indexOf(user) > -1

  buildResponse = (response) ->
    JSON.stringify
      bashir:
        auth:
          token: ehAuthToken

        info:
          survey_id: surveyId()
          response: response

  recordSurveyResponse = (surveyResponse) ->
    robot
      .http(surveyReceptorUrl)
      .header('Content-Type', 'application/json')
      .post(surveyResponse) (err, res, body) ->
