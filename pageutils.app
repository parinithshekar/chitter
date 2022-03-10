module pageutils

template deps {
	head {
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    
    <!-- Fontawesome -->	
    <script src="https://kit.fontawesome.com/6bdb84d882.js" crossorigin="anonymous"></script>
    
    <title>"Chitter"</title>
  }
}

template main {
	deps
	includeCSS("chitter.css")
	includeCSS("bulma.min.css")
	elements
}

template feedButton {
	"feed button"
}

template searchButton {
	"search button"
}

template i {
	<i all attributes></i>
}