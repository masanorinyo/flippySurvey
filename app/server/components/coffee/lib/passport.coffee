# --------------------------------------------#
# ------------ load dependencies ------------ #
# --------------------------------------------#
LocalStrategy = require("passport-local").Strategy
FacebookStrategy = require("passport-facebook").Strategy
TwitterStrategy = require("passport-twitter").Strategy
GoogleStrategy = require("passport-google-oauth").OAuth2Strategy

# -- model
User = require("../models/user")
configAuth = require("../config/oauth")

# email verification
verification = require("./verification")

# --------------------------------------------#
# ------------ load dependencies ------------ #
# --------------------------------------------#

#make user's name unique by concatenating a number to the name
#once the name becomes unique, callback function
uniqify_name = (name, num, callback) ->
	User.findOne
		
			"name": name
	 
	, (err, user) ->
			if err
				throw err
			
			else if user
			
				stringNum = num.toString()
				name = name.concat(stringNum)
				num++
				uniqify_name(name,num,callback)
			else
				callback(name)
				 

# --------------------------------------------#
# ------------  exports modeul   ------------ #
# --------------------------------------------#

module.exports = (passport) ->
	
	#--serialize users for persistent login sessions--//
	passport.serializeUser (user, done) ->
		done(null, user.id)
		
	 #--deserialize users out of session--//
	passport.deserializeUser (id, done) ->
			User.findById(id, (err, user) ->
				done(err, user)
			)
	

	 # ========== Local Login ========== #
	passport.use "local-login", new LocalStrategy(
				 
		usernameField: "email"
		passwordField: "password"
		passReqToCallback: true
		
		, (req, email, password, done) ->
			 
			process.nextTick ->
				User.findOne
				
					"local.email": email
				
				, (err, user) ->
					
					if err
					
						done err
					
					else unless user
					
						req.session.message = "No user found"
						done null, false, req.session.message
					
					else unless user.validPassword(password)
					
						req.session.message = "Wrong password"
						done null, false, req.session.message
					
					else
							
						user.visitorId.unshift(req.body.visitorId)
						user.save (err,readyUser)->
							if err 
								throw err 
							else 
								done null, user
	)
	 # ========== Local Signup ========== #
	 
	passport.use "local-signup", new LocalStrategy(
		
		#Overwrites the default usernameField with email
		usernameField: "email"
		passwordField: "password"
				
		#This will allow in checking if a user is logged in
		#(passes user data in the req from the router)
		passReqToCallback: true
		
		, (req, email, password, done) ->
			 
			#clears out the session message
			req.session.message = ""
			 
			process.nextTick ->
				User.findOne
					 
					"local.email": email
				
				, (err, user) ->
					if err
					 
						done(err)
					 
					else if user
							
						req.session.message = "That Email is already taken"
						done(null, false, req.session.message)
					 
					else

						# create a new user if there are no error and 
						# a user already using the Email in the process

						#get a name from Email
						nameMatch = email.match(/^([^@]*)@/)
						name = (if nameMatch then nameMatch[1] else null)

						#if name is successfully extracted from email
						if name


							callback = (name) ->
							 
								newUser = new User()

								newUser.username = name
								newUser.email = email
								newUser.visitorId.push(req.body.visitorId)
								newUser.profilePic = "/img/users/default_img.png"

								# Stores email and hashed password into a new user variable.
								newUser.local.email = email
								newUser.local.password = newUser.generateHash(password)

								#once users verify the account by clicking the link provided 
								#in the verification Email, this will become true
								newUser.confirmed = false

								#when users sign up with their twitter account
								#they need to submit their email separately
								newUser.hasEmail = true
								
								newUser.save (err, user) ->
									if err
											
										done(err)

									else

										verification.sendVerification(req, newUser, email)
										done(null, newUser)

							#check if there is any user already using the name
							#if any user with the same name, concatenate with a number
							#untill the name becomes unique
							#once the name becomes unique, then the user information will be saved with the callback function.
							uniqify_name(name, 1, callback)

						else
												
							done(null)

	)
	
	# #========================== Facebook ==========================//
	# #*********** Signup & Login ***********//
	passport.use "facebook", new FacebookStrategy(
		clientID: configAuth.facebookAuth.clientID
		clientSecret: configAuth.facebookAuth.clientSecret
		callbackURL: configAuth.facebookAuth.callbackURL
		
		#This will allow in checking if a user is logged in
		#(passes user data in the req from the router)
		passReqToCallback: true
	, (req, token, refreshToken, profile, done) ->
		process.nextTick ->
			
			userId = profile.id
			picUrl = "https://graph.facebook.com/" + userId + "/picture"
			
			# when the user is not logged in
			User.findOne
				"facebook.id": profile.id
			, (err, user) ->
				if err
					done err
				else if user
					
					done null, user
				else
					

					# if there is no user with facebook account
					# create a new user
					newUser = new User()
					newUser.facebook.id = profile.id
					newUser.facebook.token = token
					newUser.username = profile.name.givenName + " " + profile.name.familyName
					newUser.email = profile.emails[0].value
					newUser.profilePic = picUrl
					
					#once users verify the account by clicking the link provided 
					#in the verification Email, this will become true
					newUser.confirmed = false
					
					#when users sign up with their twitter account
					#they need to submit their email separately
					newUser.hasEmail = true
					newUser.save (err, user) ->
						if err
							done err
						else
							
							#log user's signup activity
							verification.sendVerification req, newUser, newUser.email
							done null, newUser



	)
	
	
	# #========================== Twitter Login ==========================//
	#*********** Signup & Login ***********//
	passport.use "twitter", new TwitterStrategy(
		consumerKey: configAuth.twitterAuth.consumerKey
		consumerSecret: configAuth.twitterAuth.consumerSecret
		callbackURL: configAuth.twitterAuth.callbackURL

		#This will allow in checking if a user is logged in
		#(passes user data in the req from the router)
		passReqToCallback: true
	, (req, token, tokenSecret, profile, done) ->
		process.nextTick ->

		# check if the user is already logged in
		User.findOne
			"twitter.id": profile.id
		, (err, user) ->
			if err
			
				done err
			
			else if user
				
				done null, user
			
			else
				console.log "twitter user : Nothing was found"

				# if there is no user, create them
				newUser = new User()

				#sends confirmation email
				newUser.twitter.id = profile.id
				newUser.twitter.token = token
				newUser.twitter.tokenSecret = tokenSecret
				newUser.username = profile.displayName.replace(/\s/g, "-")
				newUser.profilePic = profile.photos[0].value

				#When users submit the reset password form,
				#this will become true.
				newUser.confirmed = false

				#when users sign up with their twitter account
				#they need to submit their email separately
				newUser.hasEmail = false
				newUser.save (err) ->
					if err
						done err
					else
						done null, newUser

		
		
	)
	
	
	
	# #========================== Google+ Login ==========================//
	# #*********** Signup & Login ***********//
	passport.use "google", new GoogleStrategy(
		clientID: configAuth.googleAuth.clientID
		clientSecret: configAuth.googleAuth.clientSecret
		callbackURL: configAuth.googleAuth.callbackURL

		#This will allow in checking if a user is logged in
		#(passes user data in the req from the router)
		passReqToCallback: true
	, (req, token, refreshToken, profile, done) ->
		
		# asynchronous
		process.nextTick ->
			
		# check if the user is already logged in
		# unless req.user
		User.findOne
			"google.id": profile.id
		, (err, user) ->
			
			if err
			
				done err
			
			else if user

				done null, user

			else
					
				# if there is no user, create them
				newUser = new User()

				#sends confirmation email
				newUser.google.id = profile.id
				newUser.google.token = token
				newUser.username = profile.displayName.replace(/\s/g, "-")
				newUser.email = profile.emails[0].value # pull the first email
				newUser.profilePic = profile._json.picture
				

				#When users submit the reset password form,
				#this will become true.
				newUser.confirmed = false

				#when users sign up with their twitter account
				#they need to submit their email separately
				newUser.hasEmail = true
				
				newUser.save (err, user) ->
					if err
						done err
					else
						verification.sendVerification req, newUser, newUser.email
						done null, newUser


	)
