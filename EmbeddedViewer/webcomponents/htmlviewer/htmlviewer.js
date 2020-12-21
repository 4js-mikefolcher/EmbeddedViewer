var onICHostReady = function(version) {

	var propFunc = function(properties) {
		try {
			//Make sure properties is not null
			if (!properties) return;

			//Get the HTML viewer div tag
			var viewer = document.getElementById("html_viewer");

			//Convert the JSON string into an object
			var attribs = JSON.parse(properties);

			//Set the div tag properties
			if (attribs.htmlText) {
				viewer.innerHTML = attribs.htmlText;
			}
			if (attribs.eleHeight && attribs.eleHeight > 0) {
				viewer.height = attribs.eleHeight;
			}
			if (attribs.eleWidth && attribs.eleWidth > 0) {
				viewer.width = attribs.eleWidth;
			}
			console.log("Outer HTML: ", viewer.outerHTML);
		} catch (ex) {
			console.log("Exception: " + ex.toString());
			console.log("Properties: " + properties);
		}
	};

	gICAPI.onData = propFunc;
	gICAPI.onProperty = propFunc;

}
