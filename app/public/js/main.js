(function() {
  require.config({
    paths: {
      "angular": "../vendors/angular/angular.min",
      "angularMocks": "../vendors/angular-mock/angular-mock",
      "angularRoute": "../vendors/angular-route/angular-route.min",
      "angularResource": "../vendors/angular-resource/angular-resource.min",
      "angularCookies": "../vendors/angular-cookies/angular-cookies.min",
      "angularSanitize": "../vendors/angular-sanitize/angular-sanitize.min",
      "angularLocalStorage": "../vendors/angular-local-storage/angular-local-storage.min",
      "angularUiRouter": "../vendors/angular-ui-router/release/angular-ui-router.min",
      "jquery": "../vendors/jquery/dist/jquery.min",
      "angular-bootstrap": "../vendors/angular-bootstrap/ui-bootstrap-tpls.min",
      "domReady": "../vendors/requirejs-domready/domready",
      "underscore": "../vendors/underscore/underscore",
      "ngInfiniteScroll": "../vendors/ngInfiniteScroll/build/ng-infinite-scroll",
      "chart": "../vendors/Chart.js-master/Chart",
      "angles": "../vendors/angles-master/angles",
      "angular-deckgrid": "../vendors/angular-deckgrid/angular-deckgrid"
    },
    shim: {
      "angular": {
        'exports': 'angular'
      },
      "angularMocks": {
        deps: ['angular'],
        'exports': 'angular.mock'
      },
      "angularRoute": {
        deps: ['angular']
      },
      "angularResource": {
        deps: ['angular']
      },
      "angularCookies": {
        deps: ['angular']
      },
      "angularSanitize": {
        deps: ['angular']
      },
      "angularLocalStorage": {
        deps: ['angular']
      },
      "angularUiRouter": {
        deps: ['angular']
      },
      "angular-bootstrap": {
        deps: ['angular']
      },
      "angular-deckgrid": {
        deps: ['angular']
      },
      'angles': {
        deps: ['angular', 'chart']
      },
      "jquery": {
        exports: '$'
      },
      "underscore": {
        exports: '_'
      },
      "ngInfiniteScroll": {
        deps: ['jquery', 'angular']
      }
    }
  });

  require(['jquery', 'angular', 'app', 'routes', 'domReady'], function(jquery, angular, app, routes, domReady) {
    return domReady(function() {
      return angular.bootstrap(document, ['myapp']);
    });
  });

}).call(this);
