Library "hsm.brs"
Library "eventHandler.brs"
Library "networking.brs"

Sub Main()

	RunPlayer()

End Sub


Sub RunPlayer()

	CreateDirectory("brightsign-dumps")
	CreateDirectory("pool")
	
	msgPort = CreateObject("roMessagePort")

    Player = newPlayer(msgPort)

	Player.eventHandler = newEventHandler(invalid, msgPort)

	Player.networking = newNetworking( Player, invalid, invalid, invalid, invalid, Player.msgPort, invalid, invalid )

	Player.networking.Initialize()

	Player.eventHandler.AddHSM(Player.networking)

	Player.eventHandler.EventLoop()

	' playerXML = Player.ParseXml()

End Sub


Function newPlayer(msgPort As Object) As Object

    Player = {}

    Player.msgPort = msgPort
	EnableZoneSupport(true)

	Player.ParseXml = ParseXml
	Player.ParseTemplate = ParseTemplate
	Player.ParseFrame = ParseFrame
	Player.ParsePlaylist = ParsePlaylist
	Player.ParsePlaylistFile = ParsePlaylistFile

	return Player

End Function


Function ParseXml()

	channel = {}
	channel.templates = []

	xml$ = ReadAsciiFile("xml/publishnew.xml")
    if len(xml$) > 0 then

		publishmentXml = CreateObject("roXMLElement")
		publishmentXml.Parse(xml$)

		if publishmentXml.getName() = "Publishment" then

			templatesXML = publishmentXml.Timeline.Templates.Template
			for each templateXml in templatesXML
				template = m.ParseTemplate(templateXML)
				channel.templates.push(template)
			next

			return channel
		endif

	endif

End Function


Function ParseTemplate(templateXML As Object)

	template = {}

	template.name = templateXML.CamSetName.GetText()
	template.duration = templateXML.Duration.GetText()
	template.frames = []

	framesXML = templateXML.Frames.Frame
	for each frameXml in framesXml
		frame = m.ParseFrame(frameXML)
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
		playlist = m.ParsePlaylist(playlistXML)
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
		playlistFile = m.ParsePlaylistFile(playlistFileXML)
		playlist.files.push(playlistFile)
	next

	return playlist

End Function


Function ParsePlaylistFile(playlistFileXML As Object)

	playlistFile = {}

	playlistFile.name = playlistFileXML.Content.Cname.getText()
	playlistFile.fileName = playlistFileXML.Content.FileName.getText()
	playlistFile.duration = playlistFileXML.Content.Duration.getText()

	return playlistFile

End Function


Function IsString(inputVariable As Object) As Boolean

	if type(inputVariable) = "roString" or type(inputVariable) = "String" then return true
	return false
	
End Function


