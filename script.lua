local IsSynapse = is_synapse_function and is_synapse_function((function() end))
local required_funcs = {
    isfile = isfile,
    readfile = readfile,
    writefile = writefile,
}
for I, required in next, required_funcs do
    if type(required) ~= 'function' then
        error(I .. ' is not a function, this script requires ' .. I, 2)
    end
end
local required_tables = {
    Drawing = Drawing
}
for I, required in next, required_tables do
    if type(required) ~= 'table' then
        error(I .. ' is not a table, this script requires ' .. I, 2)
    end
end

if shared.__UAnEv1__ then
	shared.__UAnEv1__.STOP()
end

local httpget = game.HttpGet
local function httpload(url)
    return loadstring(httpget(game, url))()
end
local function httpassert(url, msg)
    return assert(httpload(url), msg)
end

local function DoesDrawingExist(Drawing)
    if IsSynapse then
        return type(Drawing) == 'table' and rawget(Drawing, '__OBJECT_EXISTS')
    else
        return true
    end
end
local function DoesObjectExist(Object)
    return Object and type(Object) == 'table' and Object.Drawing and DoesDrawingExist(Object.Drawing)
end
local function waitforchild(Parent, Name)
    repeat wait() until Parent:FindFirstChild(Name)
    return Parent[Name]
end

local getservice 		=    game.GetService
local Camera 			=	 workspace.CurrentCamera
local worldtoviewportpoint = Camera.WorldToViewportPoint
local UserInputService 	=	 getservice(game, 'UserInputService')
local RunService 		=	 getservice(game, 'RunService')

local wait = function(t)if t then return wait(t) end;return RunService.Heartbeat:Wait()end

local vector2new 		=   Vector2.new
local function Vector3ToVector2(Vector)
	return vector2new(Vector.X, Vector.Y)
end
local function JustX(Vector)
    if typeof(Vector) == 'Vector2' then
        return Vector2.new(Vector.X, 0)
    elseif typeof(Vector) == 'Vector3' then
        return Vector3.new(Vector.X, 0, 0)
    end
end
local function JustY(Vector)
    if typeof(Vector) == 'Vector2' then
        return Vector2.new(0, Vector.Y)
    elseif typeof(Vector) == 'Vector3' then
        return Vector3.new(0, Vector.Y, 0)
    end
end
local function JustZ(Vector)
    return Vector3.new(0, 0, Vector.Z)
end

local function FlatY(Vector)
    if typeof(Vector) == 'Vector2' then
        return Vector2.new(Vector.X, 0)
    elseif typeof(Vector) == 'Vector3' then
        return Vector3.new(Vector.X, 0, Vector.Z)
    end
end

local function round(number, place)
    local split = tostring(number):split('.')
    local first = split[1]
    local second = split[2]

    return tonumber(first .. ((second and '.' .. second:sub(1, place)) or ''))
end
local function getname(Player)
    if Player and Player.Name and Player.DisplayName then
        local Name, DisplayName = Player.Name, Player.DisplayName
        if DisplayName ~= Name then
            return Name .. ' (@' .. DisplayName .. ')'
        end
        return Name
    end
end

local table = httpassert('https://raw.githubusercontent.com/TechHog8984/TechHub-V3/main/script/misc/custom%20table.lua', 'Failed to get custom table.')

local IsPartVisible 		= 	 httpassert('https://raw.githubusercontent.com/TechHog8984/TechHub-V3/main/script/misc/ispartvisible.lua', 'failed to get ispartvisible function')
local EventManager 			= 	 httpassert('https://raw.githubusercontent.com/TechHog8984/TechHub-V3/main/script/misc/events.lua', 'failed to get event manager')

local PlayerService     	=    getservice(game, 'Players')
local LocalPlayer 			=	 PlayerService.LocalPlayer
local LocalCharacter 		=	 nil
local Mouse 				=	 LocalPlayer:GetMouse()

local placeid = game.PlaceId
local __UAnEv1__ = {
	Active = true,

	Connections = {},
	Config = {
		Aimbot = true,
		TeamCheck = true,

		AimbotHoldKey = Enum.UserInputType.MouseButton2,
		AimbotPart = 'Head',

		Names       =   true,
        Distance    =   true,
        Boxes       =   true,
        Tracers     =   true,
        HealthBars  =   false,
        Skeleton    =   true,

        BaseColor       =   Color3.new(1, 1, 1),
        NameColor       =   nil,
        DistanceColor   =   nil,
        BoxesColor      =   nil,
        TracersColor    =   nil,
        -- HealthBarsColor =   nil,
        SkeletonColor   =   nil,

        BaseRainbow     =   false,

        BoxType = 2,
	},

	Games = {
		Arsenal = placeid == 286090429,
        BadBusiness = placeid == 3233893879,
	},

	Drawings = {},
	Objects = {},
	PlayerEspObjects = {},
}

local BBPlayersTable, BBCharactersTable, BBTeamsTable;
if __UAnEv1__.Games.BadBusiness then
    httpload('https://raw.githubusercontent.com/TechHog8984/misc-scripts/main/Bad%20Business%20Character%20Spoofer.lua');
    local Collection = getgc(true);
    for I,V in next, Collection do
        if type(V) ~= 'table' then
            rawset(Collection, I, nil);
        end;
    end;

    for I, Table in next, Collection do
        if rawget(Table, 'GetCharacter') then
            BBPlayersTable = Table;
            break;
        end;
    end;
    for I, Table in next, Collection do
        if rawget(Table, 'SetTeamColor') then
            BBTeamsTable = Table;
            break;
        end;
    end;

    BBCharactersTable = getupvalue(BBPlayersTable.GetCharacter, 1);
end;

local Configs = httpassert('https://raw.githubusercontent.com/TechHog8984/Configclass/main/Class.lua', 'Failed to get config handler')

local before = isfile('UAnEv1/main.config')
local Config = Configs:Config{path = 'UAnEv1/main.config'}
if not before then
    for I,V in next, __UAnEv1__.Config do
        Config[I] = V
    end
end
__UAnEv1__.Config = Config

local drawingnew = Drawing.new
local function CreateDrawing(info)
	if not __UAnEv1__ or not __UAnEv1__.Active then return end
    local TYPE = info.type or 'Square'
    info.type = nil

    local Drawing = drawingnew(TYPE)

    for I,V in next, info do
        Drawing[I] = V
    end

    table.insert(__UAnEv1__.Drawings, Drawing)

    return Drawing
end
local function CreateObject(info)
	if not __UAnEv1__ or not __UAnEv1__.Active then return end
    local Object = {}

    for I, V in next, info do
        Object[I] = V
    end

    function Object:Remove()
        if Object.Drawing and DoesDrawingExist(Object.Drawing) == true then
            Object.Drawing:Remove()
        end
        Object.Drawing = nil
        table.remove(__UAnEv1__.Objects, Object)
        Object = nil
    end

    table.insert(__UAnEv1__.Objects, Object)
    return Object
