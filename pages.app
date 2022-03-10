module pages

imports pageutils
imports models

template default {
	main {		
		navbar
		div[class="container is-max-desktop"] {
			elements
		}
	}
}

template loggedInMessage {
	div[class="is-size-2"]{
		"You are logged in ~securityContext.principal.username!"
		<br>
		"Go to " navigate feed() {"your feed"} " or " navigate search() {"search for users"}
	}
}

template registrationTemplate {
	h3{ "Registration" }
	var newuser := User{}
	form {
		input( newuser.username )
		input( newuser.password )
		input( newuser.super )
		submit action{
			newuser.password := newuser.password.digest();
			newuser.save();
		}{ "Register" }
	}
}

page feed {
	default {	
		cheetIntro	
		cheetForm
		cheetFeed
	}
}

template navbarWith {
	div[class="navbar is-light"] {
		div[class="container is-max-desktop"] {
			div[class="navbar-contents"] {
				div[class="all-centered"]{
					i[class="fa-solid fa-feather-pointed fa-2x"]
					span[class="has-text-centered has-text-weight-semibold"] { "Chitter" }
				}
				div[class="all-centered"]{
					elements	
				}
			}
		}
	}
}

template navbar {
	if(!loggedIn()) {
		navbarWith
	} else {
		navbarWith {
			navigate feed()[class="white"] {
				i[class="fa-brands fa-earlybirds fa-2x"]
			}
			navigate search()[class="white"] {
				i[class="fa-solid fa-magnifying-glass fa-2x"]
			}
			form {
				submitlink signOffAction(){
					i[class="fa-solid fa-arrow-right-from-bracket fa-2x"]
				}
			}
		}
	}
	action signOffAction{
		logout();
		return root();
	}
}

template cheetIntro {
	div[class="block is-size-3"]{
		"Post a cheet "
		span[class="has-text-info"]{
			"@~securityContext.principal.username"
		}
	}
}

template cheetForm {
	var cheet := Cheet{}
	div[class="block"]{
		form {
			div[class="field"]{
				div[class="control"]{
					input( cheet.message )[class="textarea", placeholder="Unpopular opinion: K3G is boring"]
				}
			}
			submit action{
				cheet.author := securityContext.principal;
				cheet.save();
			}{ "Send Cheet" }
		}
	}
}

template cheetFeed {
	var cheets : {Cheet}
	init {
		cheets.addAll(principal.cheets);
		for (f in [ f.cheets | f in principal.following]) {
			cheets.addAll(f);
		}
	}
	div[class="block"]{
		"cheet feed"
	}
}

template cheet() { "cheet" }

page search {
	default {
		searchForm
		searchResults
	}
}

template searchForm { "search form" }

template searchResults { "search results" }