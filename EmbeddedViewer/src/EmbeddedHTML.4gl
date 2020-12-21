#+ Embedded HTML Web Component
#+
#+ This module provides the record structure and helper methods to interface with the
#+ htmlviewer web component
#+
IMPORT util

#+ Embedded HTML Record
#+
#+ Define a variable of this type to interface with the Embedded HTML web component
#+
#+ @code
#+ DEFINE htmlRec TEmbeddedHTML
#+ CALL htmlRec.init()
#+ CALL htmlRec.appendHTML("<h1>Hello World</h1>")
#+ CALL htmlRec.appendNewLine()
#+ CALL htmlRec.appendHTML("<b>Goodbye!</b>")
#+ DISPLAY htmlRec.toString() TO formonly.htmlviewer
#+
PUBLIC TYPE TEmbeddedHTML RECORD
	htmlText STRING,
	eleHeight INTEGER,
	eleWidth INTEGER
END RECORD

#+ Initialize the TEmbeddedHTML Record
#+
#+ This function initializes the TEmbeddedHTML record and sets a default height and width
#+ which can be overridden after call the init function.
#+
#+ @code
#+ CALL htmlRec.init()
#+
PUBLIC FUNCTION (self TEmbeddedHTML) init() RETURNS ()

	LET self.htmlText = ""
	LET self.eleWidth = 0
	LET self.eleHeight = 0

END FUNCTION #init

#+ Converts the TEmbeddedHTML Record to a String
#+
#+ This function converts the TEmbeddedHTML record to a JSON string and returns the string.
#+
#+ @code
#+ DISPLAY htmlRec.toString() TO formonly.htmlviewer
#+
#+ @return JSON String that represents the TEmbeddedHTML record
#+
PUBLIC FUNCTION (self TEmbeddedHTML) toString() RETURNS STRING

	RETURN util.JSON.stringifyOmitNulls(self)

END FUNCTION #toString

#+ Append HTML Text
#+
#+ This function appends HTML text to the end of the htmlText field in the TEmeddedHTML
#+ record.
#+
#+ @code
#+ CALL htmlRec.appendHTML("<h1>Hello World</h1>")
#+
#+ @param htmlText HTML text to append to the htmlText field
#+
PUBLIC FUNCTION (self TEmbeddedHTML) appendHTML(htmlText STRING) RETURNS ()

	LET self.htmlText = self.htmlText.append(htmlText)

END FUNCTION #appendHTML

#+ Append HTML New Line (Break) Tag
#+
#+ This function appends the HTML break tag to the htmlText field in the TEmeddedHTML
#+ record.
#+
#+ @code
#+ CALL htmlRec.appendNewLine()
#+
PUBLIC FUNCTION (self TEmbeddedHTML) appendNewLine() RETURNS ()

	CALL self.appendHTML("<br/>")

END FUNCTION #appendNewLine