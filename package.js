Package.describe({
  name: 'rollypolly:impersonate',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: 'https://github.com/rollymaduk/impersonate',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.use('jquery');
  api.use('coffeescript');
  api.use('reactive-var');
  api.use('templating','client');
 /* api.use('abpetkov:switchery','client');*/
  api.use('alanning:roles');
  api.use('accounts-base','client');
  api.use('gwendall:body-events@0.1.4','client');
  api.versionsFrom('1.1.0.2');
  api.addFiles('client/controls/accordion/accordion.html','client');
  api.addAssets('client/controls/accordion/cog.png','client');
  api.addFiles('client/controls/accordion/style.css','client');
  api.addFiles('client/controls/accordion/accordion.js','client');
  api.addFiles('client/controls/switch/futurico/futurico.css','client');
  api.addAssets('client/controls/switch/futurico/futurico.png','client');
  api.addFiles('client/controls/switch/icheck.min.js','client');
  api.addFiles('client/controls/switch/toggle_switch.html','client');
  api.addFiles('client/lib/jquery.slimscroll.min.js','client');
  api.addFiles('client/impersonate.coffee','client');
  api.addFiles('common/impersonate.coffee',['client','server']);
    /*server assets*/
  api.addFiles('server/impersonate.coffee','server');
  api.export('Impersonate');
});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('rollypolly:impersonate');
  api.addFiles('impersonate-tests.js');
});
