Function newNetworking( player As Object, diagnostics As Object, logging As Object, diagnosticCodes As Object, sysInfo As Object, msgPort As Object, assetPool As Object, systemTime As Object ) As Object

    NetworkingStateMachine = newHSM()
    NetworkingStateMachine.InitialPseudostateHandler = InitializeNetworkingStateMachine

	NetworkingStateMachine.player = player
	NetworkingStateMachine.diagnostics = diagnostics
	NetworkingStateMachine.logging = logging
	NetworkingStateMachine.diagnosticCodes = diagnosticCodes
	
	NetworkingStateMachine.sysInfo = sysInfo
	NetworkingStateMachine.msgPort = msgPort
	NetworkingStateMachine.assetPool = assetPool
	NetworkingStateMachine.systemTime = systemTime
	
    NetworkingStateMachine.POOL_EVENT_FILE_DOWNLOADED = 1
    NetworkingStateMachine.POOL_EVENT_FILE_FAILED = -1
    NetworkingStateMachine.POOL_EVENT_ALL_DOWNLOADED = 2
    NetworkingStateMachine.POOL_EVENT_ALL_FAILED = -2

    NetworkingStateMachine.EVENT_REALIZE_SUCCESS = 101

'	NetworkingStateMachine.LaunchRetryTimer	= LaunchRetryTimer

    NetworkingStateMachine.stTop = NetworkingStateMachine.newHState(NetworkingStateMachine, "Top")
    NetworkingStateMachine.stTop.HStateEventHandler = STTopEventHandler
    
    NetworkingStateMachine.stNetworkScheduler = NetworkingStateMachine.newHState(NetworkingStateMachine, "NetworkScheduler")
    NetworkingStateMachine.stNetworkScheduler.HStateEventHandler = STNetworkSchedulerEventHandler
	NetworkingStateMachine.stNetworkScheduler.superState = NetworkingStateMachine.stTop

    NetworkingStateMachine.stCheckingMacAddr = NetworkingStateMachine.newHState(NetworkingStateMachine, "CheckingMacAddr")
    NetworkingStateMachine.stCheckingMacAddr.HStateEventHandler = STCheckingMacAddrEventHandler
	NetworkingStateMachine.stCheckingMacAddr.superState = NetworkingStateMachine.stNetworkScheduler
	NetworkingStateMachine.stCheckingMacAddr.CheckMacAddr = CheckMacAddr

    NetworkingStateMachine.stGettingPublishmentVersionForClient = NetworkingStateMachine.newHState(NetworkingStateMachine, "GettingPublishmentVersionForClient")
    NetworkingStateMachine.stGettingPublishmentVersionForClient.HStateEventHandler = STGettingPublishmentVersionForClientEventHandler
	NetworkingStateMachine.stGettingPublishmentVersionForClient.superState = NetworkingStateMachine.stNetworkScheduler
	NetworkingStateMachine.stGettingPublishmentVersionForClient.GetPublishmentVersionForClient = GetPublishmentVersionForClient
	NetworkingStateMachine.stGettingPublishmentVersionForClient.ParseGetPublishmentVersionForClientXml = ParseGetPublishmentVersionForClientXml
	NetworkingStateMachine.stGettingPublishmentVersionForClient.RetrievePublishFile = RetrievePublishFile
	NetworkingStateMachine.stGettingPublishmentVersionForClient.UnpackPublishFile = UnpackPublishFile
	NetworkingStateMachine.stGettingPublishmentVersionForClient.GetFilesToDownload = GetFilesToDownload
	
    NetworkingStateMachine.stDownloadingContent = NetworkingStateMachine.newHState(NetworkingStateMachine, "DownloadingContent")
    NetworkingStateMachine.stDownloadingContent.HStateEventHandler = STDownloadingContentEventHandler
	NetworkingStateMachine.stDownloadingContent.superState = NetworkingStateMachine.stNetworkScheduler
	NetworkingStateMachine.stDownloadingContent.DownloadFile = DownloadFile

    NetworkingStateMachine.stWaitForTimeout = NetworkingStateMachine.newHState(NetworkingStateMachine, "WaitForTimeout")
    NetworkingStateMachine.stWaitForTimeout.HStateEventHandler = STWaitForTimeoutEventHandler
	NetworkingStateMachine.stWaitForTimeout.superState = NetworkingStateMachine.stNetworkScheduler

	NetworkingStateMachine.topState = NetworkingStateMachine.stTop
	
	return NetworkingStateMachine

