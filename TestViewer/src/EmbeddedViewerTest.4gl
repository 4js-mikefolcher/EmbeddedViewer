IMPORT os

IMPORT FGL EmbeddedHTML
IMPORT FGL EmbeddedViewer

TYPE TKeyValuePair RECORD
	recKey STRING,
	recValue STRING
END RECORD

DEFINE envValues DYNAMIC ARRAY OF TKeyValuePair

#Report Output Constants
CONSTANT _OUTPUT_PDF = "PDF"
CONSTANT _OUTPUT_HTML = "HTML"
CONSTANT _OUTPUT_BROWSER = "Browser"

CONSTANT _REPORT_NAME = "UserEnvironment.4rp"

MAIN
	DEFINE outputType STRING

	WHENEVER ANY ERROR CALL errorHandler
	CALL STARTLOG("TestViewer.log")

	OPEN WINDOW mainWindow WITH FORM "ViewerForm"
	CLOSE WINDOW SCREEN

	CALL loadCombobox()

	INPUT outputType WITHOUT DEFAULTS FROM formonly.output_type
		ATTRIBUTES (ACCEPT=FALSE)

		ON ACTION run_report
			ACCEPT INPUT

		ON ACTION CANCEL
			EXIT INPUT

		AFTER INPUT
			IF outputType IS NULL THEN
				ERROR "Must select an output type"
				CONTINUE INPUT
			END IF

			#Build key/value pairs of environment variables
			CALL envValues.clear()
			LET envValues = getEnvVars()

			IF outputType == _OUTPUT_HTML THEN
				CALL displayHTML()
			ELSE
				CALL displayGRE(outputType)
			END IF

			CONTINUE INPUT

	END INPUT

	CLOSE WINDOW mainWindow

END MAIN

PRIVATE FUNCTION displayHTML() RETURNS ()
	DEFINE embeddedHTML TEmbeddedHTML
	DEFINE idx INTEGER
	DEFINE formObj ui.Form
	DEFINE firstPass BOOLEAN = TRUE

	LET formObj = ui.Window.getCurrent().getForm()
	CALL formObj.setElementHidden("docviewer_grid", 1)
	CALL formObj.setElementHidden("htmlviewer_grid", 0)
	CALL formObj.setElementHidden("url_grid", 1)

	CALL embeddedHTML.init()
	CALL embeddedHTML.appendHTML("<table>")
	FOR idx = 1 TO envValues.getLength()
		IF firstPass THEN
			CALL embeddedHTML.appendHTML("<tr>")
			CALL embeddedHTML.appendHTML("<td><b>Variable</b></td>")
			CALL embeddedHTML.appendHTML("<td><b>Value</b></td>")
			CALL embeddedHTML.appendHTML("</tr>")
			LET firstPass = FALSE
		END IF
		CALL embeddedHTML.appendHTML("<tr>")
		CALL embeddedHTML.appendHTML(SFMT("<td>%1</td>", envValues[idx].recKey))
		CALL embeddedHTML.appendHTML(SFMT("<td>%1</td>", envValues[idx].recValue))
		CALL embeddedHTML.appendHTML("</tr>")
	END FOR
	CALL embeddedHTML.appendHTML("</table>")

	DISPLAY embeddedHTML.toString() TO formonly.htmlviewer

END FUNCTION #displayHTML

