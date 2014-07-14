Unsubscribers = new Meteor.Collection 'unsubscribers'

Meteor.methods
  unsubscribe: (email) -> Email.unsubscribe email
  resubscribe: (email) -> Email.resubscribe email

# takes and returns an array of strings
rejectUnsubscribers = (emails) ->
  unsubscribers = Unsubscribers.find(email: $in: emails).fetch()
  isUnsubscriber = _.partial _.contains, (_.pluck unsubscribers, 'email')
  _.reject emails, isUnsubscriber

sendEmail = _.bind Email.send, Email
_.extend Email,
  # TODO: add hooks
  unsubscribe: (email) -> Unsubscribers.upsert { email: email }, email: email
  resubscribe: (email) -> Unsubscribers.remove email: email
  send: (options) ->
    # if options.to is a string arrayify it
    if _.isString options.to then options.to = [options.to]
    options.to = rejectUnsubscribers options.to
    sendEmail options if options.to.length isnt 0

### wrap rejectUnsubscribers in a few functions to make it more versatile ###

# allow it to take a string
splitStrings = (emails) ->
  if _.isString emails then emails.split ',' else emails

# throw an error on undefined input
throwOnUndefined = (emails) ->
  if _.isUndefined emails
    throw new Error 'Unsubscribe: rejectUnsubscribers - emails undefined'
  emails

rejectUnsubscribers =
  _.compose rejectUnsubscribers, splitStrings, throwOnUndefined
