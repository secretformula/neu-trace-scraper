Scraper = require './scraper'

scraper = new Scraper()

scraper.initDb
  username: process.env.NEU_USER
  password: process.env.NEU_PASS
