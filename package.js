Package.describe({
  summary: "Unsubscribe from Meteor emails"
});

Package.on_use(function (api, where) {
  api.use(['coffeescript', 'email', 'underscore'], ['server']);

  api.export(['Unsubscribers', 'rejectUnsubscribers'], ['server']);

  api.add_files(['unsubscribe.coffee'], ['server']);
});

Package.on_test(function (api) {
  api.use('unsubscribe');

  api.add_files('tests.coffee', ['client', 'server']);
});
