# EmbeddedViewer
**Genero GBC Embedded Viewers**

## _Usage in Form Files_
`WEBCOMPONENT wc001 = formonly.docviewer, COMPONENTTYPE="docviewer", STRETCH=BOTH;`\
`WEBCOMPONENT wc002 = formonly.htmlviewer, COMPONENTTYPE="htmlviewer", STRETCH=BOTH;`\
`WEBCOMPONENT wc003 = formonly.videoviewer, COMPONENTTYPE="docviewer", STRETCH=BOTH;`\

## _Usage in Code - Document Viewer_
`DEFINE embeddedRec TEmbeddedViewer`\
`CALL embeddedRec.init("Report.pdf")`\
`DISPLAY embeddedRec.toString() TO formonly.docviewer`\
 
## _Usage in Code - Video Viewer_
`DEFINE embeddedRec TEmbeddedViewer`\
`CALL embeddedRec.init("Video.mp4")`\
`DISPLAY embeddedRec.toString() TO formonly.videoviewer`\

## _Usage in Code - HTML Viewer_
`DEFINE htmlRec TEmbeddedHTML`\
`CALL htmlRec.init()`\
`CALL htmlRec.appendHTML("<h1>Hello World</h1>")`\
`CALL htmlRec.appendNewLine()`\
`CALL htmlRec.appendHTML("<b>Goodbye!</b>")`\
`DISPLAY htmlRec.toString() TO formonly.htmlviewer`\

