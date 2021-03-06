define [], ()->
	(
		$scope
		$modalInstance
		$stateParams
		$location
		$timeout
		Setting
		Question
	)->
		
		link = ''
		sharableLink = ''
		lists = ''
		question = ''

		do ()->
			# when accessed from setting page
			if Setting.isSetting
				$scope.questionId = Setting.questionId
			else 
				$scope.questionId = $stateParams.id
			


			link = window.location.origin
			
			sharableLink = $scope.sharableLink = link.concat("/#/question/",$scope.questionId)

			$scope.showShareForm = false



		$scope.closeModal = ()->
			
			$scope.$dismiss()


		
		Question.get({questionId:$scope.questionId}).$promise.then (data)->
		
			question = data.question.concat("\n")
			_.each data.option, (option,index)->
				bullet = "["+index+"] - "
				lists = lists.concat(bullet,option.title,"\n")
		
		.then (data)->
			#  twitter link
			text = question + " - "+sharableLink
			text = escape(text)
			$scope.twitterShareText = 'https://twitter.com/intent/tweet?text='+text
			$scope.googleShareText = "https://plus.google.com/share?url="+sharableLink
			$scope.showShareForm = true
		
		$scope.shareFacebook = ->
			
			FB.ui(
		    	
		        method: 'feed',
		        name: question
		        link: sharableLink
		        picture: "http://polligrid.com/img/icon.png"
		        caption: "PolliGrid lets you analyze people's optinions from different angles"
		        description:lists 
		        message: ''
		    )

		

		$scope.$apply()


