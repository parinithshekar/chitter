module services

service userLogin() {
	var result := JSONObject();
	if(getHttpMethod() == "POST") {
	    var requestPayload := JSONObject(readRequestBody());
	    var correct := authenticate(requestPayload.getString("username"), requestPayload.getString("password"));
	    if (correct) {
	    	result.put("success", true);
	    } else {
	    	result.put("success", false);
	    }
	} else {
		result.put("success", false);
	}
	return result;
}

service userLogout() {
	var result := JSONObject();
	if(getHttpMethod()=="POST") {
		logout();
		success(result);
	}
	return result;
}

service userRegister() {
	var res := JSONObject();
	var errors := JSONArray();
	if(getHttpMethod()=="POST") {
		var payload := JSONObject(readRequestBody());
		var newuser := User{
			username := payload.getString("username")
			password := payload.getString("password")
			super := payload.getBoolean("super")
		};
		if (newuser.password.contains(" ") || newuser.password.length() < 8) {
			res.put("success", false);
			addJsonError(errors, "Password does not satisfy criteria");
			res.put("errors", errors);
		} else {
			newuser.password := newuser.password.digest();
			newuser.save();
			res.put("success", true);
		}
	}
	return res;
}

service currentUser() {
	var res := JSONObject();
	if (loggedIn()) {
		success(res);
		res.put("user", getUserObject(principal));
	} else {
		failure(res);
	}
	return res;
}

service postCheet() {
	var res := JSONObject();
	if(getHttpMethod()=="POST") {
		var payload := JSONObject(readRequestBody());
		if (payload.getString("message").length() == 0) {
			failure(res);
		} else {
			Cheet{
				author := principal
				message := payload.getString("message")	
			}.save();
			success(res);
		}
	}
	return res;
}

service feedCheets() {
	var res := JSONObject();
	var cheets := JSONArray();
	if (getHttpMethod()=="GET") {
		var cheeters : {User};
		// Add cheets from following and super users
		cheeters.addAll(principal.following);
		cheeters.addAll((from User as u where u.super = true));
		for (u in cheeters) {
			for (cheet in u.cheets) {
				var c := JSONObject();
				c.put("id", cheet.id);
				c.put("message", cheet.message);
				c.put("author", getUserObject(cheet.author));
				c.put("recheetCount", getRecheetCount(cheet));
				c.put("hasRecheeted", getHasRecheeted(principal, cheet));
				c.put("isRecheet", false);
				cheets.put(c);
			}
		}
		// Add recheets
		var rcs : {Cheet};
		for (rc in (from Recheet as rc where rc.rcer in ~cheeters and rc.cheet.author not in ~cheeters)) {
			if (!(rc.cheet in rcs)) {
				rcs.add(rc.cheet);
				var c := JSONObject();
				c.put("id", rc.cheet.id);
				c.put("message", rc.cheet.message);
				c.put("author", getUserObject(rc.cheet.author));
				c.put("recheetCount", getRecheetCount(rc.cheet));
				c.put("hasRecheeted", getHasRecheeted(principal, rc.cheet));
				c.put("isRecheet", true);
				c.put("recheeter", getUserObject(rc.rcer));
				cheets.put(c);
			}
		}
	}
	res.put("cheets", cheets);
	success(res);
	return res;
}

service recheet(c: Cheet) {
	var res := JSONObject();
	Recheet{ rcer := principal cheet := c}.save();
	success(res);
	return res;
}

service unfollow(user: User) {
	var res := JSONObject();
	if(getHttpMethod()=="POST") {
		principal.following.remove(user);
		success(res);
	}
	return res;
}

service follow(user: User) {
	var res := JSONObject();
	if(getHttpMethod()=="POST") {
		principal.following.add(user);
		success(res);
	}
	return res;
}

service users() {
	var users := JSONArray();
	for (u in (from User)) {
		var o := JSONObject();
		o.put("username", u.username);
		o.put("super", u.super);
		users.put(o);
	}
	return users;
}

service userInfo(user:User) {
	var userInfo := JSONObject();
	userInfo.put("username", user.username);
	userInfo.put("super", user.super);
	userInfo.put("cheets", getUserCheets(user));
	userInfo.put("isPrincipal", principal.sameUser(user));
	userInfo.put("isFollowing", (user in principal.following));
	return userInfo;
}


section functions

function getUserCheets(user: User): JSONArray {
	var cheets := JSONArray();
	for (cheet in user.cheets) {
		var c := JSONObject();
		c.put("id", cheet.id);
		c.put("message", cheet.message);
		c.put("author", getUserObject(cheet.author));
		c.put("recheetCount", getRecheetCount(cheet));
		c.put("hasRecheeted", getHasRecheeted(principal, cheet));
		c.put("isRecheet", false);
		cheets.put(c);
	}
	for (rc in (from Recheet as rc where rc.rcer = ~user)) {
		var c := JSONObject();
		c.put("id", rc.cheet.id);
		c.put("message", rc.cheet.message);
		c.put("author", getUserObject(rc.cheet.author));
		c.put("recheetCount", getRecheetCount(rc.cheet));
		c.put("hasRecheeted", getHasRecheeted(principal, rc.cheet));
		c.put("isRecheet", true);
		c.put("recheeter", getUserObject(rc.rcer));
		cheets.put(c);
	}
	return cheets;
	/*
	recheets.addAll([Recheet{ cheet := cheet rcer := null} | cheet in user.cheets]);
	recheets.addAll((from Recheet as rc where rc.rcer = ~user));
	*/
}

function getUserObject(u: User): JSONObject {
	var o := JSONObject();
	o.put("username", u.username);
	o.put("super", u.super);
	return o;
}

function getRecheetCount(c: Cheet): Int {
	return (from Recheet as rc where rc.cheet = ~c).length;
}

function getHasRecheeted(u: User, c: Cheet): Bool {
	return ((from Recheet as rc where rc.rcer = ~u and rc.cheet = ~c).length > 0);
}


section utils

function success(object: JSONObject) {
	object.put("success", true);
}

function failure(object: JSONObject) {
	object.put("success", false);
}

function addJsonError( msgs: JSONArray, error: String ){
  var o := JSONObject();
  o.put( "error", error );
  msgs.put( o );
}