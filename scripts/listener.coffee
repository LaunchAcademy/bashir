module.exports = (robot) ->
  robot.router.post '/checkup', (req, res) ->
    data = if req.body.payload?
      JSON.parse req.body.payload
    else
      req.body

    surveyResponse = JSON.stringify
      bashir:
        auth:
          token: "5"

        info:
          team_id: null
          asked_at:  null
          answered_at:  null
          question:  "Do you believe in love after love"
          response: "the heart will go on"
          responder_role:  "student"

    console.log surveyResponse

    if data.engage
      robot
        .http("http://localhost:3000/api/v1/survey_responses")
        .header('Content-Type', 'application/json')
        .post(surveyResponse) (err, res, body) ->
          console.log res.statusCode