end

local EventManager      =   httpassert('https://raw.githubusercontent.com/TechHog8984/TechHub-V3/main/script/misc/events.lua', 'failed to get event manager')

local PlayersHandler    =   {Connections = {}, Players = {}, PlayerAdded = EventManager:CreateEvent('PlayerAdded'), PlayerRemoving = EventManager:CreateEvent('PlayerRemoving')} do 

    local function PlayerAdded(Player)
        if Player then
            local Handle = {}

            Handle.CharacterAdded = EventManager:CreateEvent(Player.Name .. ' - CharacterAdded')
            Handle.CharacterRemoved = EventManager:CreateEvent(Player.name .. ' - CharacterRemoved')
            Handle.HumanoidAdded = EventManager:CreateEvent(Player.Name .. ' - HumanoidAdded')
            Handle.HumanoidRemoved = EventManager:CreateEvent(Player.Name .. ' - HumanoidRemoved')
            Handle.HumanoidRootPartAdded = EventManager:CreateEvent(Player.Name .. ' - HumanoidRootPartAdded')
            Handle.HumanoidRootPartRemoved = EventManager:CreateEvent(Player.Name .. ' - HumanoidRootPartRemoved')

            local function PartRemoved(Part)
                if Part then
                    local Name = Part.Name or Part
                    if Name == 'Humanoid' then
                        Handle.HumanoidRemoved:Fire()
                    elseif Name == 'HumanoidRootPart' then
                        Handle.HumanoidRootPartRemoved:Fire()
                    end
                end
            end

            local function PartAdded(Part)
                if Part then
                    local Name = Part.Name or Part
                    if Name == 'Humanoid' then
                        Handle.HumanoidAdded:Fire()
                    elseif Name == 'HumanoidRootPart' then
                        Handle.HumanoidRootPartAdded:Fire()
                    end
                end
            end

            local function CharacterRemoved()
                PartRemoved('Humanoid')
                PartRemoved('HumanoidRootPart')
                if Handle.CharacterRemoved then
                    Handle.CharacterRemoved:Fire()
                end
                Handle.Character = nil
                if Handle.CharacterRemovedConnection then
                    Handle.CharacterRemovedConnection:Disconnect()
                end
                if Handle.PartAddedConnection then
                    Handle.PartAddedConnection:Disconnect()
                end
                if Handle.PartRemovedConnection then
                    Handle.PartRemovedConnection:Disconnect()
                end
            end

            local function CharacterAdded(Character)
                if Character then
                    Handle.Character = Character
                    Handle.CharacterAdded:Fire(Character)
                    
                    local PartAddedConnection = Character.ChildAdded:Connect(PartAdded)
                    local PartRemovedConnection = Character.ChildRemoved:Connect(PartRemoved)
                    
                    Handle.PartAddedConnection = PartAddedConnection
                    Handle.PartRemovedConnection = PartRemovedConnection
                    
                    if not __UAnEv1__.Games.BadBusiness then
                        local CharacterRemovedConnection = waitforchild(Character, 'Humanoid').Died:Connect(CharacterRemoved)
                        Handle.CharacterRemovedConnection = CharacterRemovedConnection
                        table.insert(PlayersHandler.Connections, CharacterRemovedConnection)


                        PartAdded(Character:FindFirstChild'Humanoid' or nil)
                        PartAdded(Character:FindFirstChild'HumanoidRootPart' or nil)
                    end;

                    table.insert(PlayersHandler.Connections, PartAddedConnection)
                    table.insert(PlayersHandler.Connections, PartRemovedConnection)
                end
            end

            function Handle.GetCharacter()
                if __UAnEv1__.Games.BadBusiness and BBCharactersTable then
                    return BBCharactersTable[Player];
                end;
                return Handle.Character or Player.Character or Player.CharacterAdded:Wait()
            end

            function Handle.GetPart(part)
                local Character = Handle.GetCharacter();
                return (Character and (Character:FindFirstChild(part)));
            end
            function Handle.GetParts(...)
                local parts = {}

                for I, part in next, ({...}) do
                    parts[I] = Handle.GetPart(part)
                end

                return unpack(parts)
            end

            function Handle:Stop()
                Handle.CharacterAdded:DisconnectAll()
                Handle.CharacterRemoved:DisconnectAll()
                Handle.HumanoidAdded:DisconnectAll()
                Handle.HumanoidRemoved:DisconnectAll()
                Handle.HumanoidRootPartAdded:DisconnectAll()
                Handle.HumanoidRootPartRemoved:DisconnectAll()
            end

            CharacterAdded(Handle.GetCharacter())

            local CharacterAddedConnection = Player.CharacterAdded:connect(CharacterAdded)
            CharacterAddedConnection = CharacterAddedConnection

            table.insert(PlayersHandler.Connections, CharacterAddedConnection)

            PlayersHandler.Players[Player] = Handle

            Handle.Loaded = true

            PlayersHandler.PlayerAdded:Fire(Player, Handle)
        end
    end
    local function PlayerRemoved(Player)
        if Player and Player ~= LocalPlayer and PlayersHandler.Players[Player] then
            local Handle = PlayersHandler.Players[Player]

            PlayersHandler.PlayerRemoving:Fire(Player, Handle)

            PlayersHandler.Players[Player] = nil
            Handle = nil
        end
    end

    for Index, Player in next, PlayerService:GetPlayers() do
        PlayerAdded(Player)
    end

    table.insert(PlayersHandler.Connections, PlayerService.PlayerAdded:Connect(PlayerAdded))
    table.insert(PlayersHandler.Connections, PlayerService.PlayerRemoving:Connect(PlayerRemoved))

    function PlayersHandler:Stop()
        for I, Connection in next, PlayersHandler.Connections do
            if Connection then
                Connection:Disconnect()
            end
        end

        for Player, Handle in next, PlayersHandler.Players do
            Handle:Stop()
        end

        PlayersHandler.PlayerAdded:DisconnectAll()
        PlayersHandler.PlayerRemoving:DisconnectAll()
    end
end

local Players = PlayersHandler.Players
local LocalHandle = nil
repeat wait() LocalHandle = Players[LocalPlayer] until LocalPlayer and Players[LocalPlayer]

local function gethealth(Player)
    local Handle = Players[Player]
    if __UAnEv1__ and __UAnEv1__.Active then
        if __UAnEv1__.Games.Arsenal and Player:FindFirstChild'NRPBS' then
            return Player.NRPBS:WaitForChild('Health', math.huge).Value, Player.NRPBS:WaitForChild('MaxHealth', math.huge).Value;
        end;
    end
    if Handle then
        local Humanoid = Handle.GetPart('Humanoid')
        if Humanoid then
            return Humanoid.Health, Humanoid.MaxHealth
        end
    end
    return nil
end