PRIVATE FUNCTION displayGRE(outputType STRING) RETURNS ()
	DEFINE embeddedViewer TEmbeddedViewer
	DEFINE keyValue TKeyValuePair
	DEFINE idx INTEGER
	DEFINE formObj ui.Form
	DEFINE firstPass BOOLEAN = TRUE
	DEFINE tmpFile STRING
	DEFINE handlerObj om.SaxDocumentHandler

	LET formObj = ui.Window.getCurrent().getForm()
	CALL formObj.setElementHidden("htmlviewer_grid", 1)

	IF outputType == _OUTPUT_PDF THEN
		CALL formObj.setElementHidden("docviewer_grid", 0)
		CALL formObj.setElementHidden("url_grid", 1)
	ELSE
		CALL formObj.setElementHidden("docviewer_grid", 1)
		CALL formObj.setElementHidden("url_grid", 0)
	END IF

	FOR idx = 1 TO envValues.getLength()
		LET keyValue = envValues[idx]
		IF firstPass THEN
			IF outputType != _OUTPUT_BROWSER THEN
				LET tmpFile = getTmpFile(outputType.toLowerCase())
			END IF
			LET handlerObj = reportConfiguration(outputType, tmpFile)
			IF handlerObj IS NULL THEN
				CALL errorHandler()
			END IF
			START REPORT envReport TO XML HANDLER handlerObj
			DISPLAY fgl_report_getBrowserURL() TO formonly.urlviewer
			LET firstPass = FALSE
		END IF
		OUTPUT TO REPORT envReport(keyValue.*)
		IF int_flag THEN
			EXIT FOR
		END IF
	END FOR

	IF firstPass THEN
		ERROR "No records to process"
		RETURN
	END IF

	IF int_flag THEN
		TERMINATE REPORT envReport
	ELSE
		FINISH REPORT envReport
		IF outputType == _OUTPUT_PDF THEN
			CALL embeddedViewer.init(tmpFile)
			LET embeddedViewer.eleHeight = 800
			LET embeddedViewer.eleWidth = 600
			DISPLAY embeddedViewer.toString() TO formonly.docviewer
		END IF
	END IF

END FUNCTION #displayGRE

PRIVATE FUNCTION reportConfiguration(outputformat STRING, filepath STRING)
	RETURNS om.SaxDocumentHandler

	# load the 4rp file
	IF NOT fgl_report_loadCurrentSettings(_REPORT_NAME) THEN
		RETURN NULL
	END IF

	CALL fgl_report_selectDevice(outputformat)
	IF outputformat == _OUTPUT_PDF THEN
		CALL fgl_report_setOutputFileName(filepath)
		CALL fgl_report_selectPreview(FALSE)
	END IF

	# use the report
	RETURN fgl_report_commitCurrentSettings()

END FUNCTION

PRIVATE FUNCTION getTmpFile(ext STRING) RETURNS STRING

	RETURN SFMT("%1.%2", os.Path.makeTempName(), ext)

END FUNCTION #getTmpFile

PRIVATE FUNCTION loadCombobox() RETURNS ()
	DEFINE cbx ui.ComboBox

	LET cbx = ui.ComboBox.forName("formonly.output_type")
	IF cbx IS NOT NULL THEN
		CALL cbx.addItem(_OUTPUT_PDF, "PDF")
		CALL cbx.addItem(_OUTPUT_HTML, "HTML")
		CALL cbx.addItem(_OUTPUT_BROWSER, "Genero Report Viewer")
	END IF

END FUNCTION #loadCombobox

PRIVATE FUNCTION getEnvVars() RETURNS DYNAMIC ARRAY OF TKeyValuePair
	DEFINE envRec TKeyValuePair
	DEFINE envList DYNAMIC ARRAY OF TKeyValuePair
	DEFINE channel base.Channel
	DEFINE cmdOutput STRING
	DEFINE idx INTEGER

	LET channel = base.Channel.create()
	CALL envList.clear()
	CALL channel.openPipe(IIF(isWindows(), "set", "env"), "r")
	WHILE (cmdOutput := channel.readLine()) IS NOT NULL
		LET idx = cmdOutput.getIndexOf("=", 1)
		IF idx > 1 AND idx < cmdOutput.getLength() THEN
			LET envRec.recKey = cmdOutput.subString(1, idx - 1)
			LET envRec.recValue = cmdOutput.subString(idx + 1, cmdOutput.getLength())
			CALL envList.appendElement()
			LET envList[envList.getLength()] = envRec
		END IF
	END WHILE
	CALL channel.close()

	RETURN envList

END FUNCTION #getEnvVars

PRIVATE FUNCTION isWindows() RETURNS BOOLEAN

	RETURN (os.Path.pathSeparator() == ";")

END FUNCTION #isWindows

REPORT envReport(envRec TKeyValuePair)

	FORMAT
		ON EVERY ROW
			PRINTX envRec.*

END REPORT #envReport

PRIVATE FUNCTION errorHandler() RETURNS ()

	DISPLAY SFMT("Error Code: %1", STATUS)
	DISPLAY SFMT("Error Description: %2", err_get(STATUS))
	DISPLAY SFMT("Stack Trace: %1", base.Application.getStackTrace())
	EXIT PROGRAM -1

END FUNCTION