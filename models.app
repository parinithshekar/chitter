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
		+username
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
