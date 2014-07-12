fs = require('fs')
request = require('request')
cheerio = require('cheerio')

userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.103 Safari/537.36'

cookies = request.jar()

request = request.defaults
  jar: cookies,
  followAllRedirects: true,
  headers:
    'User-Agent': userAgent

loadTrace = (url) ->
  request url, (err, res, html) ->
    unless err
      console.log html

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

request 'http://myneu.neu.edu/cp/home/displaylogin', (err, res, html) ->
  unless err
    $ = cheerio.load(html)
    uuid = $('script[language="javascript1.1"]').html().split('document.cplogin.uuid.value=\"')[1].split("\"")[0]
    login(uuid)
  return



