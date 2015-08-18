Function newDisplayEngine(player As Object, eventHandler As Object, diagnostics As Object, logging As Object, diagnosticCodes As Object, msgPort As Object, assetPool As Object) As Object

    DisplayEngine = newHSM()
    DisplayEngine.InitialPseudostateHandler = InitializeDisplayEngine

    DisplayEngine.stTop = DisplayEngine.newHState(DisplayEngine, "Top")
    DisplayEngine.stTop.HStateEventHandler = STTopEventHandler
    
    DisplayEngine.stWaitingForInitialContent = DisplayEngine.newHState(DisplayEngine, "WaitingForInitialContent")
    DisplayEngine.stWaitingForInitialContent.HStateEventHandler = STWaitingForInitialContentEventHandler
	DisplayEngine.stWaitingForInitialContent.superState = DisplayEngine.stTop

    DisplayEngine.stWaitingForUpdatedContent = DisplayEngine.newHState(DisplayEngine, "WaitingForUpdatedContent")
    DisplayEngine.stWaitingForUpdatedContent.HStateEventHandler = STWaitingForUpdatedContentEventHandler
	DisplayEngine.stWaitingForUpdatedContent.superState = DisplayEngine.stTop

	DisplayEngine.topState = DisplayEngine.stTop

	return DisplayEngine

End Function


Function InitializeDisplayEngine() As Object

	m.channel = ParseXml()
	if type(m.channel) = "roAssociativeArray" then
		return m.stWaitingForUpdatedContent
	else
	    return m.stWaitingForInitialContent
	endif

'	channelData$ = ReadAsciiFile("channelData.json")

'	if channelData$ = "" then

'	    return m.stWaitingForInitialContent

'	else

'		m.player.channelSpecification = ParseJSON(channelData$)

'		files = BuildDownloadList( m.player.channelSpecification )
 '       assetCollection = BuildAssetCollection( files )
	'	assetPoolFiles = CreateObject("roAssetPoolFiles", m.assetPool, assetCollection)

	'	m.SetupDisplay(m.player.channelSpecification, assetPoolFiles)

	'	return m.stWaitingForUpdatedContent

	'endif

End Function


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


