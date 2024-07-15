#+ Embedded Document Web Component
#+
#+ This module provides the record structure and helper methods to interface with the
#+ either the document viewer web component (docviewer) or the video viewer web component
#+ (videoviewer).
#+
IMPORT os
IMPORT util
IMPORT security

#+ Embedded Viewer Record
#+
#+ Define a variable of this type to interface with one of the embedded viewers.
#+
#+ @code
#+ DEFINE embeddedRec TEmbeddedViewer
#+ CALL embeddedRec.init("My Report.pdf")
#+ DISPLAY embeddedRec.toString() TO formonly.docviewer
#+
PUBLIC TYPE TEmbeddedViewer RECORD
	fileUrl STRING,
	mimeType STRING,
	fileData STRING,
	eleHeight INTEGER,
	eleWidth INTEGER
END RECORD

#+ Internal Dictionary to store supported mimetypes
PRIVATE DEFINE mimetypes DICTIONARY OF STRING

#+ Internal filecache so the same file is not copied multiple times
PRIVATE DEFINE filecache DICTIONARY OF STRING

#+ Initialize the TEmbeddedViewer Record
#+
#+ This function initializes the TEmbeddedViewer record and set the
#+ file url and the mime-type based on the file passed as an 
#+ argument.  It also sets the height and width to zero.
#+
#+ @code
#+ CALL embeddedRec.init("My Report.pdf")
#+
PUBLIC FUNCTION (self TEmbeddedViewer) init(filename STRING)

	CALL self.setMimeType(filename)
	CALL self.setFileUrl(filename)
	LET self.eleHeight = 0
	LET self.eleWidth = 0

END FUNCTION #init

#+ Converts the TEmbeddedViewer Record to a String
#+
#+ This function converts the TEmbeddedViewer record to a JSON string
#+ and returns the string.
#+
#+ @code
#+ DISPLAY embeddedRec.toString() TO formonly.docviewer
#+
#+ @return JSON String that represents the TEmbeddedViewer record
#+
PUBLIC FUNCTION (self TEmbeddedViewer) toString() RETURNS STRING

	RETURN util.JSON.stringifyOmitNulls(self)

END FUNCTION #toString

#+ Sets the Mime-type of the TEmbeddedViewer Record
#+
#+ This function set the mimeType field of the TEmbeddedViewer record 
#+ based on the file extension of the file.
#+
#+ @code
#+	CALL self.setMimeType(filename)
#+
#+ @param filename File name to view in the embedded viewer
#+
PRIVATE FUNCTION (self TEmbeddedViewer) setMimeType(filename STRING) RETURNS ()
	DEFINE fileExtension STRING

	IF mimetypes.getLength() == 0 THEN
		#lazy load the mimetypes
		LET mimetypes = getMimeTypes()
	END IF

	LET fileExtension = DOWNSHIFT(os.Path.extension(filename))

	IF mimetypes.contains(fileExtension) THEN
		LET self.mimeType = mimetypes[fileExtension]
	ELSE
		LET self.mimeType = "plain/text"
	END IF

END FUNCTION

#+ Sets the File URL of the TEmbeddedViewer Record
#+
#+ This function set the fileUrl field of the TEmbeddedViewer record.  It 
#+ takes the file and copies it to an area this is viewable only to the 
#+ current user session.  It set the fileUrl field to the value of the 
#+ private URL.
#+
#+ @code
#+	CALL self.setFileUrl(filename)
#+
#+ @param filename File name to view in the embedded viewer
#+
PRIVATE FUNCTION (self TEmbeddedViewer) setFileUrl(filename STRING) RETURNS ()
	DEFINE gas_private_filepath STRING

	IF filecache.contains(filename) THEN
		LET self.fileUrl = filecache[filename]
	ELSE
		LET gas_private_filepath = FGL_GETENV("FGL_PRIVATE_DIR")
		IF gas_private_filepath IS NULL THEN
			CALL self.setFileData(filename)
		ELSE
			LET gas_private_filepath = SFMT("%1%2%3",
				gas_private_filepath,
				os.Path.separator(),
				os.Path.baseName(filename))
			IF os.Path.copy(filename, gas_private_filepath) THEN
				LET self.fileUrl = SFMT("%1/%2",
					FGL_GETENV("FGL_PRIVATE_URL_PREFIX"),
					os.Path.baseName(gas_private_filepath))
				LET filecache[filename] = self.fileUrl
			END IF
		END IF
	END IF

END FUNCTION #setFileUrl

#+ Sets the File Data (Base 64) of the TEmbeddedViewer Record
#+
#+ This function sets the fileData field of the TEmbeddedViewer record.  It
#+ takes the file and, base 64 encodes it, and sets the fileData field.
#+
#+ @code
#+	CALL self.setFileData(filename)
#+
#+ @param filename File name to view in the embedded viewer
#+
PRIVATE FUNCTION (self TEmbeddedViewer) setFileData(filename STRING) RETURNS ()

	VAR byteData BYTE
	LOCATE byteData IN MEMORY
	CALL byteData.readFile(filename)
	LET self.fileData = security.Base64.FromByte(byteData)
	FREE byteData

	LET self.fileUrl = NULL
	IF self.mimeType IS NOT NULL THEN
		LET self.fileData = SFMT("data:%1;base64,%2", self.mimeType, self.fileData)
	END IF

END FUNCTION #setFileData

#+ Builds Mime-type Dictionary
#+
#+ This function builds and returns a dictionary of the file extensions (key)
#+ and the corresponding mime-types (value).
#+
#+ @code
#+ LET mimetypes = getMimeTypes()
#+
#+ @return Dictionary of file extensions and the associated mime-types
#+
PRIVATE FUNCTION getMimeTypes() RETURNS DICTIONARY OF STRING
	DEFINE extList DICTIONARY OF STRING

	LET extList["pdf"] = "application/pdf"
	LET extList["html"] = "text/html"
	LET extList["htm"] = "text/html"
	LET extList["swf"] = "application/x-shockwave-flash"
	LET extList["rtf"] = "application/rtf"
	LET extList["mp4"] = "video/mp4"
	LET extList["webm"] = "video/webm"
	LET extList["ogv"] = "video/ogg"

	RETURN extList

END FUNCTION #getMimeTypes