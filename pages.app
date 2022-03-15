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
					navigate feed() {						
						i[class="fa-brands fa-twitter fa-2x"]
						span[class="has-text-centered has-text-weight-semibold"] { "Chitter" }
					}
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
			navigate userProfile(principal)[class="white"] {
				i[class="fa-solid fa-user fa-2x"]
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
		navigate userProfile(principal) {
			span[class="has-text-info"]{
				"@~securityContext.principal.username"
			}
		}
	}
}

template cheetForm {
	var cheet := Cheet{}
	div[class="block"]{
		form {
			div[class="field cheet-form"]{
				div[class="control cheet-textarea"]{
					input( cheet.message )[class="textarea", rows="3", placeholder="What's going on?"]
				}
				div[class="control cheet-submit-button all-centered"]{
						submit action{
						cheet.author := securityContext.principal;
						cheet.save();
					}[class="button is-info is-rounded"] {
							"+ "
							i[class="fa-solid fa-feather-pointed"]
					 }
				}
			}
			
		}
	}
}

template cheetFeed {
	var recheets : [Recheet]
	div[class="block cheet-feed"]{
		displayCheets(recheets)
	}
	init {
		// cheets.addAll(principal.cheets);
		// Use Recheet entity schema as a temporary dict
		
		// Base cheeters to get cheets from are users the principal is following and super users
		var cheeters : {User};
		cheeters.addAll(principal.following);
		cheeters.addAll((from User as u where u.super = true));
		for (cs in [ f.cheets | f in cheeters]) {
			recheets.addAll([Recheet{ cheet := cheet rcer := null} | cheet in cs]);
		}
		for (rc in (from Recheet as rc where rc.rcer in ~cheeters and rc.cheet.author not in ~cheeters)) {
			recheets.add(rc);
		}
	}
}

template displayCheets(recheets: [Recheet]) {
	for(recheet in recheets order by recheet.cheet.created desc) {
		cheetTemplate(recheet)
	}
}

template cheetTemplate(recheet: Recheet) {
	// TODO: improve what information to show on cheets
	div[class="card"]{
		div[class="card-content"]{
			navigate userProfile(recheet.cheet.author) {
				div[class="subtitle has-text-weight-semibold"]{
					"@~recheet.cheet.author.username"
				}
			}
			div[class="subtitle"]{
				~recheet.cheet.message
			}
			div[class="subtitle recheet-section"]{
				recheetedBySection(recheet.rcer)
				recheetSection(recheet.cheet)
			}
		}
	}
}

template recheetedBySection(user: User) {
	if (user != null ) {
		div[class="subtitle has-text-weight-light has-text-grey-light no-bottom-margin"] {
			"Recheeted by "
			navigate userProfile(user) {
				span{
					"@~user.username"
				}
			}
		}
	} else {
		div[class="subtitle has-text-weight-light has-text-grey-light no-bottom-margin"] {
			""
		}
	}
}

template recheetSection(cheet: Cheet) {
	var rcCount := (from Recheet as rc where rc.cheet = ~cheet).length
	var hasRecheeted := ((from Recheet as rc where rc.rcer = ~principal and rc.cheet = ~cheet).length > 0)
	if (cheet.author == principal || hasRecheeted) {
		div[class="recheet-button has-text-black"]{
			"~rcCount "
			i[class="fa-solid fa-retweet"]
		}
	} else {
		submitlink recheetAction()[class="recheet-button has-text-info"] {
			"~rcCount "
			i[class="fa-solid fa-retweet"]
		}
	}
	action recheetAction() {
		Recheet{ rcer := principal cheet := cheet}.save();
	}
}

// TODO: fix search based on username
page search {
	request var query := ""
	default {
		div[class="block field search-form"]{
			div[class="control"]{
				form {
					input ( query )[
						class="input",
						type="text",
						placeholder="Search by username",
						oninput = action{
							replace( results );
						},
						onsubmit = action{
							replace( results );
						}
					]
				}
			}
		}
		div[class="block search-results"] {			
			placeholder results {
				if (query != "") {
					// TODO: fix search
					for ( u in
						[ u | u in (from User)
							where
							(!principal.sameUser(u) &&
							u.username.toLowerCase().contains(query.toLowerCase()))
						]
					) {
						searchResultUser(u)
					}
					
					/*
					for (u in (results from search User matching query)) {
						searchResultUser(u)
					}
					*/
				}
			}
		}
	}
}

template searchResultUser(user: User) {
	navigate userProfile(user) {		
		div[class="card"] {
			div[class="card-content"] {
				div[class="subtitle user-name"] {
					"@~user.username"
				}
			}
		}
	}
}

page userProfile(user: User) {
	default {
		userIntro(user)
		userCheetFeed(user)
	}
}

// TODO: add follow button
template userIntro(user: User) {
	div[class="block is-size-3 user-intro"]{
		div[class="has-text-info"]{
			"@~user.username's cheets"
		}
		div[class="subtitle user-follow-button"]{
			followButtonTemplate(user)
		}
	}
}

template userCheetFeed(user: User) {
	var recheets : [Recheet]
	div[class="block cheet-feed"]{
		displayCheets(recheets)
	}
	init {
		// Use Recheet entity schema as a temporary dict 
		// TODO: improve how to fetch cheets
		recheets.addAll([Recheet{ cheet := cheet rcer := null} | cheet in user.cheets]);
		recheets.addAll((from Recheet as rc where rc.rcer = ~user));
	}
}

template followButtonTemplate(user: User) {
	if (principal.sameUser(user)) {
		""
	}
    else if (user in principal.following) {
        submitlink unfollowAction()[class="button is-danger is-light is-rounded"] {
            "Unfollow"
        }
    } else {
        submitlink followAction()[class="button is-info is-rounded"] {
            "Follow"
        }
    }
    action followAction() {
        principal.following.add(user);
    }
    action unfollowAction() {
        principal.following.remove(user);
    }
}
