IMPORT os
IMPORT FGL EmbeddedViewer

CONSTANT _VIDEO_FILE = "How To Embedded Viewer.mp4"
CONSTANT _VIDEO_GRID = "videoviewer_grid"

MAIN

	WHENEVER ANY ERROR CALL errorHandler
	CALL STARTLOG("VideoViewer.log")

	OPEN WINDOW videoWindow WITH FORM "VideoForm"
	CLOSE WINDOW SCREEN

	MENU
		ON ACTION load_video
			CALL loadVideo()
		ON ACTION CANCEL
			EXIT MENU
	END MENU

	CLOSE WINDOW videoWindow

END MAIN

PRIVATE FUNCTION loadVideo() RETURNS ()
	DEFINE videoViewer TEmbeddedViewer
	DEFINE videoFile STRING

	LET videoFile = SFMT("..%1res%1%2", os.Path.separator(), _VIDEO_FILE)
	IF NOT os.Path.exists(videoFile) THEN
		ERROR SFMT("Video file %1 does not exist", videoFile)
		RETURN
	END IF

	CALL ui.Window.getCurrent().getForm().setElementHidden(_VIDEO_GRID, 0)
	CALL videoViewer.init(videoFile)
	LET videoViewer.eleWidth = 800
	DISPLAY videoViewer.toString() TO formonly.videoviewer

END FUNCTION #loadVideo

PRIVATE FUNCTION errorHandler() RETURNS ()

	DISPLAY SFMT("Error Code: %1", STATUS)
	DISPLAY SFMT("Error Description: %2", err_get(STATUS))
	DISPLAY SFMT("Stack Trace: %1", base.Application.getStackTrace())
	EXIT PROGRAM -1

END FUNCTION