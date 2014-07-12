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

# GET initial page and find uuid
request.get(
  url: 'http://myneu.neu.edu/cp/home/displaylogin'
, (err, res, body) ->
  $ = cheerio.load(body)
  console.log $("script[language='javascript1.1']").html()
)

# POST login request
request.post(
  url: 'https://myneu.neu.edu/cp/home/login'
  form:
    user: process.env.NEU_USER
    pass: process.env.NEU_PASS
    uuid: 'e95c1238-b97c-4fe6-a9f9-8b73ff0eff1c'
, (err, res, body) ->
  # console.log body
)
