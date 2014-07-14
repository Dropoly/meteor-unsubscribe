Unsubscribers = new Meteor.Collection 'unsubscribers'

Meteor.methods
  unsubscribe: (email) -> Email.unsubscribe email
  resubscribe: (email) -> Email.resubscribe email

# takes and returns an array of strings
rejectUnsubscribers = (emails) ->
  unsubscribers = Unsubscribers.find(email: $in: emails).fetch()
  isUnsubscriber = (email) -> _.contains (_.pluck unsubscribers, 'email'), email
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
