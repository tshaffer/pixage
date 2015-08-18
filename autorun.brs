Sub Main()

	RunPlayer()

End Sub


Sub RunPlayer()
	
	msgPort = CreateObject("roMessagePort")

    Player = newPlayer(msgPort)

	Player.CheckMacAddr = CheckMacAddr
	Player.GetPublishmentVersionForClient = GetPublishmentVersionForClient
	Player.ParseGetPublishmentVersionForClientXml = ParseGetPublishmentVersionForClientXml
	Player.RetrievePublishFile = RetrievePublishFile
	Player.UnpackPublishFile = UnpackPublishFile
	Player.ParseXml = ParseXml
	Player.ParseTemplate = ParseTemplate
	Player.ParseFrame = ParseFrame
	Player.ParsePlaylist = ParsePlaylist
	Player.ParsePlaylistFile = ParsePlaylistFile

	Player.EventLoop = EventLoop

'	Player.CheckMacAddr()
'	Player.EventLoop()
	playerXML = Player.ParseXml()
	stop

End Sub


Function newPlayer(msgPort As Object) As Object

    Player = {}

    Player.msgPort = msgPort
	EnableZoneSupport(true)

	return Player

End Function



Function GetSoapContentType() As String
	return "text/xml; charset="+ chr(34) + "utf-8" + chr(34)
End Function


Sub CheckMacAddr()

	url$ = "http://pixage.kocsistem.com.tr/dev30/ClientWS/Client.asmx"

	m.soapTransfer = CreateObject( "roUrlTransfer" )
	m.soapTransfer.SetTimeout( 30000 )
	m.soapTransfer.SetPort( m.msgPort )
	m.soapTransfer.SetUrl( url$ )

	if not m.soapTransfer.addHeader("SOAPACTION", "http://tempuri.org/CheckMacAddr") stop
	if not m.soapTransfer.addHeader( "Content-Type", GetSoapContentType() ) stop


'										<?xml version="1.0" encoding="utf-8"?>
	checkMacAddrXml = "<?xml version=" + chr(34) + "1.0" + chr(34) + " encoding=" + chr(34) + "utf-8" + chr(34) + "?>"

'										<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
	checkMacAddrXml = checkMacAddrXml + "<soap:Envelope xmlns:xsi=" + chr(34) + "http://www.w3.org/2001/XMLSchema-instance" + chr(34) + " xmlns:xsd=" + chr(34) + "http://www.w3.org/2001/XMLSchema" + chr(34) + " xmlns:soap=" + chr(34) + "http://schemas.xmlsoap.org/soap/envelope/" + chr(34) + ">"
	
'										<soap:Body>
	checkMacAddrXml = checkMacAddrXml + "<soap:Body>"

'										<CheckMacAddr xmlns="http://tempuri.org/">
	checkMacAddrXml = checkMacAddrXml + "<CheckMacAddr xmlns=" + chr(34) + "http://tempuri.org/" + chr(34) + ">"

'										<ClientGUID>string</ClientGUID>
	checkMacAddrXml = checkMacAddrXml + "<ClientGUID>736b3972-aa2b-463b-8ac4-668bb3374ef1</ClientGUID>"

'										<MACAddresses>
	checkMacAddrXml = checkMacAddrXml + "<MACAddresses>"

'										<string>string</string>
	checkMacAddrXml = checkMacAddrXml + "<string>90:ac:3f:03:87:12</string>"
	 
'										</MACAddresses>
	checkMacAddrXml = checkMacAddrXml + "</MACAddresses>"

'										</CheckMacAddr>
	checkMacAddrXml = checkMacAddrXml + "</CheckMacAddr>"

'										</soap:Body>
	checkMacAddrXml = checkMacAddrXml + "</soap:Body>"

'										</soap:Envelope>	
	checkMacAddrXml = checkMacAddrXml + "</soap:Envelope>"
	

	aa = {}
	aa.method = "POST"
	aa.request_body_string = checkMacAddrXml
	aa.response_body_string = true

	if not m.soapTransfer.AsyncMethod( aa ) then
		stop
	endif

End Sub


Sub GetPublishmentVersionForClient()

	url$ = "http://pixage.kocsistem.com.tr/dev30/ClientWS/Client.asmx"

	m.getPublishmentVersionForClientXfer = CreateObject( "roUrlTransfer" )
	m.getPublishmentVersionForClientXfer.SetTimeout( 30000 )
	m.getPublishmentVersionForClientXfer.SetPort( m.msgPort )
	m.getPublishmentVersionForClientXfer.SetUrl( url$ )

	if not m.getPublishmentVersionForClientXfer.addHeader("SOAPACTION", "http://tempuri.org/GetPublishmentVersionForClient") stop
	if not m.getPublishmentVersionForClientXfer.addHeader( "Content-Type", GetSoapContentType() ) stop


'<?xml version="1.0" encoding="utf-8"?>
	getPublishmentVersionForClientXml = "<?xml version=" + chr(34) + "1.0" + chr(34) + " encoding=" + chr(34) + "utf-8" + chr(34) + "?>"

