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