local function AllowedTeam(Player)
	if __UAnEv1__ and __UAnEv1__.Active and __UAnEv1__.Config.TeamCheck then
        if __UAnEv1__.Games.BadBusiness then
            return not BBTeamsTable:ArePlayersFriendly(Player, LocalPlayer);
        end;
		if Player.Team and LocalPlayer.Team then
			return Player.Team ~= LocalPlayer.Team
		end
	end
	return true
end

local function GetPlayerFromPart(Part)
	for Player, Handle in next, Players do
		if Player and Player ~= LocalPlayer then
			local Character = Handle.GetCharacter()
			if Character and Part:IsDescendantOf(Character) then
				return Player
			end
		end
	end
end

local function GetClosestPlayerToCursor()
	--check if the Target property of Mouse is not nil
	if Mouse.Target then
		--Mouse.Target is the part that the mouse is hovering over.
		--So, we get the player from Mouse.Target
		local Player = GetPlayerFromPart(Mouse.Target)
		--if it can find the player from Mouse.Target and its team and health are valid, then return the player
		if Player and AllowedTeam(Player) and (gethealth(LocalPlayer)) > 0 then return Player end
	end

	local ClosestPlayer = nil

	local MaxDist = math.huge

	--loop through the players
	for Player, Handle in next, Players do
		--check if this player exists, is not the localplayer, and its team is allowed
        local LPHealth = (gethealth(LocalPlayer));
		if Player and Player ~= LocalPlayer and AllowedTeam(Player) and LPHealth and LPHealth > 0 then
			--get the character of the localplayer and its HumanoidRootPart
			LocalCharacter = LocalHandle.GetCharacter()
			local LocalHumanoidRootPart = LocalHandle.GetPart('HumanoidRootPart')

			--check if it exists
			if LocalHumanoidRootPart then
				--get the player's character and its HumanoidRootPart
				local Character = Handle.GetCharacter()
				local HumanoidRootPart = Handle.GetPart('HumanoidRootPart')

				--check if it exists and if it is visible
				if HumanoidRootPart and (gethealth(Player)) > 0 and IsPartVisible(HumanoidRootPart, Character) then
					--check if there already is a closestplayer
					if ClosestPlayer then
						--get the mouse position
						local MousePos = Vector2.new(Mouse.X, Mouse.Y)
						--get the screen position and whether or not the humanoidrootpart is on screen
						local ScreenPos, Onscreen = worldtoviewportpoint(Camera, HumanoidRootPart.Position)

						--check if it is onscreen (basic visible check)
						if Onscreen then
							--get the distance of the player to the cursor
							local Distance = (MousePos - Vector3ToVector2(ScreenPos)).Magnitude
							--check if the distance is less than the distance of the current closestplayer
							if Distance < MaxDist then
								--if so, then set the max distance to this and then set the closestplayer to this player
								MaxDist = Distance
								ClosestPlayer = Player
							end
						end
					else
						--if there isnt, then set it to this player
						ClosestPlayer = Player
					end
				end
			end
		end
	end

	--return the closestplayer
	return ClosestPlayer
end

local function PlayerAdded(Player, Handle)
    if not __UAnEv1__ or not __UAnEv1__.Active then return end
    local NameObject = CreateObject{
        Drawing = CreateDrawing{type = 'Text',
            Color = __UAnEv1__.Config.NameColor or __UAnEv1__.Config.BaseColor,
            Text = Player.Name,
            Size = 18,
            Center = true,
            Outline = true,
            OutlineColor = Color3.new(0, 0, 0),
            Font = Drawing.Fonts.Monospace,
        }
    }
    local TracerObject = CreateObject{
        Drawing = CreateDrawing{type = 'Line',
            Color = __UAnEv1__.Config.TracersColor or __UAnEv1__.Config.BaseColor,
            Thickness = 3,
        }
    }
    local BoxObject = CreateObject{
        Drawing = CreateDrawing{
            Color = __UAnEv1__.Config.BoxesColor or __UAnEv1__.Config.BaseColor,
            Thickness = 3,
        }
    }
    local HealthLineObjectRed = CreateObject{
        Drawing = CreateDrawing{type = 'Line',
            -- Color = __UAnEv1__.Config.HealthBarsColor or __UAnEv1__.Config.BaseColor,
            Color = Color3.new(1, 0, 0),
            Thickness = 3,
        }
    }
    local HealthLineObjectGreen = CreateObject{
        Drawing = CreateDrawing{type = 'Line',
            -- Color = __UAnEv1__.Config.HealthBarsColor or __UAnEv1__.Config.BaseColor,
            Color = Color3.new(0, 1, 0),
            Thickness = 3,
            ZIndex = 1,
        }
    }
    local DistanceObject = CreateObject{
        Drawing = CreateDrawing{type = 'Text',
            Color = __UAnEv1__.Config.DistanceColor or __UAnEv1__.Config.BaseColor,
            Text = '0',
            Size = 16,
            Center = true,
            Outline = true,
            OutlineColor = Color3.new(0, 0, 0),
            Font = Drawing.Fonts.Monospace,
        }
    }
    local Skeleton = {}

    for I, V in next, {'HeadToTorso', 'TorsoToLeftShoulder', 'TorsoToRightShoulder', 'LeftShoulderToLeftUpperArm', 'LeftShoulderToLeftArm', 'RightShoulderToRightUpperArm', 'RightShoulderToRightArm', 'LeftShoulderToLeftLowerArm', 'RightShoulderToRightLowerArm', 'TorsoToLeftHip', 'TorsoToRightHip', 'LeftHipToLeftLeg', 'LeftHipToLeftUpperLeg', 'RightHipToRightUpperLeg', 'RightHipToRightLeg', 'LeftHipToLeftLowerLeg', 'RightHipToRightLowerLeg'} do
        Skeleton[V] = CreateObject{
            Drawing = CreateDrawing{type = 'Line',
                Color = __UAnEv1__.Config.SkeletonColor or __UAnEv1__.Config.BaseColor,
                Thickness = 3,
            }
        }
    end

    function Skeleton:Remove()
        for I, V in next, Skeleton do
            if DoesObjectExist(V) then
                V:Remove()
            end
        end
        Skeleton = nil
    end
    local Box2 = {}

    for I,V in next, {'BL1', 'BL2', 'BL3', 'BL4'} do
        Box2[V] = CreateObject{
            Drawing = CreateDrawing{type = 'Line',
                Color = __UAnEv1__.Config.BoxesColor or __UAnEv1__.Config.BaseColor,
                Thickness = 3,
            }
        }
    end

    function Box2:Remove()
        for I, V in next, Box2 do
            if DoesObjectExist(V) then
                V:Remove()
            end
        end
        Box2 = nil
    end

    local Box3 = CreateObject{
        Drawing = CreateDrawing{type = 'Quad',
            Color = __UAnEv1__.Config.BoxesColor or __UAnEv1__.Config.BaseColor,
            Thickness = 3,
        }
    }

    local Esp = {
        Name = NameObject,
        Tracer = TracerObject,
        Box = BoxObject,
        HealthLineRed = HealthLineObjectRed,
        HealthLineGreen = HealthLineObjectGreen,
        Distance = DistanceObject,
        Box3 = Box3,

        Iterables = {
            Skeleton = Skeleton,
            Box2 = Box2,
        }
    }

    __UAnEv1__.PlayerEspObjects[Player] = Esp
