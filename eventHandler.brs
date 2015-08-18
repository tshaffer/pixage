Function newEventHandler(diagnostics As Object, msgPort As Object) As Object

	EventHandler = {}

	EventHandler.diagnostics = diagnostics
	EventHandler.msgPort = msgPort

	EventHandler.hsms = []

	EventHandler.AddHSM				= eventHandler_AddHSM
	EventHandler.EventLoop			= eventHandler_EventLoop

	return EventHandler

End Function


Sub eventHandler_AddHSM( hsm As Object )

	m.hsms.push( hsm )

End Sub


Sub eventHandler_EventLoop()

    while true
        
        msg = wait(0, m.msgPort)

'		m.diagnostics.PrintTimestamp()
'		m.diagnostics.PrintDebug("msg received - type=" + type(msg))
		print "msg received - type=" + type(msg)
'		if type(msg) = "roVideoEvent" then
'			stop
'		endif

		numHSMs% = m.hsms.Count()
		for i% = 0 to numHSMs% - 1
			m.hsm = m.hsms[i%]
			m.hsm.Dispatch(msg)
		next

	end while

End Sub


