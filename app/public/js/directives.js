(function() {
  define(['angular', 'controllers', 'underscore', 'jquery'], function(angular, controllers, _, $) {
    return angular.module('myapp.directives', ['myapp.controllers', 'myapp.services']).directive('newFilter', function() {
      return {
        restrict: 'EA',
        scope: true,
        templateUrl: 'views/partials/newfilter.html',
        controller: 'NewFilterCtrl'
      };
    }).directive('stopEvent', function() {
      return {
        restrict: 'A',
        link: function(scope, element, attr) {
          return element.bind(attr.stopEvent, function(e) {
            return e.stopPropagation();
          });
        }
      };
    }).directive('buttonOk', function($timeout) {
      return {
        restrict: 'A',
        scope: {
          question: "=buttonOk",
          target: "=",
          filterAdded: "="
        },
        link: function(scope, elem) {
          return $timeout(function() {
            var addedFilter, targetIds;
            targetIds = _.pluck(scope.question.targets, '_id');
            addedFilter = _.find(targetIds, function(id) {
              return id === scope.target._id;
            });
            if (addedFilter) {
              return scope.filterAdded = true;
            }
          }, 100, true);
        }
      };
    }).directive('answered', function($timeout) {
      return {
        restrict: "A",
        scope: {
          answered: "=",
          submitted: "="
        },
        link: function(scope) {
          return $timeout(function() {
            if (scope.answered) {
              return scope.submitted = true;
            }
          }, 500, true);
        }
      };
    }).directive('favorited', function($timeout, User) {
      return {
        restrict: "A",
        scope: {
          question: "=favorited",
          favorite: "="
        },
        link: function(scope) {
          return $timeout(function() {
            var favoriteQuestion;
            if (scope.question !== void 0 && User.user) {
              favoriteQuestion = _.find(User.user.favorites, function(id) {
                return id === scope.question._id;
              });
            }
            if (favoriteQuestion) {
              return scope.favorite = true;
            }
          }, 100, true);
        }
      };
    }).directive('focusMe', function($timeout) {
      return {
        restrict: "A",
        scope: {
          focusMe: "="
        },
        link: function(scope, element) {
          return $timeout(function() {
            return element.bind('focus', function() {
              return scope.$apply(scope.focusMe = true);
            });
          }, 300, true);
        }
      };
    }).directive("toggle", function($timeout, $window) {
      return {
        restrict: "A",
        scope: {
          order: "=",
          category: "="
        },
        link: function(scope, element, attr) {
          var w;
          w = angular.element($window);
          return w.bind("click", function(e) {
            if (e.target.id === "order-toggler" || e.target.id === "order-icon") {
              return scope.$apply(scope.category = false);
            } else if (e.target.id === "category-toggler" || e.target.id === "category-icon") {
              return scope.$apply(scope.order = false);
            } else {
              scope.$apply(scope.order = false);
              return scope.$apply(scope.category = false);
            }
          });
        }
      };
    }).directive("getSize", function($timeout) {
      return {
        restrict: "A",
        scope: {
          getSize: "="
        },
        link: function(scope, elem) {
          return $timeout(function() {
            scope.getSize.height = elem[0].offsetHeight;
            return scope.getSize.width = elem[0].offsetWidth;
          }, 300, true);
        }
      };
    }).directive("disableEnter", function() {
      return function(scope, element, attrs) {
        return element.bind("keydown keypress", function(event) {
          if (event.which === 13) {
            return event.preventDefault();
          }
        });
      };
    }).directive('noScopeRepeatForGrid', function($compile, $templateCache) {
      return {
        link: function(scope, elem, attrs) {
          return scope.$watch(attrs.items, function(items) {
            var template;
            if (items) {
              template = $templateCache.get("question.html");
              return items.forEach(function(val, key) {
                var newElement;
                newElement = angular.element(template.replace(/#OBJ#/g, attrs.items + '[' + key + ']'));
                $compile(newElement)(scope);
                return elem.append(newElement);
              });
            }
          });
        }
      };
    }).directive('noScopeRepeatForTargets', function($compile, $templateCache) {
      return {
        link: function(scope, elem, attrs) {
          return scope.$watch(attrs.items, function(items) {
            var template;
            if (items) {
              template = $templateCache.get('targetQuestion.html');
              return items.forEach(function(val, key) {
                var closing, newElement, newTemplate, starting;
                starting = "<div class=\"content animated fadeInLeft\" ng-show=\"" + key + "==filterNumber\">";
                closing = "	<form ng-controller=\"TargetListCtrl\" ng-submit=\"submitTarget(card,targetAnswer," + key + ")\"> <ul no-scope-repeat-for-targets-options items=\"#OBJ#.lists\" class=\"answers\"></ul> <input type=\"submit\" class=\"submit-button btn btn-primary btn-sm\" value=\"Next\"> </form> </div>";
                newTemplate = starting.concat(template, closing);
                newElement = angular.element(newTemplate.replace(/#OBJ#/g, attrs.items + '[' + key + ']'));
                $compile(newElement)(scope);
                return elem.append(newElement);
              });
            }
          });
        }
      };
    }).directive('noScopeRepeatForTargetsOptions', function($compile, $templateCache) {
      return {
        link: function(scope, elem, attrs) {
          return scope.$watch(attrs.items, function(items) {
            var template;
            if (items) {
              template = $templateCache.get('targetQuestion-options.html');
              return items.forEach(function(val, key) {
                var newElement;
                newElement = angular.element(template.replace(/#OBJ#/g, attrs.items + '[' + key + ']'));
                $compile(newElement)(scope);
                return elem.append(newElement);
              });
            }
          });
        }
      };
    }).directive('noScopeRepeatForCounts', function($compile, $templateCache) {
      return {
        link: function(scope, elem, attrs) {
          return scope.$watch(attrs.items, function(items) {
            var template;
            if (items) {
              template = $templateCache.get('result.html');
              return items.forEach(function(val, key) {
                var newElement;
                newElement = angular.element(template.replace(/#OBJ#/g, attrs.items + '[' + key + ']'));
                $compile(newElement)(scope);
                return elem.append(newElement);
              });
            }
          });
        }
      };
    });
  });

}).call(this);