End Function


Function InitializeNetworkingStateMachine() As Object

	m.channel = ParseXml()

    m.timeBetweenNetConnects% = 30

    m.networkDownloadTimer = CreateObject("roTimer")
    m.networkDownloadTimer.SetPort(m.msgPort)

	return m.stCheckingMacAddr
	
End Function


Function GetSoapContentType() As String
	return "text/xml; charset="+ chr(34) + "utf-8" + chr(34)
End Function


Function STNetworkSchedulerEventHandler(event As Object, stateData As Object) As Object

    stateData.nextState = invalid
    
    if type(event) = "roAssociativeArray" then      ' internal message event

        if IsString(event["EventType"]) then
        
            if event["EventType"] = "ENTRY_SIGNAL" then
            
                ' m.obj.diagnostics.PrintDebug(m.id$ + ": entry signal")
				print m.id$ + ": entry signal"

                return "HANDLED"

            else if event["EventType"] = "EXIT_SIGNAL" then

                ' m.obj.diagnostics.PrintDebug(m.id$ + ": exit signal")
				print m.id$ + ": exit signal"
            
'            else if event["EventType"] = "POST_IMPRESSION" then

'				bulletinId$ = event["BulletinId"]
'				m.PostImpression(bulletinId$)
'				return "HANDLED"

			endif
            
        endif
        
	endif
            
    stateData.nextState = m.superState
    return "SUPER"
    
End Function


Sub CheckMacAddr()

	url$ = "http://pixage.kocsistem.com.tr/dev30/ClientWS/Client.asmx"

	m.checkMacAddrXfer = CreateObject( "roUrlTransfer" )
	m.checkMacAddrXfer.SetTimeout( 30000 )
	m.checkMacAddrXfer.SetPort( m.stateMachine.msgPort )
	m.checkMacAddrXfer.SetUrl( url$ )

	if not m.checkMacAddrXfer.addHeader("SOAPACTION", "http://tempuri.org/CheckMacAddr") stop
	if not m.checkMacAddrXfer.addHeader( "Content-Type", GetSoapContentType() ) stop


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

	if not m.checkMacAddrXfer.AsyncMethod( aa ) then
		stop
	endif

End Sub


Function STCheckingMacAddrEventHandler(event As Object, stateData As Object) As Object

    stateData.nextState = invalid
    
    if type(event) = "roAssociativeArray" then      ' internal message event

        if IsString(event["EventType"]) then
        
            if event["EventType"] = "ENTRY_SIGNAL" then
			
                ' m.obj.diagnostics.PrintDebug(m.id$ + ": entry signal")
				print m.id$ + ": entry signal"
				m.CheckMacAddr()				
                return "HANDLED"

            else if event["EventType"] = "EXIT_SIGNAL" then

                ' m.obj.diagnostics.PrintDebug(m.id$ + ": exit signal")
				print m.id$ + ": exit signal"
            
			endif
            
        endif
     
'	else if type(event) = "roTimerEvent" then

'		sourceIdentity$ = stri(event.GetSourceIdentity())

'		if type( m.retryGetSoftwareManifestXferTimer ) = "roTimer" and sourceIdentity$ = stri(m.retryGetSoftwareManifestXferTimer.GetIdentity()) then
		
'			m.GetSoftwareManifest()				
'			return "HANDLED"
			
'		endif

    else if type(event) = "roUrlEvent" then
		if type (m.checkMacAddrXfer) = "roUrlTransfer" then
	        if event.GetSourceIdentity() = m.checkMacAddrXfer.GetIdentity() then
				if event.GetResponseCode() = 200 or event.GetResponseCode() = 0 then
					checkMacAddrResponse$ = event.GetString()
					stateData.nextState = m.stateMachine.stGettingPublishmentVersionForClient
					return "TRANSITION"
				else
					stop
				endif
			endif
		endif
    endif
            
    stateData.nextState = m.superState
    return "SUPER"
    
End Function


Sub GetPublishmentVersionForClient()

	url$ = "http://pixage.kocsistem.com.tr/dev30/ClientWS/Client.asmx"

	m.getPublishmentVersionForClientXfer = CreateObject( "roUrlTransfer" )
	m.getPublishmentVersionForClientXfer.SetTimeout( 30000 )
	m.getPublishmentVersionForClientXfer.SetPort( m.stateMachine.msgPort )
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
	m.getPublishFileXfer.SetPort( m.stateMachine.msgPort )
	m.getPublishFileXfer.SetUrl( url$ )

	' PIXAGETODO - make asynchronous
	rc = m.getPublishFileXfer.GetToFile("publish.zip")
	if rc <> 200 then stop

