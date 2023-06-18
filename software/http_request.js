
http_get = (url, type="", callback=(request)=>{
	console.log(request.responseText)
	http_get("/state", "json", (request)=>{
		light_obj = document.getElementById("light");
		if (request.readyState === XMLHttpRequest.DONE) {
			if (request.status === 200) {
				var response = request.response
				if (response["state"] == 1) { light_obj.className = "label label-success" }
				else { light_obj.className = "label label-danger" }
				console.log(response);
			}
		}
	})
}) => {
	const Http = new XMLHttpRequest();
	domain = "https://esp32c3.tbz.io"
	uri = domain + url
	Http.open("GET", uri);
	Http.responseType = type;
	Http.send();
	Http.onload = ()=>{
		callback(Http)
	}
}
http_get("/state")