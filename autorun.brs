Library "hsm.brs"
Library "eventHandler.brs"
Library "networking.brs"
Library "displayEngine.brs"

Sub Main()

	RunPlayer()

End Sub


Sub RunPlayer()

	CreateDirectory("brightsign-dumps")
	CreateDirectory("pool")
	CreateDirectory("assets")
	
	msgPort = CreateObject("roMessagePort")

    Player = newPlayer(msgPort)

	Player.eventHandler = newEventHandler(invalid, msgPort)

	Player.networking = newNetworking( Player, invalid, invalid, invalid, invalid, Player.msgPort, invalid, invalid )
	Player.displayEngine = newDisplayEngine(Player, Player.eventHandler, invalid, invalid, invalid, Player.msgPort, invalid)

	Player.networking.Initialize()
	Player.displayEngine.Initialize()

	Player.eventHandler.AddHSM(Player.networking)
	Player.eventHandler.AddHSM(Player.displayEngine)

	Player.eventHandler.EventLoop()

End Sub


Function newPlayer(msgPort As Object) As Object

    Player = {}

    Player.msgPort = msgPort
	EnableZoneSupport(true)

	return Player

End Function


Function IsString(inputVariable As Object) As Boolean

	if type(inputVariable) = "roString" or type(inputVariable) = "String" then return true
	return false
	
End Function


Function ParseXml()

	channel = {}
	channel.version = ""
	channel.templates = []

	xml$ = ReadAsciiFile("xml/publishnew.xml")
    if len(xml$) > 0 then

		publishmentXml = CreateObject("roXMLElement")
		publishmentXml.Parse(xml$)

		if publishmentXml.getName() = "Publishment" then
			
			channel.version = publishmentXml.Version.GetText()

			templatesXML = publishmentXml.Timeline.Templates.Template
			for each templateXml in templatesXML
				template = ParseTemplate(templateXML)
				channel.templates.push(template)
			next

		endif
	endif

	return channel

End Function


Function ParseTemplate(templateXML As Object)

	template = {}

	template.name = templateXML.CamSetName.GetText()
	template.duration = templateXML.Duration.GetText()
	template.frames = []

	framesXML = templateXML.Frames.Frame
	for each frameXml in framesXml
		frame = ParseFrame(frameXML)
		template.frames.push(frame)
	next

	return template

End Function


Function ParseFrame(frameXML As Object)

	frame = {}

	frame.name = frameXML.CamName.GetText()
	frame.playlists = []

	playlistsXML = frameXML.PlayLists.Playlist
	for each playlistXML in playlistsXML
		playlist = ParsePlaylist(playlistXML)
		frame.playlists.push(playlist)
	next

	return frame

End Function


Function ParsePlaylist(playlistXML As Object)

	playlist = {}

	playlist.name = playlistXML.ListFileID.GetText()
	playlist.files = []

	playlistFilesXML = playlistXML.PlayListFiles.PlaylistFile
	for each playlistFileXML in playlistFilesXML
		playlistFile = ParsePlaylistFile(playlistFileXML)
		playlist.files.push(playlistFile)
	next

	return playlist

End Function


Function ParsePlaylistFile(playlistFileXML As Object)

	playlistFile = {}

	playlistFile.name = playlistFileXML.Content.Cname.getText()
	playlistFile.fileName = playlistFileXML.Content.FileName.getText()
	playlistFile.playOrder = int(val(playlistFileXML.FileOrder.getText()))
	playlistFile.duration = playlistFileXML.Duration.getText()
	playlistFile.contentId = playlistFileXML.Content.ContentID.getText()
	playlistFile.fileSize = playlistFileXML.Content.FileSize.getText()
	playlistFile.CRC = playlistFileXML.Content.CRC.getText()

	return playlistFile

End Function


Sub DisplayErrorScreen(msg1$ As String, msg2$ As String)

	videoMode = CreateObject("roVideoMode")
	resX = videoMode.GetResX()
	resY = videoMode.GetResY()
	videoMode = invalid

	r = CreateObject("roRectangle", 0, 0, resX, resY)
	twParams = CreateObject("roAssociativeArray")
	twParams.LineCount = 1
	twParams.TextMode = 2
	twParams.Rotation = 0
	twParams.Alignment = 1
	tw=CreateObject("roTextWidget",r,1,2,twParams)
	tw.PushString("")
	tw.Show()

	r=CreateObject("roRectangle",0,resY/2-resY/32,resX,resY/32)
	tw=CreateObject("roTextWidget",r,1,2,twParams)
	tw.PushString(msg1$)
	tw.Show()

	r2=CreateObject("roRectangle",0,resY/2,resX,resY/32)
	tw2=CreateObject("roTextWidget",r2,1,2,twParams)
	tw2.PushString(msg2$)
	tw2.Show()

	' wait here forever
	msToWaitBeforeRebooting = 0
    msgPort = CreateObject("roMessagePort")
    msg = wait(msToWaitBeforeRebooting, msgPort)
    RebootSystem()

End Sub


