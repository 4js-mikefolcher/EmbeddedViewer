var onICHostReady = function(version) {

	var propFunc = function(properties) {
		try {
			//Make sure properties is not null
			if (!properties) return;

			//Get the object tag
			var viewer = document.getElementById("docviewer_object");

			//Create an object from the JSON string
			var attribs = JSON.parse(properties);

			//Set the object tag properties
			if (attribs.fileUrl) {
				viewer.data = attribs.fileUrl;
			}
			if (attribs.fileData) {
				viewer.data = attribs.fileData;
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
			console.debug("Object tag initialized with attributes: " + properties);
		} catch (ex) {
			console.log("Exception: " + ex.toString());
			console.log("Properties: " + properties);
		}
	};

	gICAPI.onData = propFunc;
	gICAPI.onProperty = propFunc;
}
