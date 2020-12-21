var onICHostReady = function(version) {

	var propFunc = function(properties) {
		try {
			//Make sure properties is not null
			if (!properties) return;

			//Get the video tag
			var viewer = document.getElementById("videoviewer_object");

			//Convert the JSON string to an object
			var attribs = JSON.parse(properties);

			//Set the video tag properties
			if (attribs.fileUrl) {
				viewer.src = attribs.fileUrl;
			}
			if (attribs.mimeType) {
				viewer.type = attribs.mimeType;
			}
			if (attribs.eleHeight && attribs.eleHeight > 0) {
				viewer.height = attribs.eleHeight;
			}
			if (attribs.eleWidth && attribs.eleWidth > 0) {
				viewer.width = attribs.eleWidth;
			}
			console.debug("Video tag initialized with attributes: " + properties);
		} catch (ex) {
			console.log("Exception: " + ex.toString());
			console.log("Properties: " + properties);
		}
	};

	gICAPI.onData = propFunc;
	gICAPI.onProperty = propFunc;

}
