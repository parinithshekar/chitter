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
			registrationTemplate
		}
	}
}


override template login {
	var username : String
	var password : Secret
	var stayLoggedIn := false
	form {
		<fieldset>
		<legend>
			output( "Login" )
		</legend>
		<table>
			<tr>labelcolumns( "Username: " ){ input( username ) }</tr>
			<tr>labelcolumns( "Password: " ){ input( password ) }</tr>
			<tr>labelcolumns( "Stay logged in: " ){ input( stayLoggedIn ) } </tr>
		</table>
		submit signinAction() { "Login" }
		</fieldset>
	}
	action signinAction {
		getSessionManager().stayLoggedIn := stayLoggedIn;
		validate( authenticate( username, password ), "The login credentials are not valid.");
//		message( "You are now logged in." );
		return feed();
	}
}
