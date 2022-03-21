module models

entity User {
	username: String (name, id)
	password: Secret
	super: Bool
	cheets: {Cheet} (inverse = author)
	followers: {User}
	following: {User} ( inverse = followers )
	predicate sameUser( u: User ){ this == u }
	
	predicate isFollowing( user: User ){ user in this.following }
	
	search mapping {
		username
		username as subUserName using usernameAnalyzer
	}
}

entity Cheet {
	author: User
	message: WikiText
//	predicate isRecheetedBy( u: User ){ (from Recheet as rc where rc.rcer = u and cheet = this).length == 1 }
}

entity Recheet {
	rcer: User
	cheet: Cheet
}

analyzer usernameAnalyzer {
  // tokenizer = PatternTokenizer(pattern="([a-z])", group="1")
  tokenizer = StandardTokenizer
  token filter = LowerCaseFilter
  token filter = NGramFilter(minGramSize = "1", maxGramSize = "50")
}