end
local function PlayerRemoved(Player, Handle)
    if not __UAnEv1__ or not __UAnEv1__.Active then return end
    local EspObjects = __UAnEv1__.PlayerEspObjects[Player]
    if EspObjects then
        for I, Object in next, EspObjects do
            if DoesObjectExist(Object) then
                Object:Remove()
            end
        end
        if EspObjects.Iterables then
            for I, Iterable in next, EspObjects.Iterables do
                for I, Object in next, Iterable do
                    if DoesObjectExist(Object) then
                        Object:Remove()
                    end
                end
            end
        end
    end

    table.removebyindex(__UAnEv1__.PlayerEspObjects, Player)
end
PlayersHandler.PlayerAdded:Connect(PlayerAdded)
for Player, Handle in next, Players do
    PlayerAdded(Player, Handle)
end
PlayersHandler.PlayerRemoving:Connect(PlayerRemoved)

local function IsDown(EnumItem)
	return (EnumItem.EnumType == Enum.KeyCode and UserInputService:IsKeyDown(EnumItem)) or (EnumItem.EnumType == Enum.UserInputType and UserInputService:IsMouseButtonPressed(EnumItem))
end
table.insert(__UAnEv1__.Connections, RunService.Heartbeat:Connect(function()
	if __UAnEv1__ and __UAnEv1__.Active and __UAnEv1__.Config.Aimbot and IsDown(__UAnEv1__.Config.AimbotHoldKey) then
		LocalCharacter = LocalHandle.GetCharacter()
		local ClosestPlayer = GetClosestPlayerToCursor()
		if ClosestPlayer then
			local ClosestHandle = Players[ClosestPlayer]
			local ClosestCharacter = ClosestHandle.GetCharacter()

			local AimPart = ClosestHandle.GetPart(__UAnEv1__.Config.AimbotPart)

			if AimPart and IsPartVisible(AimPart, ClosestCharacter) then
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, AimPart.CFrame.Position)
			end
		end
	end
end))
table.insert(__UAnEv1__.Connections, RunService.RenderStepped:Connect(function()
    for Player, EspObjects in next, __UAnEv1__.PlayerEspObjects do
        if type(EspObjects) == 'table' then
            task.spawn(function()
                for I,V in next, EspObjects do
                    if DoesObjectExist(V) then
                        V.Visible = false;
                    end;
                end;
                for I,V in next, EspObjects.Iterables do
                    for I,V in next, V do
                        if DoesObjectExist(V) then
                            V.Visible = false;
                        end;
                    end;
                end;
            end);
        end;
    end;
    if __UAnEv1__ and __UAnEv1__.Active and (__UAnEv1__.Config.Names or __UAnEv1__.Config.Distance or __UAnEv1__.Config.Boxes or __UAnEv1__.Config.Tracers or __UAnEv1__.ConfigHealthBars or __UAnEv1__.Config.Skeleton) then
        for Player, Handle in next, Players do
            if Player and LocalPlayer and Player ~= LocalPlayer and __UAnEv1__.PlayerEspObjects[Player] then
                task.spawn(function()
                    local EspObjects = __UAnEv1__.PlayerEspObjects[Player]
                    local Iterables = EspObjects.Iterables

                    local NameObject          =   EspObjects.Name
                    local Tracer              =   EspObjects.Tracer
                    local Box                 =   EspObjects.Box
                    local HealthLineRed       =   EspObjects.HealthLineRed
                    local HealthLineGreen     =   EspObjects.HealthLineGreen
                    local DistanceObject      =   EspObjects.Distance
                    local Box3                =   EspObjects.Box3

                    local Skeleton    =   Iterables.Skeleton
                    local Box2        =   Iterables.Box2

                    if AllowedTeam(Player) and Handle then
                        local Character = Handle.GetCharacter()
                        local Head, Humanoid, HumanoidRootPart = Handle.GetParts('Head', 'Humanoid', 'HumanoidRootPart')
                        local Health, MaxHealth = gethealth(Player)

                        if Head and Humanoid and Health > 0 and HumanoidRootPart then
                            local HeadPos, HeadOnScreen = worldtoviewportpoint(Camera, Head.Position)
                            local HrpPos, HrpOnScreen = worldtoviewportpoint(Camera, HumanoidRootPart.Position)

                            local HrpCFr = HumanoidRootPart.CFrame
                            local HrpXV = HrpCFr.XVector
                            local HrpYV = HrpCFr.YVector

                            local OnScreen = HeadOnScreen or HrpOnScreen

                            for I,V in next, EspObjects do
                                if DoesObjectExist(V) then V.Drawing.Visible = OnScreen end
                            end
                            if Iterables then
                                for I, Iterable in next, Iterables do
                                    for I, Object in next, Iterable do
                                        if DoesObjectExist(Object) then Object.Drawing.Visible = OnScreen end
                                    end
                                end
                            end
                            if HeadPos and OnScreen then
                                local HeadPos = Vector3ToVector2(HeadPos)
                                if DoesObjectExist(NameObject) then
                                    if __UAnEv1__.Config.Names then
                                        NameObject.Drawing.Color = __UAnEv1__.Config.NameColor or __UAnEv1__.Config.BaseColor
                                        local Health, MaxHealth = gethealth(Player);
                                        NameObject.Drawing.Text = getname(Player, Humanoid);
                                        NameObject.Drawing.Position = HeadPos - Vector2.new(0, NameObject.Drawing.Size)
                                    end
                                end
                                if DoesObjectExist(Tracer) then
                                    if __UAnEv1__.Config.Tracers then
                                        Tracer.Drawing.Color = __UAnEv1__.Config.TracersColor or __UAnEv1__.Config.BaseColor
                                        Tracer.Drawing.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                        Tracer.Drawing.To = HeadPos
                                    end
                                end

                                local BoxSize = Vector2.new(Camera.ViewportSize.X / HrpPos.Z, (worldtoviewportpoint(Camera, Head.Position + Vector3.new(0, 0, 0))).Y - (worldtoviewportpoint(Camera, HumanoidRootPart.Position - Vector3.new(0, 3.5, 0))).Y)
                                local BoxPos = Vector2.new(HrpPos.X - BoxSize.X / 2, HrpPos.Y - BoxSize.Y / 2)
                                if DoesObjectExist(Box) then
                                    if __UAnEv1__.Config.Boxes and __UAnEv1__.Config.BoxType == 1 then
                                        Box.Drawing.Color = __UAnEv1__.Config.BoxesColor or __UAnEv1__.Config.BaseColor
                                        Box.Drawing.Size = BoxSize
                                        Box.Drawing.Position = BoxPos
                                    end
                                end

                                if DoesObjectExist(HealthLineRed) then
                                    if __UAnEv1__.Config.HealthBars then
                                        -- HealthLineRed.Drawing.Color = __UAnEv1__.Config.HealthBarsColor or __UAnEv1__.Config.BaseColor
                                        if __UAnEv1__.Config.BoxType == 1 then
                                            HealthLineRed.Drawing.From = BoxPos + Vector2.new(BoxSize.X + HealthLineRed.Drawing.Thickness, HealthLineRed.Drawing.Thickness)
                                            HealthLineRed.Drawing.To = BoxPos + Vector2.new(BoxSize.X + HealthLineRed.Drawing.Thickness, BoxSize.Y - HealthLineRed.Drawing.Thickness)
                                        elseif __UAnEv1__.Config.BoxType == 2 then
                                            -- local HrpPos = HumanoidRootPart.Position
                                            -- HealthLineRed.Drawing.From = Vector3ToVector2(worldtoviewportpoint(Camera, HrpPos + Vector3.new(0, 2, 0) + FlatY(HrpXV) + Vector3.new(.03, 0, 0)))
                                            -- HealthLineRed.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, HrpPos - Vector3.new(0, 3.3, 0) + FlatY(HrpXV) + Vector3.new(.03, 0, 0)))

                                            local BoxSize = Vector2.new(Camera.ViewportSize.X / HrpPos.Z, (worldtoviewportpoint(Camera, Head.Position + Vector3.new(0, 2, 0))).Y - (worldtoviewportpoint(Camera, HumanoidRootPart.Position - Vector3.new(0, 1, 0))).Y)
                                            local BoxPos = Vector2.new(HrpPos.X - BoxSize.X / 2, HrpPos.Y - BoxSize.Y / 2)

                                            HealthLineRed.Drawing.From = BoxPos + Vector2.new(BoxSize.X + HealthLineRed.Drawing.Thickness, HealthLineRed.Drawing.Thickness)
                                            HealthLineRed.Drawing.To = BoxPos + Vector2.new(BoxSize.X + HealthLineRed.Drawing.Thickness, BoxSize.Y - HealthLineRed.Drawing.Thickness)
                                        end
                                    end
                                end
                                if DoesObjectExist(HealthLineGreen) then
                                    if __UAnEv1__.Config.HealthBars then
                                        -- HealthLineGreen.Drawing.Color = __UAnEv1__.Config.HealthBarsColor or __UAnEv1__.Config.BaseColor
                                        local DIV = Health / MaxHealth
                                        -- if __UAnEv1__.Config.BoxType == 1 then
                                            local Bottom = BoxSize.Y + HealthLineGreen.Drawing.Thickness
                                            local Top = BoxPos.Y + BoxSize.Y

                                            -- HealthLineGreen.Drawing.From = BoxPos + Vector2.new(BoxSize.X + HealthLineGreen.Drawing.Thickness, HealthLineGreen.Drawing.Thickness)
                                            -- HealthLineGreen.Drawing.To = BoxPos + Vector2.new(BoxSize.X + HealthLineGreen.Drawing.Thickness, BoxSize.Y * DIV - HealthLineGreen.Drawing.Thickness)
                                        -- elseif __UAnEv1__.Config.BoxType == 2 then
                                        --     local HrpPos = HumanoidRootPart.Position

                                        --     local To = Vector3ToVector2(worldtoviewportpoint(Camera, HrpPos + Vector3.new(0, 2, 0) + FlatY(HrpXV) + Vector3.new(.03, 0, 0)))
                                        --     local From = Vector3ToVector2(worldtoviewportpoint(Camera, HrpPos - Vector3.new(0, 3.3, 0) + FlatY(HrpXV) + Vector3.new(.03, 0, 0)))
                                        --     HealthLineGreen.Drawing.To = Vector2.new(To.X, To.Y / DIV)
                                        --     HealthLineGreen.Drawing.From = From
                                        -- end
                                    end
                                end
                                if DoesObjectExist(DistanceObject) then
                                    if __UAnEv1__.Config.Distance then
                                        DistanceObject.Drawing.Color = __UAnEv1__.Config.DistanceColor or __UAnEv1__.Config.BaseColor
                                        DistanceObject.Drawing.Position = HeadPos - Vector2.new(0, DistanceObject.Drawing.Size * 2)
                                        local LocalHrp = LocalHandle.GetPart('HumanoidRootPart')
                                        if LocalHrp then
                                            local Distance = (LocalHrp.Position - HumanoidRootPart.Position).Magnitude
                                            DistanceObject.Drawing.Text = tostring(round(Distance, 2))
                                        end
                                    end
                                end

                                if Skeleton then
                                    if __UAnEv1__.Config.Skeleton then
                                        for I,Object in next, Skeleton do
                                            if DoesObjectExist(Object) then Object.Drawing.Color = __UAnEv1__.Config.SkeletonColor or __UAnEv1__.Config.BaseColor end
                                        end

                                        local HeadToTorso = Skeleton.HeadToTorso
                                        
                                        local TorsoToLeftShoulder = Skeleton.TorsoToLeftShoulder
                                        local TorsoToRightShoulder = Skeleton.TorsoToRightShoulder 

                                        local LeftShoulderToLeftUpperArm = Skeleton.LeftShoulderToLeftUpperArm
                                        local RightShoulderToRightUpperArm = Skeleton.RightShoulderToRightUpperArm
                                        local LeftShoulderToLeftArm = Skeleton.LeftShoulderToLeftArm

                                        local LeftShoulderToLeftLowerArm = Skeleton.LeftShoulderToLeftLowerArm
                                        local RightShoulderToRightLowerArm = Skeleton.RightShoulderToRightLowerArm
                                        local RightShoulderToRightArm = Skeleton.RightShoulderToRightArm

                                        local TorsoToLeftHip = Skeleton.TorsoToLeftHip
                                        local TorsoToRightHip = Skeleton.TorsoToRightHip

                                        local LeftHipToLeftUpperLeg = Skeleton.LeftHipToLeftUpperLeg 
                                        local RightHipToRightUpperLeg = Skeleton.RightHipToRightUpperLeg 
                                        local LeftHipToLeftLeg = Skeleton.LeftHipToLeftLeg

                                        local LeftHipToLeftLowerLeg = Skeleton.LeftHipToLeftLowerLeg 
                                        local RightHipToRightLowerLeg = Skeleton.RightHipToRightLowerLeg 
                                        local RightHipToRightLeg = Skeleton.RightHipToRightLeg

                                        if DoesObjectExist(HeadToTorso) then
                                            HeadToTorso.Drawing.From = HeadPos
                                            HeadToTorso.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, HumanoidRootPart.Position - Vector3.new(0, 1, 0)))
                                        end
                                        
                                        if DoesObjectExist(TorsoToLeftShoulder) then
                                            if Humanoid.RigType == Enum.HumanoidRigType.R6 then
                                                local Arm = Handle.GetPart('Left Arm')
                                                TorsoToLeftShoulder.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, Arm.Position + Vector3.new(0, 1, 0)))
                                            else
                                                local Arm = Handle.GetPart('LeftUpperArm')
                                                TorsoToLeftShoulder.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, Arm.Position + Vector3.new(0, .6, 0)))
                                            end
                                            TorsoToLeftShoulder.Drawing.From = Vector3ToVector2(worldtoviewportpoint(Camera, Head.Position - Vector3.new(0, .5, 0)))
                                        end
                                        if DoesObjectExist(TorsoToRightShoulder) then
                                            if Humanoid.RigType == Enum.HumanoidRigType.R6 then
                                                local Arm = Handle.GetPart('Right Arm')
                                                TorsoToRightShoulder.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, Arm.Position + Vector3.new(0, 1, 0)))
                                            else
                                                local Arm = Handle.GetPart('RightUpperArm')
                                                TorsoToRightShoulder.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, Arm.Position + Vector3.new(0, .6, 0)))
                                            end
                                            TorsoToRightShoulder.Drawing.From = Vector3ToVector2(worldtoviewportpoint(Camera, Head.Position - Vector3.new(0, .5, 0)))
                                        end

                                        if DoesObjectExist(TorsoToLeftHip) then
                                            if Humanoid.RigType == Enum.HumanoidRigType.R6 then
                                                local Leg = Handle.GetPart('Left Leg')
                                                TorsoToLeftHip.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, Leg.Position + Vector3.new(0, 1, 0)))
                                            else
                                                local Leg = Handle.GetPart('LeftUpperLeg')
                                                TorsoToLeftHip.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, Leg.Position + Vector3.new(0, .6, 0)))
                                            end
                                            TorsoToLeftHip.Drawing.From = Vector3ToVector2(worldtoviewportpoint(Camera, HumanoidRootPart.Position - Vector3.new(0, 1, 0)))
                                        end
                                        if DoesObjectExist(TorsoToRightHip) then
                                            if Humanoid.RigType == Enum.HumanoidRigType.R6 then
                                                local Leg = Handle.GetPart('Right Leg')
                                                TorsoToRightHip.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, Leg.Position + Vector3.new(0, 1, 0)))
                                            else
                                                local Leg = Handle.GetPart('RightUpperLeg')
                                                TorsoToRightHip.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, Leg.Position + Vector3.new(0, .6, 0)))
                                            end
                                            TorsoToRightHip.Drawing.From = Vector3ToVector2(worldtoviewportpoint(Camera, HumanoidRootPart.Position - Vector3.new(0, 1, 0)))
                                        end

                                        if Humanoid.RigType == Enum.HumanoidRigType.R6 then
                                            if DoesObjectExist(LeftShoulderToLeftArm) then
                                                local Arm = Handle.GetPart('Left Arm')

                                                LeftShoulderToLeftArm.Drawing.From = Vector3ToVector2(worldtoviewportpoint(Camera, Arm.Position + Vector3.new(0, 1, 0)))
                                                LeftShoulderToLeftArm.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, Arm.Position - Vector3.new(0, 1, 0)))
                                            end
                                            if DoesObjectExist(RightShoulderToRightArm) then
                                                local Arm = Handle.GetPart('Right Arm')

                                                RightShoulderToRightArm.Drawing.From = Vector3ToVector2(worldtoviewportpoint(Camera, Arm.Position + Vector3.new(0, 1, 0)))
                                                RightShoulderToRightArm.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, Arm.Position - Vector3.new(0, 1, 0)))
                                            end

                                            if DoesObjectExist(LeftHipToLeftLeg) then
                                                local Leg = Handle.GetPart('Left Leg')

                                                LeftHipToLeftLeg.Drawing.From = Vector3ToVector2(worldtoviewportpoint(Camera, Leg.Position + Vector3.new(0, 1, 0)))
                                                LeftHipToLeftLeg.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, Leg.Position - Vector3.new(0, 1, 0)))
                                            end

                                            if DoesObjectExist(RightHipToRightLeg) then
                                                local Leg = Handle.GetPart('Right Leg')

                                                RightHipToRightLeg.Drawing.From = Vector3ToVector2(worldtoviewportpoint(Camera, Leg.Position + Vector3.new(0, 1, 0)))
                                                RightHipToRightLeg.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, Leg.Position - Vector3.new(0, 1, 0)))
                                            end

                                        elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then
                                            if DoesObjectExist(LeftShoulderToLeftUpperArm) then
                                                local UpperArm, LowerArm = Handle.GetParts('LeftUpperArm', 'LeftLowerArm')

                                                LeftShoulderToLeftUpperArm.Drawing.From = Vector3ToVector2(worldtoviewportpoint(Camera, UpperArm.Position + Vector3.new(0, .6, 0)))
                                                LeftShoulderToLeftUpperArm.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, LowerArm.Position))
                                            end
                                            if DoesObjectExist(LeftShoulderToLeftLowerArm) then
                                                local UpperArm, LowerArm = Handle.GetParts('LeftUpperArm', 'LeftLowerArm')

                                                LeftShoulderToLeftLowerArm.Drawing.From = Vector3ToVector2(worldtoviewportpoint(Camera, LowerArm.Position))
                                                LeftShoulderToLeftLowerArm.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, LowerArm.Position - LowerArm.CFrame.YVector))
                                            end

                                            if DoesObjectExist(RightShoulderToRightUpperArm) then
                                                local UpperArm, LowerArm = Handle.GetParts('RightUpperArm', 'RightLowerArm')

                                                RightShoulderToRightUpperArm.Drawing.From = Vector3ToVector2(worldtoviewportpoint(Camera, UpperArm.Position + Vector3.new(0, .6, 0)))
                                                RightShoulderToRightUpperArm.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, LowerArm.Position))
                                            end
                                            if DoesObjectExist(RightShoulderToRightLowerArm) then
                                                local UpperArm, LowerArm = Handle.GetParts('RightUpperArm', 'RightLowerArm')

                                                RightShoulderToRightLowerArm.Drawing.From = Vector3ToVector2(worldtoviewportpoint(Camera, LowerArm.Position))
                                                -- RightShoulderToRightLowerArm.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, LowerArm.Position - Vector3.new(0, .7, 0)))
                                                RightShoulderToRightLowerArm.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, LowerArm.Position - LowerArm.CFrame.YVector))
                                            end

                                            if DoesObjectExist(LeftHipToLeftUpperLeg) then
                                                local UpperLeg, LowerLeg = Handle.GetParts('LeftUpperLeg', 'LeftLowerLeg')

                                                LeftHipToLeftUpperLeg.Drawing.From = Vector3ToVector2(worldtoviewportpoint(Camera, UpperLeg.Position + Vector3.new(0, .6, 0)))
                                                LeftHipToLeftUpperLeg.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, LowerLeg.Position))
                                            end
                                            if DoesObjectExist(LeftHipToLeftLowerLeg) then
                                                local UpperLeg, LowerLeg = Handle.GetParts('LeftUpperLeg', 'LeftLowerLeg')

                                                LeftHipToLeftLowerLeg.Drawing.From = Vector3ToVector2(worldtoviewportpoint(Camera, LowerLeg.Position))
                                                LeftHipToLeftLowerLeg.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, LowerLeg.Position - LowerLeg.CFrame.YVector))
                                            end

                                            if DoesObjectExist(RightHipToRightUpperLeg) then
                                                local UpperLeg, LowerLeg = Handle.GetParts('RightUpperLeg', 'RightLowerLeg')

                                                RightHipToRightUpperLeg.Drawing.From = Vector3ToVector2(worldtoviewportpoint(Camera, UpperLeg.Position + Vector3.new(0, .6, 0)))
                                                RightHipToRightUpperLeg.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, LowerLeg.Position))
                                            end
                                            if DoesObjectExist(RightHipToRightLowerLeg) then
                                                local UpperLeg, LowerLeg = Handle.GetParts('RightUpperLeg', 'RightLowerLeg')

                                                RightHipToRightLowerLeg.Drawing.From = Vector3ToVector2(worldtoviewportpoint(Camera, LowerLeg.Position))
                                                RightHipToRightLowerLeg.Drawing.To = Vector3ToVector2(worldtoviewportpoint(Camera, LowerLeg.Position - LowerLeg.CFrame.YVector))
                                            end
                                        end
                                    end
                                end

                                if __UAnEv1__.Config.Boxes and __UAnEv1__.Config.BoxType == 2 or __UAnEv1__.Config.BoxType == 3 then
                                    for I, Object in next, Box2 do
                                        if DoesObjectExist(Object) then Object.Drawing.Color = __UAnEv1__.Config.BoxesColor or __UAnEv1__.Config.BaseColor end
                                    end
                                    local BL1 = Box2.BL1
                                    local BL2 = Box2.BL2
                                    local BL3 = Box2.BL3
                                    local BL4 = Box2.BL4

                                    local HrpPos = HumanoidRootPart.Position

                                    local Wide = (__UAnEv1__.Config.WideBox and HrpXV * 1.2) or Vector3.new(0, 0, 0)

                                    local TopLeft = nil
                                    local TopRight = nil

                                    local BottomLeft = nil
                                    local BottomRight = nil
                                    if __UAnEv1__.Config.BoxType == 2 then
                                        TopLeft = Vector3ToVector2(worldtoviewportpoint(Camera, HrpPos + Vector3.new(0, 2, 0) - FlatY(HrpXV) - FlatY(Wide)))
                                        TopRight = Vector3ToVector2(worldtoviewportpoint(Camera, HrpPos + Vector3.new(0, 2, 0) + FlatY(HrpXV) + FlatY(Wide)))

                                        BottomLeft = Vector3ToVector2(worldtoviewportpoint(Camera, HrpPos - Vector3.new(0, 2, 0) - FlatY(HrpXV) - Vector3.new(0, 1.3, 0) - FlatY(Wide)))
                                        BottomRight = Vector3ToVector2(worldtoviewportpoint(Camera, HrpPos - Vector3.new(0, 2, 0) + FlatY(HrpXV) - Vector3.new(0, 1.3, 0) + FlatY(Wide)))
                                    else
                                        local Leg = Handle.GetPart('Left Leg') or Handle.GetPart('LeftUpperLeg')
                                        local LegPos = Leg.Position
                                        local LegCFr = Leg.CFrame
                                        local LegYV = LegCFr.YVector

                                        TopLeft = Vector3ToVector2(worldtoviewportpoint(Camera, HrpPos + JustY(HrpYV) - FlatY(HrpXV) - FlatY(Wide)))
                                        TopRight = Vector3ToVector2(worldtoviewportpoint(Camera, HrpPos + JustY(HrpYV) + FlatY(HrpXV) + FlatY(Wide)))

                                        BottomLeft = Vector3ToVector2(worldtoviewportpoint(Camera, HrpPos - JustY(HrpYV) - FlatY(HrpXV) - JustY(HrpYV) - FlatY(Wide) - FlatY(LegYV)))
                                        BottomRight = Vector3ToVector2(worldtoviewportpoint(Camera, HrpPos - JustY(HrpYV) + FlatY(HrpXV) - JustY(HrpYV) - FlatY(Wide) - FlatY(LegYV)))
                                    end

                                    if DoesObjectExist(BL1) then
                                        BL1.Drawing.From = TopLeft
                                        BL1.Drawing.To = TopRight
                                    end
                                    if DoesObjectExist(BL2) then
                                        BL2.Drawing.From = BottomLeft
                                        BL2.Drawing.To = BottomRight
                                    end
                                    if DoesObjectExist(BL3) then
                                        BL3.Drawing.From = TopLeft
                                        BL3.Drawing.To = BottomLeft
                                    end
                                    if DoesObjectExist(BL4) then
                                        BL4.Drawing.From = TopRight
                                        BL4.Drawing.To = BottomRight
                                    end
                                    

                                    -- local TopLeft = Vector3ToVector2(worldtoviewportpoint(Camera, HrpPos + JustZ(HumanoidRootPart.Size)))
                                    -- local TopRight = Vector3ToVector2(worldtoviewportpoint(Camera, HrpPos))

                                    -- if DoesObjectExist(BL1) then
                                    --     BL1.Drawing.From = TopLeft
                                    --     BL1.Drawing.To = TopRight
                                    -- end
                                else
                                    for I, Object in next, Box2 do if DoesObjectExist(Object) then Object.Drawing.Visible = false end end
                                end

                                if DoesObjectExist(Box3) then
                                    if __UAnEv1__.Config.Boxes and __UAnEv1__.Config.BoxType == 4 then
                                        local TopLeft = Vector3ToVector2(worldtoviewportpoint(Camera, HrpPos + Vector3.new(0, 2, 0) - FlatY(HrpXV)))
                                        local TopRight = Vector3ToVector2(worldtoviewportpoint(Camera, HrpPos + Vector3.new(0, 2, 0) + FlatY(HrpXV)))

                                        local BottomLeft = Vector3ToVector2(worldtoviewportpoint(Camera, HrpPos - Vector3.new(0, 2, 0) - FlatY(HrpXV) - Vector3.new(0, 1.3, 0)))
                                        local BottomRight = Vector3ToVector2(worldtoviewportpoint(Camera, HrpPos - Vector3.new(0, 2, 0) + FlatY(HrpXV) - Vector3.new(0, 1.3, 0)))

                                        Box3.Drawing.PointA = TopRight
                                        Box3.Drawing.PointB = TopLeft
                                        Box3.Drawing.PointC = BottomLeft
                                        Box3.Drawing.PointD = BottomRight
                                    end 
                                end
                            end
                        else
                            for I,Object in next, EspObjects do
                                if DoesObjectExist(Object) then Object.Drawing.Visible = false end
                            end
                            if Iterables then
                                for I, Iterable in next, Iterables do
                                    for I, Object in next, Iterable do
                                        if DoesObjectExist(Object) then
                                            Object.Drawing.Visible = false
                                        end
                                    end
                                end
                            end
                        end
                    else
                        for I,Object in next, EspObjects do
                            if DoesObjectExist(Object) then Object.Drawing.Visible = false end
                        end
                        if Iterables then
                            for I, Iterable in next, Iterables do
                                for I, Object in next, Iterable do
                                    if DoesObjectExist(Object) then
                                        Object.Drawing.Visible = false
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end
end))

