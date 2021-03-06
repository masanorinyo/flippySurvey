define ['underscore'], ( _ )->
	($scope,$timeout,$q,Filters,Question)->
		
		# --------------------- utility functions --------------- #
		
		findSameOption = (item)->
			
			if item == filterUtil.newList then true else false


		# --------------------- scope variables --------------- #

		filterUtil = $scope.filterUtil = 
			newList 	 			: ""
			sameListFound 			: false
			isNotFilledOut 			: false

		newFilter = $scope.newFilter = 
			id 				: null
			title 			: ""
			question 		: ""
			lists 			: []
			created_at	 	: Date
			

		# --------------------- scope functions --------------- #
		
		$scope.addNewList = (list)->
			
			
			
			sameOptionFound = _.find newFilter.lists,(data)->
				data.option == list


			if list is "" or !list

				return false

			else if sameOptionFound 
				
				filterUtil.sameListFound = true 
			
			else
				
				# create a list option
				data = 
					option 		:list
					answeredBy	:[]

				# store it into the list
				newFilter.lists.push(data)
				filterUtil.newList = ""
				filterUtil.sameListFound = false

		$scope.submitNewFilter = (newFilter)->
			
			enoughOptions = false

			if _.size(newFilter.lists) >= 2
				
				enoughOptions = true

			else

				filterUtil.isNotFilledOut = true


			if newFilter.title is "" or !newFilter.title
				
				filterUtil.isNotFilledOut = true
			
			else if newFilter.question is "" or !newFilter.question

				filterUtil.isNotFilledOut = true	

			else if enoughOptions


				filterUtil.isNotFilledOut 	= false	
				
				#clone the newly created filter
				clone_newFilter = angular.copy(newFilter)
				clone_newFilter.created_at = new Date().getTime()


				defer = $q.defer()

				newlySavedFilter = null
				defer.promise
					
					# Save the newly created filter into database
					.then -> 
					
						_.each clone_newFilter.lists, (list)->
							list.option = escape(list.option)
							console.log list.option 
					
					.then ->

						newlySavedFilter = Filters.save(clone_newFilter)
										
					# unescape and retrieve it from it.
					.then -> 
						_.each clone_newFilter.lists, (list)->
							list.option = unescape(list.option)
							console.log list.option 
					.then ->

						$scope.targets.unshift(newlySavedFilter)
						

				defer.resolve()
										
				
				#clean up after submitting the data					
				newFilter.title 			= ""
				newFilter.question  		= ""
				newFilter.lists 			= []

				#this will hide the filter creation box
				$scope.utility.readyToMakeNewFilter = false
				

		$scope.removeList = (index)->
			newFilter.lists.splice(index,1)

		$scope.cancelToMakeFIlter = ()->
			$scope.utility.readyToMakeNewFilter = false	

		$scope.$apply()


