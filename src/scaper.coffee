request = require 'request'
cheerio = require 'cheerio'

cookieJar = request.jar()

request = request.defaults(
  jar: cookieJar
  followAllRedirects: true,
  headers:
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML,
    like Gecko) Chrome/30.0.1599.101 Safari/537.36'
)

console.log "username: %s\npassword: %s\n", process.env.NEU_USER,\
process.env.NEU_PASS

# GET initial page and find uuid
request.get(
  url: 'http://myneu.neu.edu/cp/home/displaylogin'
, (err, res, body) ->
  $ = cheerio.load(body)

  # TODO: Check for page success

  uuid = $('script[language="javascript1.1"]').html().split(\
  'document.cplogin.uuid.value=\"')[1].split("\"")[0]

  # POST login request
  request.post(
    url: 'https://myneu.neu.edu/cp/home/login'
    form:
      user: process.env.NEU_USER
      pass: process.env.NEU_PASS
      uuid: uuid
  , (err, res, body) ->
    # TODO: Check for login sucess

    request.get(
      url: 'http://myneu.neu.edu/cp/home/next'
    , (err, res, body) ->
      console.log body
    )
  )

)