End Sub


Sub UnpackPublishFile()

	ok = CreateDirectory("xml")

	brightPackage = CreateObject("roBrightPackage", "publish.zip")
	brightPackage.unpack("SD:/xml")

End Sub


Function GetFilesToDownload(channel As Object)

	playlistFiles = []
	filesToDownload = []

	for each template in channel.templates
		for each frame in template.frames
			for each playlist in frame.playlists
				for each playlistFile in playlist.files
					playlistFiles.push(playlistFile)
				next
			next
		next
	next

	for each playlistFile in playlistFiles
		fileName = playlistFile.contentId + "#" + playlistFile.fileName
		filePath = "assets/" + fileName
		file = CreateObject("roReadFile", filePath)
		if type(file) = "roReadFile" then
			file.SeekToEnd()
			fileLength = file.CurrentPosition()
			if fileLength <> int(val(playlistFile.fileSize)) then
				filesToDownload.push(playlistFile)
			endif
		else
			filesToDownload.push(playlistFile)
		endif
	next

	return filesToDownload

End Function


Function STGettingPublishmentVersionForClientEventHandler(event As Object, stateData As Object) As Object

    stateData.nextState = invalid
    
    if type(event) = "roAssociativeArray" then      ' internal message event

        if IsString(event["EventType"]) then
        
            if event["EventType"] = "ENTRY_SIGNAL" then
			
                ' m.obj.diagnostics.PrintDebug(m.id$ + ": entry signal")
				print m.id$ + ": entry signal"
				m.GetPublishmentVersionForClient()				
                return "HANDLED"

            else if event["EventType"] = "EXIT_SIGNAL" then

                ' m.obj.diagnostics.PrintDebug(m.id$ + ": exit signal")
				print m.id$ + ": exit signal"
            
			endif
            
        endif
     
'	else if type(event) = "roTimerEvent" then

'		sourceIdentity$ = stri(event.GetSourceIdentity())

'		if type( m.retryGetSoftwareManifestXferTimer ) = "roTimer" and sourceIdentity$ = stri(m.retryGetSoftwareManifestXferTimer.GetIdentity()) then
		
'			m.GetSoftwareManifest()				
'			return "HANDLED"
			
'		endif

    else if type(event) = "roUrlEvent" then
		if type (m.getPublishmentVersionForClientXfer) = "roUrlTransfer" then
	        if event.GetSourceIdentity() = m.getPublishmentVersionForClientXfer.GetIdentity() then
				if event.GetResponseCode() = 200 or event.GetResponseCode() = 0 then

					getPublishmentVersionForClient$ = event.GetString()
					xmlVersion$ = m.ParseGetPublishmentVersionForClientXml( event )
					if xmlVersion$ <> m.stateMachine.channel.version then

						print "Versions are different - retrieve publish file"

						m.stateMachine.downloadXMLVersion = xmlVersion$

						m.RetrievePublishFile(xmlVersion$)
						m.UnpackPublishFile()
						m.stateMachine.channel = ParseXml()
						m.stateMachine.filesToDownload = m.GetFilesToDownload(m.stateMachine.channel)
						if m.stateMachine.filesToDownload.Count() > 0 then
							stateData.nextState = m.stateMachine.stDownloadingContent
						else

							print "No new assets to download - post message"

							' publishment file changed - no new assets to download
							contentUpdatedEvent = CreateObject("roAssociativeArray")
							contentUpdatedEvent["EventType"] = "CONTENT_UPDATED"
							m.stateMachine.msgPort.PostMessage(contentUpdatedEvent)

							stateData.nextState = m.stateMachine.stWaitForTimeout
							m.stateMachine.channel.version = xmlVersion$
						endif

						return "TRANSITION"					
					endif

					print "Versions are the same - wait for next timeout"

					stateData.nextState = m.stateMachine.stWaitForTimeout
					return "TRANSITION"
				else
					stop
				endif
			endif
		endif
    endif
            
    stateData.nextState = m.superState
    return "SUPER"
    
End Function


