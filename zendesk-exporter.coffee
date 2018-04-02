fs         = require 'fs'
rp         = require 'request-promise'

creds      = 

  "subdomain": process.env.ZENDESK_DOMAIN
  "username" : process.env.ZENDESK_USER
  "token"    : process.env.ZENDESK_TOKEN

userAgent   = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36'
authHeaders =
  'Authorization' : 'Basic ' + new Buffer("#{creds.username}/token:#{creds.token}").toString('base64')
  'user-agent'    : userAgent

# Get 100 Users at each request by default (maximum)
getUsers = (options)->

  options         = options or {}  
  options.url     = options.url or "https://#{creds.subdomain}.zendesk.com/api/v2/users.json"
  options.method  = "GET"
  options.headers = authHeaders
  options.json    = true

  console.log "Requesting page: #{options.url}"
  rp(options)

getAllUsers = ()->

  zendeskJSON = {}

  new Promise (resolve,request)->

    # 1. Do a first request and get the count and store the first 100 entries
    getUsers()
    .then((res)-> 

      # Store first 100 entries
      zendeskJSON = res

      # 2. Find the number of remaining page numbers
      remaining = ( res.count / 100) >> 0  # 1174 / 100
      if res.count % 100 isnt 0 then remaining++
      return remaining
    ).then((remaining)->

      console.log "Remaining Pages: #{remaining}" # 11

      # 3. Create a loop with the remaining number pages, decrementing at each step
      # "https://#{creds.subdomain}.zendesk.com/api/v2/users.json?page=2"
      sequentialPromise = Promise.resolve()

      for num in [2..remaining]

        do (num)->

          sequentialPromise = sequentialPromise.then ()=>

            getUsers({ url: "https://#{creds.subdomain}.zendesk.com/api/v2/users.json?page=#{num}" })
            .then((res)=>

              console.log "Number of users per entry: #{res.users.length}"
              console.log "Next Page: #{res.next_page}"
              zendeskJSON.users = zendeskJSON.users.concat(res.users) 

            ).catch(console.log)

      sequentialPromise.then((res)->) 

    ).then((res)->

      console.log("Number of returned Entries: ", zendeskJSON.users.length)
      console.log("Writing JSON file...")
      return resolve(zendeskJSON)

    ).catch(console.log)

# GET ALL USERS AND WRITE TO FILE
writeUsersToFile = ()->

  getAllUsers()
  .then((res)-> fs.writeFileSync('zendesk.json', JSON.stringify(res.users, null, '\t'), 'utf8'))
  .catch(console.log)

# WiP
createCSV = ()->

  zendeskUsers = fs.readFileSync('zendesk.json', 'utf8')
  zendeskUsers = JSON.parse(zendeskUsers)
  counter = 0
  zendeskUsers.map((res)->
    console.log counter, res.name, res.email
    counter++
  )
  console.log("Number of returned Entries: ", zendeskUsers.length)

# Usage: Get first 100 customers:
getUsers().then(console.log).catch(console.log)
