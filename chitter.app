application chitter


imports models
imports pages
imports pageutils
imports services


principal is User with credentials username, password

access control rules

	// pages
	rule page root{ true }
	rule page feed{ loggedIn() }
	rule page search{ loggedIn() }
	rule page userProfile(user: User) { loggedIn() }
  
	// services
	rule page userLogin() { true }
	rule page userRegister() { true }
	rule page userLogout() { loggedIn() }
	rule page currentUser() { loggedIn() }
	rule page postCheet() { loggedIn() }
	rule page feedCheets() { loggedIn() }
	rule page recheet(cheet: Cheet) { loggedIn() }
	rule page users() { loggedIn() }
	rule page userInfo(user: User) { loggedIn() }
	rule page follow(user: User) { loggedIn() }
	rule page unfollow(user: User) { loggedIn() }

section rootPage

page root {
	// authentication
	default {
		if(loggedIn()){
			loggedInMessage
		}
		else {
			login
			<hr>
			registrationTemplate
		}
	}
}
