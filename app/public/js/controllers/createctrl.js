(function() {
  define(['underscore'], function(_) {
    return function($scope, $modalInstance, $location, $timeout, Filters, Question, User, Page, $state, $stateParams, $q, Debounce) {
      var findSameOption, message, newQuestion, targets, utility;
      findSameOption = function(item) {
        if (item.title === newQuestion.newOption) {
          return true;
        } else {
          return false;
        }
      };
      targets = $scope.targets = Filters.get({
        offset: Page.filterPage
      });
      newQuestion = $scope.question = {
        newOption: "",
        question: "",
        category: "0",
        respondents: [],
        favorite: false,
        favoritedBy: [],
        numOfFilters: 0,
        totalResponses: 0,
        alreadyAnswered: false,
        created_at: Date,
        option: [],
        targets: [],
        creator: null,
        photo: ""
      };
      $scope.showDetails = false;
      $scope.outOfFilters = false;
      $scope.loadData = "Load more data";
      $scope.searchText = '';
      message = $scope.message = {
        questionNotFound: "",
        optionsNotEnough: "",
        categoryNotChosen: ""
      };
      utility = $scope.utility = {
        isOptionAdded: false,
        isSameOptionFound: false,
        isQuestionFound: false,
        isCategoryChosen: false,
        areOptionsEnough: false,
        readyToMakeNewFilter: false,
        isCreatingQuestion: true,
        isQuestionCreated: false,
        isQuestionCompleted: false
      };
      $scope.downloadFilters = function() {
        $scope.loadData = "...Loading data";
        Page.filterPage += 6;
        return Filters.get({
          offset: Page.filterPage
        }).$promise.then(function(data) {
          var newlyDownloaded;
          newlyDownloaded = data;
          if (newlyDownloaded.length === 0 || _.isUndefined(newlyDownloaded)) {
            return $scope.loadData = "No more data";
          } else {
            newlyDownloaded.forEach(function(val, key) {
              return $scope.targets.push(val);
            });
            return $scope.loadData = "Load more data";
          }
        });
      };
      $scope.searching = function() {
        return console.log('test');
      };
      $scope.searchFilter = Debounce($scope.searching, 333, false);
      $scope.closeModal = function() {
        $scope.$dismiss();
        $location.path('/');
        return $timeout(function() {
          return $state.transitionTo($state.current, $stateParams, {
            reload: true,
            inherit: true,
            notify: true
          });
        }, 500, true);
      };
      $scope.createOption = function(option) {
        var newlyCreatedOption, sameOptionFound;
        sameOptionFound = _.find(newQuestion.option, findSameOption);
        if (option === "" || !option) {
          return false;
        } else if (sameOptionFound) {
          utility.isSameOptionFound = true;
        } else {
          newlyCreatedOption = {
            title: option,
            count: 0,
            answeredBy: []
          };
          newQuestion.option.push(newlyCreatedOption);
          utility.isOptionAdded = true;
          utility.isSameOptionFound = false;
          $timeout(function() {
            return utility.isOptionAdded = false;
          }, 500, true);
        }
        return newQuestion.newOption = '';
      };
      $scope.removeOption = function(index) {
        return newQuestion.option.splice(index, 1);
      };
      $scope.openCreateFilterBox = function() {
        return utility.readyToMakeNewFilter = !utility.readyToMakeNewFilter;
      };
      $scope.submitQuestion = function() {
        var chosen;
        if (newQuestion.question !== "") {
          utility.isQuestionFound = true;
          message.questionNotFound = "";
        } else {
          newQuestion.question;
          utility.isQuestionFound = false;
          message.questionNotFound = "Please finish making a question";
        }
        if (_.size(newQuestion.option) >= 2) {
          utility.areOptionsEnough = true;
          message.optionsNotEnough = "";
        } else {
          utility.areOptionsEnough = false;
          message.optionsNotEnough = "Please make at least two options";
        }
        if (newQuestion.category !== "0") {
          chosen = utility.isCategoryChosen = true;
          message.categoryNotChosen = "";
        } else {
          utility.isCategoryChosen = false;
          message.categoryNotChosen = "Please choose a category";
        }
        if (utility.isQuestionFound && utility.areOptionsEnough && utility.isCategoryChosen) {
          utility.isQuestionCreated = true;
          return utility.isCreatingQuestion = false;
        } else {
          return false;
        }
      };
      $scope.completeQuestion = function() {
        newQuestion.question = "Which one ".concat(newQuestion.question);
        newQuestion.numOfFilters = _.size(newQuestion.targets);
        newQuestion.created_at = new Date().getTime();
        newQuestion.photo = User.profilePic;
        newQuestion.creatorName = User.profilePic;
        newQuestion.creator = User._id;
        Question.save(newQuestion);
        utility.isQuestionCreated = false;
        return utility.isQuestionCompleted = true;
      };
      $scope.backToCreateQuestion = function() {
        utility.isCreatingQuestion = true;
        return utility.isQuestionCreated = false;
      };
      $scope.backToTargetAudience = function() {
        utility.isQuestionCompleted = false;
        return utility.isQuestionCreated = true;
      };
      return $scope.$apply();
    };
  });

}).call(this);
