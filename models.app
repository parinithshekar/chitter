module models

entity User {
	username: String (name, id)
	password: Secret
	tag: String ( validate ( isUniqueTag() , "tag needs ot be unique") )
	super: Bool
	cheets: {Cheet} (inverse = author)
	followers: {User}
	following: {User}
	predicate sameUser( u: User ){ this == u }
	predicate isUniqueTag(){ (from User as u where u.tag = ~this.tag).length <= 1 }
}

entity Cheet {
	author: User
	message: WikiText
}

entity Like {
	actor: User
	cheet: Cheet
}
