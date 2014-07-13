fs = require('fs')
request = require('request')
cheerio = require('cheerio')

userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.103 Safari/537.36'

cookies = request.jar()
reviews = []

questions = [{
  text: "All responses are completely anonymous, and participation in the evaluation process is expected. However, you are permitted to opt out of completing this questionnaire by selecting \"Opt Out.\""
  options: ["No Response", "I will participate", "I choose not to participate"]
},{
  text: "The syllabus helped me to learn."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "The textbook(s) helped me to learn."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "The materials posted online, including Blackboard, helped me to learn."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "The out-of-class assignments and fieldwork helped me to learn."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "The lectures helped me to learn."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "The in-class discussions and activities helped me to learn."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "The classroom technology helped me to learn."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "The number of hours per week I devoted to this course including lectures, discussions, homework, reading, projects, assignments and tests"
  options: ["1-4", "5-8", "9-12", "13-16", "17-20", "No Response"]
},{
  text: "I found this course intellectually challenging."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "I learned a lot in this course."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "I learned to apply course concepts and principles."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "I developed additional skills in expressing myself orally and in writing."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "I learned to analyze and evaluate ideas, arguments, and points of view"
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "The instructor possessed the basic communications skills necessary to teach the course."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "The instructor clearly communicated ideas and information."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "The instructor clearly stated the objectives of the course."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "The instructor covered what was stated in the course objectives and syllabus."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "The instructor came to class prepared to teach."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "The instructor used class time effectively."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "The instructor provided sufficient feedback."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "The instructor fairly evaluated my performance."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "The instructor is someone I would recommend to other students."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "The instructor treated students with respect."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "The instructor acknowledged and took effective action when students did not understand the material."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "The instructor was available to assist students outside of class."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "The instructor displayed enthusiasm for the course."
  options: ["Strongly Agree", "Agree", "Neutral", "Disagree", "Strongly Disagree", "No Response", "N/A"]
},{
  text: "What is your overall rating of this instructor's teaching effectiveness?"
  options: ["Almost Always Effective", "Usually Effective", "Sometimes Effective", "Rarely Effective", "Never Effective", "No Response"]
}]

questionsJSON = JSON.stringify(questions, null, 2)

unless fs.existsSync('questions.json')
  fs.writeFile 'questions.json', questionsJSON, (error) ->
    throw error if error
    console.log "questions JSON written"

unless fs.existsSync('reviews.json')
  fs.writeFile 'reviews.json', '', (error) ->
    throw error if error

fs.readFile 'reviews.json', 'utf8', (error, data) ->
  throw error if error

  try
    reviews = JSON.parse(data)
  catch error
    reviews = {}
  finally
    start()


repeat = (ms, func) ->
  setInterval func, ms

# backup to disk every minute
repeat 60000, ->
  console.log 'writing reviews to disc'
  fs.writeFile 'reviews.json', JSON.stringify(reviews), (error) ->
    throw error if error
    console.log 'wrote reviews to disks'


console.log reviews

request = request.defaults
  jar: cookies,
  followAllRedirects: true,
  headers:
    'User-Agent': userAgent

scrape = ->
  request.post
    url: 'https://prod-web.neu.edu/wasapp/TRACE25/secure/search.do',
    form:
      'survey.surveyID': '0'
      'instructor.nuid': ''
      'department.deptId': ''
  , (err, res, html) ->
    $ = cheerio.load(html)
    reviewURLs = []

    $('tr').each (i, el) ->
      reviewURLs.push $(el).find('a').attr('href')

    loadReviews(reviewURLs)


delay = (ms, func) ->
  setTimeout func, ms

loadReviews = (reviewURLs) ->

  console.log "Remaining: #{reviewURLs.length}"
  current = reviewURLs.pop()

  unless /detail.do/.test(current)
    console.log 'not a real review'
    loadReviews reviewURLs
    return

  reviewUrlSearch = current.split("?")[1].split("&")
  courseId = reviewUrlSearch[0].split("=")[1]
  sectionId = reviewUrlSearch[1].split("=")[1]

  key = "#{courseId}|#{sectionId}"

  if reviews[key]?
    console.log 'review already exists!'
    loadReviews reviewURLs
    return

  scrapeReview current, key, courseId, sectionId, reviewURLs

