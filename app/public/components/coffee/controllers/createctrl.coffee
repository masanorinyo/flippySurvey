define ['underscore'], ( _ )->
	($scope,$modalInstance,$location,$timeout,Filters,Question,User,Page,$state,$stateParams,$q,Debounce)->
		
		# --------------------- Functions for utility --------------------- #
		
		findSameOption = (item)->
			
			if item.title == newQuestion.newOption then true else false

						
		# ----------------- Scope functions and variables ----------------- #
		
		# ***************  models *************** #


		targets = $scope.targets = Filters.get({offset:Page.filterPage})

		newQuestion = $scope.question = 
			newOption 			: ""
			question 			: ""
			category 			: "0"
			respondents 		: []
			favorite 			: false
			favoritedBy 		: []
			numOfFilters		: 0
			totalResponses 		: 0
			alreadyAnswered 	: false
			created_at 			: Date
			option				: []
			targets 			: []
			creator 			: null
			photo				: ""

	
		

		# *************** variables  *************** #
		
		# If true, this will show the details of a filter
		$scope.showDetails 		= false

		# if true, infinite scroll will be disabled
		$scope.outOfFilters = false

		$scope.loadData = "Load more data"

		$scope.searchText = ''

		# warning messages
		message = $scope.message = 

			questionNotFound		: ""
			optionsNotEnough 		: ""
			categoryNotChosen 		: ""


		utility = $scope.utility =

			# This will handle warning message
			
			isOptionAdded 		: false
			isSameOptionFound  	: false
			isQuestionFound 	: false
			isCategoryChosen 	: false
			areOptionsEnough	: false
			
			# If true, box for making a new filter shows up
			readyToMakeNewFilter: false
			
			# This will switch around modal sections
			isCreatingQuestion  : true
			isQuestionCreated	: false
			isQuestionCompleted	: false

		

		# *************** functions *************** #
		
		$scope.downloadFilters = ()->
			
			$scope.loadData = "...Loading data"
			Page.filterPage += 6			
			
			Filters.get({offset:Page.filterPage}).$promise
				.then (data)-> 
					
					newlyDownloaded = data
					
					if newlyDownloaded.length == 0 or _.isUndefined(newlyDownloaded)
						
						$scope.loadData = "No more data"
					else 
						
						newlyDownloaded.forEach (val,key)->
							
							$scope.targets.push(val)
						
						$scope.loadData = "Load more data"
			

		$scope.searching = ->
			console.log 'test'

		$scope.searchFilter = Debounce($scope.searching, 333, false);
			
			
  
  
  




			
			
			

			
			

		

		# -- applies to all modal sections --#
		
		$scope.closeModal = ()->

			
			$scope.$dismiss()
			$location.path('/')

			$timeout ->
				
				
				# reload the page
				$state.transitionTo($state.current, $stateParams, {
					reload: true
					inherit: true
					notify: true
				})

			,500,true

		
		# -- for create question section --#
		
		#this will create option
		$scope.createOption	= (option)->


			# check to see if the same option is present
			sameOptionFound = _.find(newQuestion.option,findSameOption)
			
			# check if newly created option is empty and the same option is found
			if option is "" or !option

				return false

			else if sameOptionFound 
				
				utility.isSameOptionFound = true 
			
			else 

				# newly created option meets the above conditions, added to the question
				newlyCreatedOption = 
					title 		: option
					count 		: 0
					answeredBy 	: []



				newQuestion.option.push(newlyCreatedOption)
				utility.isOptionAdded = true
				utility.isSameOptionFound = false 
				
				# resetting for another option
				$timeout ->
					utility.isOptionAdded = false
				,500,true

			# clears out the input
			newQuestion.newOption = ''

		# this will remove option
		$scope.removeOption = (index)->

			newQuestion.option.splice(index,1)
			
			
			
		# this will open the box for creating a new filter
		$scope.openCreateFilterBox = ()->

			utility.readyToMakeNewFilter = !utility.readyToMakeNewFilter


		# -- actions taken by confirmation buttons --#

		# this checks if the conditions for making a new question is made or not
		$scope.submitQuestion = ()->
			
			# whether question is made or not
			if newQuestion.question != ""
				
				utility.isQuestionFound  = true
				message.questionNotFound = ""
				
			else
				newQuestion.question
				utility.isQuestionFound  = false
				message.questionNotFound = "Please finish making a question"
			

			# whether more than 2 option are chosen or not
			if _.size(newQuestion.option) >= 2
								
				utility.areOptionsEnough = true	
				message.optionsNotEnough = ""
			
			else 
				utility.areOptionsEnough = false
				message.optionsNotEnough = "Please make at least two options"
			

			# whether category is chosen or not
			if newQuestion.category != "0"

				chosen = utility.isCategoryChosen = true
				message.categoryNotChosen = ""

			else 
				utility.isCategoryChosen  = false
				message.categoryNotChosen = "Please choose a category"

			# enough the above conditions are all true, then section changes
			if 	utility.isQuestionFound and utility.areOptionsEnough and utility.isCategoryChosen
				
				# section changes
				utility.isQuestionCreated 	= true
				utility.isCreatingQuestion 	= false

			else 

				false
				

		# This will convert the temporary question into an actual question
		$scope.completeQuestion = ()->
			
			newQuestion.question = "Which one ".concat(newQuestion.question)

			# get the number of added target audience questions
			newQuestion.numOfFilters = _.size(newQuestion.targets)

			# get the current time
			newQuestion.created_at = new Date().getTime()			

			newQuestion.photo = User.profilePic
			newQuestion.creatorName = User.profilePic
			newQuestion.creator = User._id


			# $scope.question.unshift(newQuestion)
			Question.save(newQuestion)


			utility.isQuestionCreated 		= false
			utility.isQuestionCompleted 	= true			


		# -- actions taken by back buttons --#

		$scope.backToCreateQuestion = ()->
			
			utility.isCreatingQuestion 	= true
			utility.isQuestionCreated 	= false

		$scope.backToTargetAudience = ()->
			
			utility.isQuestionCompleted = false
			utility.isQuestionCreated 	= true

		

			

		# --- invoke the scope --- #
		
		$scope.$apply()


