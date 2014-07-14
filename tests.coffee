# set-up email
emailSent = undefined
recipients = undefined
EmailTest.hookSend (options) ->
  emailSent = true
  recipients = options.to
  false

# set up normal recipients
subscribers = ['subs0@test.com', 'subs1@test.com', 'subs2@test.com']

# set up unsubscribers
unsubscribers = ['unsub0@test.com', 'unsub1@test.com', 'unsub2@test.com']
unsubscribe = _.partial Meteor.call, 'unsubscribe'
isUnsubscriber = _.partial _.contains, unsubscribers
_.each unsubscribers, unsubscribe

# set up resubscriber */
resubscribers = ['resub0@test.com', 'resub1@test.com', 'resub2@test.com']
resubscribe = _.partial Meteor.call, 'resubscribe'
_.each(resubscribers, unsubscribe)
_.each(resubscribers, resubscribe)

Tinytest.add 'Unsubscribe - rejectUnsubscribers', (test) ->
  recipients = _.union subscribers, unsubscribers, resubscribers
  recipients = rejectUnsubscribers recipients
  isRecipient = _.partial _.contains, recipients
  anyUnsubscribers = _.any recipients, isUnsubscriber
  test.isFalse anyUnsubscribers, 'Expected no unsubscribers'
  allSubscribers = _.every subscribers, isRecipient
  test.isTrue allSubscribers, 'Expected all subscribers'
  allResubscribers = _.every resubscribers, isRecipient
  test.isTrue allResubscribers, 'Expected all resubscribers'

Tinytest.add 'Unsubscribe - Send a normal email', (test) ->
  emailSent = false
  Email.send to: subscribers, from: 'test@test.com'
  test.isTrue emailSent, 'Expected the email to be sent'

Tinytest.add 'Unsubscribe - Don\'t send to an unsubscriber', (test) ->
  emailSent = false
  Email.send (to: (_.first unsubscribers), from: 'test@test.com')
  test.isFalse emailSent, 'Expected the email to not be sent'

Tinytest.add 'Unsubscribe - Filter unsubscribed from a list', (test) ->
  recipients = _.union subscribers, unsubscribers
  Email.send to: recipients, from: 'test@test.com'
  anyUnsubscribers = _.any recipients, isUnsubscriber
  test.isFalse anyUnsubscribers, 'Expected no unsubscribed recipients'

Tinytest.add 'Unsubscribe - Don\'t send if all are unsubscribed', (test) ->
  emailSent = false
  Email.send to: unsubscribers, from: 'test@test.com'
  test.isFalse emailSent, 'Expected the email to not be sent'

Tinytest.add 'Unsubscribe - Send an email to resubscribed recipients', (test) ->
  emailSent = false
  Email.send to: resubscribers, from: 'test@test.com'
  test.isTrue emailSent, 'Expected the email to be sent'