scrapeReview = (review_url, key, courseId, sectionId, reviewURLs) ->

  console.log "Scraping #{review_url}"

  request "https://prod-web.neu.edu#{review_url}", (error, response, html) ->
    if error then throw error

    $ = cheerio.load(html)

    review =
      professor: $('th:contains("Instructor Name")').next().text()
      term: $('th:contains("Term")').next().text()
      numStudents: parseInt($('th:contains("Students Enrolled")').next().text())
      numResponses: parseInt($('th:contains("Students Polled")').next().text().split('(')[0])
      subject: $('th:contains("Subject")').next().text()
      course: $('th:contains("Course")').next().text()

    console.log review

    responses = []

    for question in questions
      text = question['text']

      response = {}
      response['question'] = text
      response['answers'] = []

      $("strong:contains(#{text})").next().find('tr').each (i, el) ->
        response['answers'].push parseInt($(el).find('td:not(.nowrap)').text())

      responses.push response

    review['responses'] = responses

    courseCommentsUrl = "/wasapp/TRACE25/secure/memo.do?ciid=#{courseId}&qid=82&sid=#{sectionId}"
    profCommentsUrl = "/wasapp/TRACE25/secure/memo.do?ciid=#{courseId}&qid=81&sid=#{sectionId}"

    courseCommentsDone = false
    profCommentsDone = false

    saveReview = =>
      reviews[key] = review
      loadReviews reviewURLs
      console.log reviews[key]
      return

    saveCourseComments = (courseComments) ->
      console.log courseComments
      review['courseComments'] = courseComments
      courseCommentsDone = true
      if profCommentsDone
        saveReview()

    saveProfComments = (profComments) ->
      console.log profComments
      review['profComments'] = profComments
      profCommentsDone = true
      if courseCommentsDone
        saveReview()

    request "https://prod-web.neu.edu#{courseCommentsUrl}", (error, response, html) ->
      throw error if error
      courseComments = []

      $ = cheerio.load(html)

      $('p').each (i, el) =>
        comment = $(el).text().trim()

        unless /Close Window/i.test(comment)
          unless comment is ''
            courseComments.push comment

      saveCourseComments(courseComments)


    request "https://prod-web.neu.edu#{profCommentsUrl}", (error, response, html) ->
      throw error if error
      profComments = []

      $ = cheerio.load(html)

      $('p').each (i, el) =>
        comment = $(el).text().trim()

        unless /Close Window/i.test(comment)
          unless comment is ''
            profComments.push comment

      saveProfComments(profComments)


loadTrace = (url) ->
  request url, (err, res, html) ->
    unless err
      scrape()

postLogin = ->
  traceURL = 'http://myneu.neu.edu/cp/ip/login?sys=was&url=https://prod-web.neu.edu/wasapp/TRACE25'
  request traceURL, (err, res, html) ->
    unless err
      search_params = res['request']['uri']['search'].substring(1).split('&')
      data = {}
      for param in search_params
        pair = param.split('=')
        name = pair[0]
        val = pair[1]
        if name is "cookie"
          new_cookie = request.cookie(unescape(val))
          cookies.setCookie(new_cookie, 'https://prod-web.neu.edu/CPIP/pickup_new.html')
        if name is "dest"
          data['destination_url'] = unescape(val)

      loadTrace data['destination_url']

login = (uuid) ->
  request.post
    url: 'https://myneu.neu.edu/cp/home/login',
    form:
      user: process.env.NEU_USER
      pass: process.env.NEU_PASS
      uuid: uuid
  , (err, res, html) ->
    postLogin()


start = ->
  console.log 'starting'
  request 'http://myneu.neu.edu/cp/home/displaylogin', (err, res, html) ->
    unless err
      $ = cheerio.load(html)
      uuid = $('script[language="javascript1.1"]').html().split('document.cplogin.uuid.value=\"')[1].split("\"")[0]
      login(uuid)
    return



