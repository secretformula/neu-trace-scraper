request = require 'request'
cheerio = require 'cheerio'

class Scraper
  REQUEST_USER_AGENT: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.103 Safari/537.36'
  MYNEU_LOGIN_URL: 'http://myneu.neu.edu/cp/home/displaylogin'
  MYNEU_LOGIN_POSTBACK_URL: 'https://myneu.neu.edu/cp/home/login'
  TRACE_LOAD_URL: 'http://myneu.neu.edu/cp/ip/login?sys=was&url=https://prod-web.neu.edu/wasapp/TRACE25'
  TRACE_URL: 'https://prod-web.neu.edu/wasapp/TRACE25'

  cookieJar: request.jar()

  constructor: () ->
    @request = request.defaults
      jar: @cookieJar,
      followAllRedirects: true,
      headers:
        'User-Agent': @REQUEST_USER_AGENT

  initDb: (settings) =>
    @_getLoginUuid (uuid) =>
      @_loginMyNeu settings.username, settings.password, uuid, (err, res, body) =>
        if err then throw err
        @_fixTraceCookies () =>
          @_openTrace (err, res, body) =>
            console.log body


  _getLoginUuid: (cb) ->
    @request @MYNEU_LOGIN_URL, (err, res, body) ->
      if err then throw err
      $ = cheerio.load(body)
      uuid = $('script[language="javascript1.1"]').html().split('document.cplogin.uuid.value=\"')[1].split("\"")[0]
      cb(uuid)
  _loginMyNeu: (username, password, uuid, cb) ->
    @request.post
      url: @MYNEU_LOGIN_POSTBACK_URL,
      form:
        user: username
        pass: password
        uuid: uuid
    , cb
  _fixTraceCookies: (cb) =>
    @request.get @TRACE_LOAD_URL, (err, res, html) =>
      if err then throw err

      search_params = res['request']['uri']['search'].substring(1).split('&')
      data = {}
      for param in search_params
        pair = param.split('=')
        name = pair[0]
        val = pair[1]
        if name is "cookie"
          new_cookie = @request.cookie(unescape(val))
          @cookieJar.setCookie(new_cookie, 'https://prod-web.neu.edu/CPIP/pickup_new.html')
        if name is "dest"
          data['destination_url'] = unescape(val)
        cb()
  _openTrace: (cb) ->
    @request.get @TRACE_URL, cb

module.exports = Scraper