Sub DownloadFile(playlistFile)

	url$ = "http://pixage.kocsistem.com.tr/dev30/uploaderws/files/" + playlistFile.contentId + ".pxc"

	m.downloadFileXfer = CreateObject( "roUrlTransfer" )
	m.downloadFileXfer.SetTimeout( 300000 )
	m.downloadFileXfer.SetPort( m.stateMachine.msgPort )
	m.downloadFileXfer.SetUrl( url$ )

	targetFile = "assets/" + playlistFile.contentId + "#" + playlistFile.fileName

	print "download from " + url$ + " to " + targetFile

	rc = m.downloadFileXfer.AsyncGetToFile(targetFile)
	if rc <> 200 then stop

End Sub


Function STDownloadingContentEventHandler(event As Object, stateData As Object) As Object

    stateData.nextState = invalid
    
    if type(event) = "roAssociativeArray" then      ' internal message event

        if IsString(event["EventType"]) then
        
            if event["EventType"] = "ENTRY_SIGNAL" then
            
                ' m.obj.diagnostics.PrintDebug(m.id$ + ": entry signal")
				print m.id$ + ": entry signal"

				playlistFile = m.stateMachine.filesToDownload.Shift()
				m.DownloadFile(playlistFile)

                return "HANDLED"

            else if event["EventType"] = "EXIT_SIGNAL" then

                ' m.obj.diagnostics.PrintDebug(m.id$ + ": exit signal")
				print m.id$ + ": exit signal"
            
			endif
            
        endif
        
    else if type(event) = "roUrlEvent" then

		if type (m.downloadFileXfer) = "roUrlTransfer" then
	        if event.GetSourceIdentity() = m.downloadFileXfer.GetIdentity() then
				if event.GetResponseCode() = 200 or event.GetResponseCode() = 0 then
					print "url xfer complete - responseCode = " + stri(event.GetResponseCode())
					if m.stateMachine.filesToDownload.Count() = 0 then

						print "all files successfully downloaded"

						contentUpdatedEvent = CreateObject("roAssociativeArray")
						contentUpdatedEvent["EventType"] = "CONTENT_UPDATED"
						m.stateMachine.msgPort.PostMessage(contentUpdatedEvent)

						stateData.nextState = m.stateMachine.stWaitForTimeout
						return "TRANSITION"
					else
						playlistFile = m.stateMachine.filesToDownload.Shift()
						m.DownloadFile(playlistFile)
					endif
				else
					print "file download error"
stop
					' try next file
					if m.stateMachine.filesToDownload.Count() = 0 then
						stop
					else
						playlistFile = m.stateMachine.filesToDownload.Shift()
						m.DownloadFile(playlistFile)
					endif
				endif
			endif
		endif

    endif
            
    stateData.nextState = m.superState
    return "SUPER"
    
End Function


Function STWaitForTimeoutEventHandler(event As Object, stateData As Object) As Object

    stateData.nextState = invalid
    
    if type(event) = "roAssociativeArray" then      ' internal message event

        if IsString(event["EventType"]) then
        
            if event["EventType"] = "ENTRY_SIGNAL" then
            
                ' m.obj.diagnostics.PrintDebug(m.id$ + ": entry signal")
				print m.id$ + ": entry signal"

				m.stateMachine.networkDownloadTimer.SetElapsed(m.stateMachine.timeBetweenNetConnects%, 0)
				m.stateMachine.networkDownloadTimer.Start()

                return "HANDLED"

            else if event["EventType"] = "EXIT_SIGNAL" then

                ' m.obj.diagnostics.PrintDebug(m.id$ + ": exit signal")
				print m.id$ + ": exit signal"
            
			endif
            
        endif
        
    else if type(event) = "roTimerEvent" then
    
        if type(m.stateMachine.networkDownloadTimer) = "roTimer" then
        
            if stri(event.GetSourceIdentity()) = stri(m.stateMachine.networkDownloadTimer.GetIdentity()) then			
				stateData.nextState = m.stateMachine.stGettingPublishmentVersionForClient
		        return "TRANSITION"
			endif
		    
		endif

    endif
            
    stateData.nextState = m.superState
    return "SUPER"
    
End Function


Sub AddFileToDownload( assetsToDownload As Object, fileName$ As String, hash$ As String )

'	m.obj.diagnostics.PrintDebug( "Updated script file: " + fileName$)
'	m.stateMachine.logging.WriteDiagnosticLogEntry( m.stateMachine.diagnosticCodes.GET_UPDATED_FILE, fileName$ )
	
	asset = {}
	asset.name = fileName$
	asset.link = GetSWUpdateBaseURL() + fileName$
	asset.hash = "sha1:" + hash$
	assetsToDownload.push( asset )

End Sub

