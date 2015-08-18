Function newDisplayEngine(player As Object, eventHandler As Object, diagnostics As Object, logging As Object, diagnosticCodes As Object, msgPort As Object, assetPool As Object) As Object

    DisplayEngine = newHSM()
    DisplayEngine.InitialPseudostateHandler = InitializeDisplayEngine

	DisplayEngine.msgPort = msgPort

    DisplayEngine.stTop = DisplayEngine.newHState(DisplayEngine, "Top")
    DisplayEngine.stTop.HStateEventHandler = STTopEventHandler
    
    DisplayEngine.stWaitingForInitialContent = DisplayEngine.newHState(DisplayEngine, "WaitingForInitialContent")
    DisplayEngine.stWaitingForInitialContent.HStateEventHandler = STWaitingForInitialContentEventHandler
	DisplayEngine.stWaitingForInitialContent.superState = DisplayEngine.stTop

    DisplayEngine.stWaitingForUpdatedContent = DisplayEngine.newHState(DisplayEngine, "WaitingForUpdatedContent")
    DisplayEngine.stWaitingForUpdatedContent.HStateEventHandler = STWaitingForUpdatedContentEventHandler
	DisplayEngine.stWaitingForUpdatedContent.superState = DisplayEngine.stTop
	DisplayEngine.stWaitingForUpdatedContent.BuildContentList = BuildContentList
	DisplayEngine.stWaitingForUpdatedContent.DisplayItem = DisplayItem
	DisplayEngine.stWaitingForUpdatedContent.PlayVideo = PlayVideo
	DisplayEngine.stWaitingForUpdatedContent.DisplayImage = DisplayImage

	DisplayEngine.topState = DisplayEngine.stTop

	return DisplayEngine

End Function


Function InitializeDisplayEngine() As Object

	r = CreateObject("roRectangle", 0, 0, 1920, 1080)

	m.imagePlayer = CreateObject("roImageWidget", r)
	m.imagePlayer.StopDisplay()

	m.videoPlayer = CreateObject("roVideoPlayer")
	m.videoPlayer.SetRectangle(r)
	m.videoPlayer.ToFront()
	m.videoPlayer.SetPort(m.msgPort)
	m.videoPlayer.StopClear()

	m.channel = ParseXml()
	if type(m.channel) = "roAssociativeArray" then
		return m.stWaitingForUpdatedContent
	else
	    return m.stWaitingForInitialContent
	endif

End Function


Sub BuildContentList()

	m.playlistFiles = []

	for each template in m.stateMachine.channel.templates
		for each frame in template.frames
			for each playlist in frame.playlists
				for each playlistFile in playlist.files
					m.playlistFiles.push(playlistFile)
				next
			next
		next
	next

End Sub


Function STWaitingForInitialContentEventHandler(event As Object, stateData As Object) As Object

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
            
            else if event["EventType"] = "CONTENT_UPDATED" then

                ' new content was downloaded from the network
'                m.obj.diagnostics.PrintDebug("STWaitingForInitialContentEventHandler - CONTENT_UPDATED")
'				m.obj.logging.WriteDiagnosticLogEntry( m.obj.diagnosticCodes.SWITCHING_TO_NEW_CONTENT, "" )

'				channelSpecification = event["ChannelSpecification"]
'				assetPoolFiles = event["AssetPoolFiles"]

'				m.stateMachine.SetupDisplay(channelSpecification, assetPoolFiles)

'      			stateData.nextState = m.stateMachine.stWaitingForUpdatedContent
'				return "TRANSITION"

			endif
            
        endif
        
    endif
            
    stateData.nextState = m.superState
    return "SUPER"
    
End Function


Function STWaitingForUpdatedContentEventHandler(event As Object, stateData As Object) As Object

    stateData.nextState = invalid
    
    if type(event) = "roAssociativeArray" then      ' internal message event

        if IsString(event["EventType"]) then
        
            if event["EventType"] = "ENTRY_SIGNAL" then
            
                ' m.obj.diagnostics.PrintDebug(m.id$ + ": entry signal")
				print m.id$ + ": entry signal"

				m.BuildContentList()
				m.displayIndex = 0
				m.DisplayItem()

                return "HANDLED"

            else if event["EventType"] = "EXIT_SIGNAL" then

                ' m.obj.diagnostics.PrintDebug(m.id$ + ": exit signal")
				print m.id$ + ": exit signal"

            else if event["EventType"] = "CONTENT_UPDATED" then
                ' new content was downloaded from the network
'               m.obj.diagnostics.PrintDebug("STWaitingForInitialContentEventHandler - CONTENT_UPDATED")
'				m.obj.logging.WriteDiagnosticLogEntry( m.obj.diagnosticCodes.SWITCHING_TO_NEW_CONTENT, "" )

				m.stateMachine.channel = ParseXml()
				m.BuildContentList()

				m.displayIndex = 0
				m.DisplayItem()

                return "HANDLED"

			endif
            
        endif

    else if type(event) = "roVideoEvent" and event.GetInt() = 8 then
		m.displayIndex = m.displayIndex + 1
		if m.displayIndex >= m.playlistFiles.Count() then
			m.displayIndex = 0
		endif
		m.DisplayItem()
	
	else if type(event) = "roTimerEvent"
        if type(m.displayTimer) = "roTimer" and stri(event.GetSourceIdentity()) = stri(m.displayTimer.GetIdentity()) then
			m.displayIndex = m.displayIndex + 1
			if m.displayIndex >= m.playlistFiles.Count() then
				m.displayIndex = 0
			endif
			m.DisplayItem()
        endif
	 
	endif
            
    stateData.nextState = m.superState
    return "SUPER"
    
End Function


Function GetFilePath(item As Object) As String

	filePath = "assets/" + item.contentId + "#" + item.fileName
	return filePath

End Function


Function DisplayImage(item As Object)

	filePath = GetFilePath(item)
	ok = m.stateMachine.imagePlayer.DisplayFile(filePath)
	m.stateMachine.videoPlayer.StopClear()

	if type(m.displayTimer) <> "roTimer" then
	    m.displayTimer = CreateObject("roTimer")
		m.displayTimer.SetPort(m.stateMachine.msgPort)
	endif

	m.displayTimer.SetElapsed(int(val(item.duration)), 0)
    m.displayTimer.Start()

End Function


Function PlayVideo(item As Object)

	filePath = GetFilePath(item)
	ok = m.stateMachine.videoPlayer.PlayFile(filePath)
	ok = m.stateMachine.imagePlayer.StopDisplay()

End Function


Sub DisplayItem()

	item = m.playlistFiles[m.displayIndex]

	ext = GetFileExtension(item.fileName)
	if ext <> invalid then
		if IsVideo(ext) then
			m.PlayVideo(item)
		else if IsImage(ext) then
			m.DisplayImage(item)
		endif
	endif

End Sub


Function GetFileExtension(file as String) as Object
  s=file.tokenize(".")
  if s.Count()>1
    ext=s.pop()
    return ext
  end if
  return invalid
end Function


Function IsVideo(ext As String) As Boolean

	if ext = "mp4" return true
	if ext = "mpg" return true
	if ext = "ts" return true
	if ext = "mov" return true

End Function


Function IsImage(ext As String) As Boolean

	if ext = "jpg" return true
	if ext = "png" return true

End Function


