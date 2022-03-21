application chitter


imports models
imports pages
imports pageutils


principal is User with credentials username, password

access control rules
  rule page root{ true }
  rule page feed{ loggedIn() }
  rule page search{ loggedIn() }
  rule page userProfile(user: User) { loggedIn() }

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