'<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
	getPublishmentVersionForClientXml = getPublishmentVersionForClientXml + "<soap:Envelope xmlns:xsi=" + chr(34) + "http://www.w3.org/2001/XMLSchema-instance" + chr(34) + " xmlns:xsd=" + chr(34) + "http://www.w3.org/2001/XMLSchema" + chr(34) + " xmlns:soap=" + chr(34) + "http://schemas.xmlsoap.org/soap/envelope/" + chr(34) + ">"

'  <soap:Body>
	getPublishmentVersionForClientXml = getPublishmentVersionForClientXml + "<soap:Body>"

'    <GetPublishmentVersionForClient xmlns="http://tempuri.org/">
	getPublishmentVersionForClientXml = getPublishmentVersionForClientXml + "<GetPublishmentVersionForClient xmlns=" + chr(34) + "http://tempuri.org/" + chr(34) + ">"

'      <ClientGUID>string</ClientGUID>
	getPublishmentVersionForClientXml = getPublishmentVersionForClientXml + "<ClientGUID>736b3972-aa2b-463b-8ac4-668bb3374ef1</ClientGUID>"

'      <MACAddress>
'	getPublishmentVersionForClientXml = getPublishmentVersionForClientXml + "<MACAddresses>"
	getPublishmentVersionForClientXml = getPublishmentVersionForClientXml + "<MACAddress>"

'        <string>string</string>
	getPublishmentVersionForClientXml = getPublishmentVersionForClientXml + "<string>90:ac:3f:03:87:12</string>"

'      </MACAddress>
'	getPublishmentVersionForClientXml = getPublishmentVersionForClientXml + "</MACAddresses>"
	getPublishmentVersionForClientXml = getPublishmentVersionForClientXml + "</MACAddress>"

'    </GetPublishmentVersionForClient>
	getPublishmentVersionForClientXml = getPublishmentVersionForClientXml + "</GetPublishmentVersionForClient>"

'  </soap:Body>
	getPublishmentVersionForClientXml = getPublishmentVersionForClientXml + "</soap:Body>"

'</soap:Envelope>
	getPublishmentVersionForClientXml = getPublishmentVersionForClientXml + "</soap:Envelope>"


	aa = {}
	aa.method = "POST"
	aa.request_body_string = getPublishmentVersionForClientXml
	aa.response_body_string = true

	if not m.getPublishmentVersionForClientXfer.AsyncMethod( aa ) then
		stop
	endif


End Sub


Function ParseGetPublishmentVersionForClientXml( event As Object ) As String

	if event.GetString() <> "" then
		getPublishmentVersionForClientXMLDoc = CreateObject("roXMLElement")
		getPublishmentVersionForClientXMLDoc.Parse(event.GetString())
		children = getPublishmentVersionForClientXMLDoc.GetChildElements()
		if children.Count() = 1 then
			soapBody = children[0]
			publishmentVersionForClientResult = soapBody.GetPublishmentVersionForClientResponse.GetPublishmentVersionForClientResult
			outputObjectList = soapBody.GetPublishmentVersionForClientResponse.GetPublishmentVersionForClientResult.OutputObject
			xmlVersion$ = outputObjectList[0].GetBody()
			return xmlVersion$
		endif
	endif

	return ""

End Function


Sub RetrievePublishFile( xmlVersion$ )

	' retrieve xml file from “http://pixage.kocsistem.com.tr/dev30/uploaderws/files/”  + publishmentversion + “.zip”
	url$ = "http://pixage.kocsistem.com.tr/dev30/uploaderws/files/" + xmlVersion$ + ".zip"

	m.getPublishFileXfer = CreateObject( "roUrlTransfer" )
	m.getPublishFileXfer.SetTimeout( 30000 )
	m.getPublishFileXfer.SetPort( m.msgPort )
	m.getPublishFileXfer.SetUrl( url$ )

	rc = m.getPublishFileXfer.GetToFile("publish.zip")
	if rc <> 200 then stop

End Sub


Sub UnpackPublishFile()

	ok = CreateDirectory("xml")

	brightPackage = CreateObject("roBrightPackage", "publish.zip")
	brightPackage.unpack("SD:/xml")

End Sub

Sub EventLoop()

    while true
        
        msg = wait(0, m.msgPort)

		print "msg received - type=" + type(msg)

		if type(msg) = "roUrlEvent" then

			if msg.GetSourceIdentity() = m.soapTransfer.GetIdentity() then
				if msg.GetResponseCode() = 200 then
					checkMacAddrResponse$ = msg.GetString()
					m.GetPublishmentVersionForClient()
				else
					stop
				endif
			endif

			if msg.GetSourceIdentity() = m.getPublishmentVersionForClientXfer.GetIdentity() then
				getPublishmentVersionForClient$ = msg.GetString()
				xmlVersion$ = m.ParseGetPublishmentVersionForClientXml( msg )

				' longer term, check to see if xml has changed
				m.RetrievePublishFile(xmlVersion$)

				m.UnpackPublishFile()

				m.ParseXml()

				stop
			endif

		endif

    end while
    
End Sub


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