function __UAnEv1__.STOP()
	for Player, Handle in next, Players do
        PlayerRemoved(Player, Handle)
    end
    for I, Connection in next, __UAnEv1__.Connections do
    	Connection:Disconnect()
    end

    if __UAnEv1__.Gui then
    	__UAnEv1__.Gui:Destroy()
    	__UAnEv1__.Gui = nil
    end

    PlayersHandler:Stop()
    __UAnEv1__.Active = false
    if shared.__UAnEv1__ and shared.__UAnEv1__ == __UAnEv1__ then
        shared.__UAnEv1__ = nil
    end
    __UAnEv1__ = nil
end

do -- TechHub V3 UI Library
    -- local Library = httpassert('https://raw.githubusercontent.com/TechHog8984/TechHub-V3/main/ui/UILibV3.lua', 'Failed to get UI library.')
    -- local Gui = Library:CreateGui('UAnEv1 GUI', 'Universal Aimbot N Esp', 'V1 - Made By TechHog#8984')

    -- Gui:GetCloseEvent():Connect(__UAnEv1__.STOP)

    -- local GeneralSection = Gui:CreateSection('General')
    -- local ToggleTeamCheckButton = nil
    -- ToggleTeamCheckButton = GeneralSection:TextButton('Toggle TeamCheck', function()
    -- 	__UAnEv1__.Config.TeamCheck = not __UAnEv1__.Config.TeamCheck
    -- 	ToggleTeamCheckButton.text.Text = ('Toggle TeamCheck (%s)'):format(tostring(__UAnEv1__.Config.TeamCheck))
    -- end)
    -- ToggleTeamCheckButton.text.Text = ('Toggle TeamCheck (%s)'):format(tostring(__UAnEv1__.Config.TeamCheck))

    -- local AimbotSection = Gui:CreateSection('Aimbot')
    -- local ToggleAimbotButton = nil
    -- ToggleAimbotButton = AimbotSection:TextButton('Toggle Aimbot', function()
    -- 	__UAnEv1__.Config.Aimbot = not __UAnEv1__.Config.Aimbot
    -- 	ToggleAimbotButton.text.Text = ('Toggle Aimbot (%s)'):format(tostring(__UAnEv1__.Config.Aimbot))
    -- end)
    -- ToggleAimbotButton.text.Text = ('Toggle Aimbot (%s)'):format(tostring(__UAnEv1__.Config.Aimbot or false))

    -- local EspSection = Gui:CreateSection('Esp')

    -- local NamesToggleButton = nil
    -- local DistanceToggleButton = nil
    -- local BoxesToggleButton = nil
    -- local TracersToggleButton = nil
    -- local HealthBarsToggleButton = nil
    -- local SkeletonToggleButton = nil

    -- NamesToggleButton = EspSection:TextButton('Toggle Names', function()
    -- 	__UAnEv1__.Config.Names = not __UAnEv1__.Config.Names
    -- 	NamesToggleButton.text.Text = ('Toggle Names (%s)'):format(tostring(__UAnEv1__.Config.Names))
    -- end)
    -- NamesToggleButton.text.Text = ('Toggle Names (%s)'):format(tostring(__UAnEv1__.Config.Names or false))

    -- DistanceToggleButton = EspSection:TextButton('Toggle Distance', function()
    -- 	__UAnEv1__.Config.Distance = not __UAnEv1__.Config.Distance
    -- 	DistanceToggleButton.text.Text = ('Toggle Distance (%s)'):format(tostring(__UAnEv1__.Config.Distance))
    -- end)
    -- DistanceToggleButton.text.Text = ('Toggle Distance (%s)'):format(tostring(__UAnEv1__.Config.Distance or false))

    -- BoxesToggleButton = EspSection:TextButton('Toggle Boxes', function()
    -- 	__UAnEv1__.Config.Boxes = not __UAnEv1__.Config.Boxes
    -- 	BoxesToggleButton.text.Text = ('Toggle Boxes (%s)'):format(tostring(__UAnEv1__.Config.Boxes))
    -- end)
    -- BoxesToggleButton.text.Text = ('Toggle Boxes (%s)'):format(tostring(__UAnEv1__.Config.Boxes or false))

    -- TracersToggleButton = EspSection:TextButton('Toggle Tracers', function()
    -- 	__UAnEv1__.Config.Tracers = not __UAnEv1__.Config.Tracers
    -- 	TracersToggleButton.text.Text = ('Toggle Tracers (%s)'):format(tostring(__UAnEv1__.Config.Tracers))
    -- end)
    -- TracersToggleButton.text.Text = ('Toggle Tracers (%s)'):format(tostring(__UAnEv1__.Config.Tracers or false))

    -- HealthBarsToggleButton = EspSection:TextButton('Toggle HealthBars', function()
    -- 	__UAnEv1__.Config.HealthBars = not __UAnEv1__.Config.HealthBars
    -- 	HealthBarsToggleButton.text.Text = ('Toggle HealthBars (%s)'):format(tostring(__UAnEv1__.Config.HealthBars))
    -- end)
    -- HealthBarsToggleButton.text.Text = ('Toggle HealthBars (%s)'):format(tostring(__UAnEv1__.Config.HealthBars or false))

    -- SkeletonToggleButton = EspSection:TextButton('Toggle Skeleton', function()
    -- 	__UAnEv1__.Config.Skeleton = not __UAnEv1__.Config.Skeleton
    -- 	SkeletonToggleButton.text.Text = ('Toggle Skeleton (%s)'):format(tostring(__UAnEv1__.Config.Skeleton))
    -- end)
    -- SkeletonToggleButton.text.Text = ('Toggle Skeleton (%s)'):format(tostring(__UAnEv1__.Config.Skeleton or false))
end

do --Elysium UI Library
    
end

__UAnEv1__.Gui = Gui
shared.__UAnEv1__ = __UAnEv1__
