var accessToken;

function FBlogin() {
	FB.login(function(response) {
		if (response.authResponse) {
			accessToken = response.authResponse.accessToken;
     		console.log('Welcome! ' + accessToken);
	    } else {
	    	console.log('User cancelled login or did not fully authorize.');
	    }
	}, {scope: 'email, user_photos'});
}

function FBlogout() {
	FB.logout(function(response) {
  		// user is now logged out
	});
}