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
	includeCSS("bulma.min.css")
	includeCSS("chitter.css")
	elements
}

template feedButton {
	"feed button"
}

template searchButton {
	"search button"
}

template i {
	<i all attributes>
	elements
	</i>
}

template p {
	<p all attributes>
		elements
	</p>
}

template footer {
	<footer all attributes>
	elements
	</footer>
}

template button {
	<button all attributes>
	elements
	</button>
}

template label {
	<label all attributes>
	elements
	</label>
}