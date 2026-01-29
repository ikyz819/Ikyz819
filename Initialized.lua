local Liquid = {}

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local ContentProvider = game:GetService('ContentProvider')
local TweenService = game:GetService('TweenService')
local CoreGui = game:GetService('CoreGui')

local Mobile = if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then true else false

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local Camera = workspace.CurrentCamera
local DDX, DDY
local Mouse = game.Players.LocalPlayer:GetMouse()

function Liquid:Parent()
	if not RunService:IsStudio() then
		return (gethui and gethui()) or CoreGui
	end

	return PlayerGui
end

function Liquid:Draggable(inputframe, dragframe)
	local dragging = false
	local dragStart = nil
	local startPos = nil

	inputframe.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true

			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragStart = UserInputService:GetMouseLocation()
			else
				dragStart = input.Position
			end

			startPos = dragframe.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement 
			or input.UserInputType == Enum.UserInputType.Touch) then

			local currentPos

			if input.UserInputType == Enum.UserInputType.MouseMovement then
				currentPos = UserInputService:GetMouseLocation()
			else
				currentPos = input.Position
			end

			local delta = currentPos - dragStart

			dragframe.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

function Liquid:Button(Parent)
	local Click = Instance.new("TextButton")

	Click.Name = "Click"
	Click.Parent = Parent
	Click.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Click.BackgroundTransparency = 1.000
	Click.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Click.BorderSizePixel = 0
	Click.Size = UDim2.new(1, 0, 1, 0)
	Click.Font = Enum.Font.SourceSans
	Click.Text = ""
	Click.TextColor3 = Color3.fromRGB(0, 0, 0)
	Click.TextSize = 14.000
	Click.ZIndex = Parent.ZIndex + 3

	return Click
end

function Liquid:Tween(info)
	return TweenService:Create(info.v, TweenInfo.new(info.t, Enum.EasingStyle[info.s], Enum.EasingDirection[info.d]), info.g)
end

function Liquid:Effect(c, p)
	p.ClipsDescendants = true

	local Mouse = LocalPlayer:GetMouse()

	local relativeX = Mouse.X - c.AbsolutePosition.X
	local relativeY = Mouse.Y - c.AbsolutePosition.Y

	if relativeX < 0 or relativeY < 0 or relativeX > c.AbsoluteSize.X or relativeY > c.AbsoluteSize.Y then
		return
	end

	local ClickButtonCircle = Instance.new("Frame")
	ClickButtonCircle.Parent = p
	ClickButtonCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ClickButtonCircle.BackgroundTransparency = 0.95
	ClickButtonCircle.BorderSizePixel = 0
	ClickButtonCircle.AnchorPoint = Vector2.new(0.5, 0.5)
	ClickButtonCircle.Position = UDim2.new(0, relativeX, 0, relativeY)
	ClickButtonCircle.Size = UDim2.new(0, 0, 0, 0)
	ClickButtonCircle.ZIndex = p.ZIndex

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(1, 0)
	UICorner.Parent = ClickButtonCircle

	local tweenInfo = TweenInfo.new(2.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	local expandTween = TweenService:Create(ClickButtonCircle, tweenInfo, {
		Size = UDim2.new(0, c.AbsoluteSize.X * 1.5, 0, c.AbsoluteSize.X * 1.5),
		BackgroundTransparency = 1
	})

	expandTween.Completed:Connect(function()
		ClickButtonCircle:Destroy()
	end)

	expandTween:Play()
end

function Liquid:Asset(rbx)
	if typeof(rbx) == 'number' then
		return "rbxassetid://" .. rbx
	end

	if typeof(rbx) == 'string' and rbx:find('rbxassetid://') then
		return rbx
	end

	return rbx
end

function Liquid:VectorToUdim(vec2)
	return UDim2.new(0, vec2.X, 0, vec2.Y)
end

function Liquid:Resize(inputframe, frametoresize, minSize, maxSize, speed)
	local resizing = false
	local resizeStart = nil
	local startSize = nil

	minSize = minSize or Vector2.new(50, 50)
	maxSize = maxSize or Vector2.new(1000, 1000)
	speed   = speed or 1.5

	inputframe.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 
			or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			resizeStart = input.Position
			startSize = frametoresize.Size

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizing = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement 
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = (input.Position - resizeStart) * speed

			local newX = math.clamp(startSize.X.Offset + delta.X, minSize.X, maxSize.X)
			local newY = math.clamp(startSize.Y.Offset + delta.Y, minSize.Y, maxSize.Y)

			frametoresize.Size = UDim2.new(
				startSize.X.Scale, newX,
				startSize.Y.Scale, newY
			)
		end
	end)
end

function Liquid:BlurFrame(getFrame)
	local MTREL = "Glass"
	local binds = {}
	local root = Instance.new('Folder', Camera)
	root.Name = 'BlurSnox'

	local gTokenMH = 99999999
	local gToken = math.random(1, gTokenMH)

	local DepthOfField = Instance.new('DepthOfFieldEffect', game:GetService('Lighting'))
	DepthOfField.FarIntensity = 0
	DepthOfField.FocusDistance = 51.6
	DepthOfField.InFocusRadius = 50
	DepthOfField.NearIntensity = 1
	DepthOfField.Name = "DPT_"..gToken

	local frame = Instance.new('Frame')
	frame.Parent = getFrame
	frame.Size = UDim2.new(0.95, 0, 0.95, 0)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1

	local GenUid

	do
		local id = 0
		function GenUid()
			id = id + 1
			return 'neon::'..tostring(id)
		end
	end

	do
		local function IsNotNaN(x)
			return x == x
		end

		local continue = IsNotNaN(Camera:ScreenPointToRay(0,0).Origin.x)

		while not continue do
			RunService.RenderStepped:wait()
			continue = IsNotNaN(Camera:ScreenPointToRay(0,0).Origin.x)
		end
	end

	local DrawQuad; do
		local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
		local sz = 0.2

		local function DrawTriangle(v1, v2, v3, p0, p1) -- I think Stravant wrote this function
			local s1 = (v1 - v2).magnitude
			local s2 = (v2 - v3).magnitude
			local s3 = (v3 - v1).magnitude
			local smax = max(s1, s2, s3)
			local A, B, C

			if s1 == smax then
				A, B, C = v1, v2, v3
			elseif s2 == smax then
				A, B, C = v2, v3, v1
			elseif s3 == smax then
				A, B, C = v3, v1, v2
			end

			local para = ( (B-A).x*(C-A).x + (B-A).y*(C-A).y + (B-A).z*(C-A).z ) / (A-B).magnitude
			local perp = sqrt((C-A).magnitude^2 - para*para)
			local dif_para = (A - B).magnitude - para

			local st = CFrame.new(B, A)
			local za = CFrame.Angles(pi/2,0,0)

			local cf0 = st

			local Top_Look = (cf0 * za).lookVector
			local Mid_Point = A + CFrame.new(A, B).lookVector * para
			local Needed_Look = CFrame.new(Mid_Point, C).lookVector
			local dot = Top_Look.x*Needed_Look.x + Top_Look.y*Needed_Look.y + Top_Look.z*Needed_Look.z

			local ac = CFrame.Angles(0, 0, acos(dot))

			cf0 = cf0 * ac

			if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
				cf0 = cf0 * CFrame.Angles(0, 0, -2*acos(dot))
			end

			cf0 = cf0 * CFrame.new(0, perp/2, -(dif_para + para/2))

			local cf1 = st * ac * CFrame.Angles(0, pi, 0)

			if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
				cf1 = cf1 * CFrame.Angles(0, 0, 2*acos(dot))
			end

			cf1 = cf1 * CFrame.new(0, perp/2, dif_para/2)

			if not p0 then
				p0 = Instance.new('Part')
				p0.FormFactor = 'Custom'
				p0.TopSurface = 0
				p0.BottomSurface = 0
				p0.Anchored = true
				p0.CanCollide = false
				p0.CastShadow = false
				p0.Material = MTREL
				p0.Size = Vector3.new(sz, sz, sz)
				local mesh = Instance.new('SpecialMesh', p0)
				mesh.MeshType = 2
				mesh.Name = 'WedgeMesh'
			end

			p0.WedgeMesh.Scale = Vector3.new(0, perp/sz, para/sz)
			p0.CFrame = cf0

			if not p1 then
				p1 = p0:clone()
			end

			p1.WedgeMesh.Scale = Vector3.new(0, perp/sz, dif_para/sz)
			p1.CFrame = cf1

			return p0, p1
		end

		function DrawQuad(v1, v2, v3, v4, parts)
			parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
			parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
		end
	end

	if binds[frame] then
		return binds[frame].parts
	end

	local uid = GenUid()
	local parts = {}
	local f = Instance.new('Folder', root)
	f.Name = frame.Name

	local parents = {}

	do
		local function add(child)
			if child:IsA'GuiObject' then
				parents[#parents + 1] = child
				add(child.Parent)
			end
		end

		add(frame)
	end

	local function UpdateOrientation(fetchProps)
		local properties = {
			Transparency = 0.98;
			BrickColor = BrickColor.new('Institutional white');
		}
		local zIndex = 1 - 0.05*frame.ZIndex

		local tl, br = frame.AbsolutePosition, frame.AbsolutePosition + frame.AbsoluteSize
		local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
		do
			local rot = 0;
			for _, v in ipairs(parents) do
				rot = rot + v.Rotation
			end
			if rot ~= 0 and rot%180 ~= 0 then
				local mid = tl:lerp(br, 0.5)
				local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
				local vec = tl
				tl = Vector2.new(c*(tl.x - mid.x) - s*(tl.y - mid.y), s*(tl.x - mid.x) + c*(tl.y - mid.y)) + mid
				tr = Vector2.new(c*(tr.x - mid.x) - s*(tr.y - mid.y), s*(tr.x - mid.x) + c*(tr.y - mid.y)) + mid
				bl = Vector2.new(c*(bl.x - mid.x) - s*(bl.y - mid.y), s*(bl.x - mid.x) + c*(bl.y - mid.y)) + mid
				br = Vector2.new(c*(br.x - mid.x) - s*(br.y - mid.y), s*(br.x - mid.x) + c*(br.y - mid.y)) + mid
			end
		end

		DrawQuad(
			Camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin, 
			Camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin, 
			Camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin, 
			Camera:ScreenPointToRay(br.x, br.y, zIndex).Origin, 
			parts
		)

		if fetchProps then
			for _, pt in pairs(parts) do
				pt.Parent = f
			end
			for propName, propValue in pairs(properties) do
				for _, pt in pairs(parts) do
					pt[propName] = propValue
				end
			end
		end
	end

	UpdateOrientation(true)
	RunService:BindToRenderStep(uid, 2000, UpdateOrientation)

	return {
		DepthOfField,
		frame
	}
end

function Liquid:Template(Parent, Title, Desc, Padding)
	local Template = Instance.new("Frame")
	local UIStroke_1 = Instance.new("UIStroke")
	local UICorner_1 = Instance.new("UICorner")
	local Text_1 = Instance.new("Frame")
	local UIListLayout_1 = Instance.new("UIListLayout")
	local Desc_1 = Instance.new("TextLabel")
	local Title_1 = Instance.new("TextLabel")
	local UIPadding_1 = Instance.new("UIPadding")
	local Scaler_1 = Instance.new("Frame")
	local UIListLayout_2 = Instance.new("UIListLayout")
	local UIPadding_2 = Instance.new("UIPadding")

	Template.Name = "Template"
	Template.Parent = Parent
	Template.BackgroundColor3 = Color3.fromRGB(70,70,70)
	Template.BackgroundTransparency = 0.8199999928474426
	Template.BorderColor3 = Color3.fromRGB(0,0,0)
	Template.BorderSizePixel = 0
	Template.Size = UDim2.new(1, 0,0, 63)

	UIStroke_1.Parent = Template
	UIStroke_1.Color = Color3.fromRGB(25,25,25)
	UIStroke_1.Thickness = 1
	UIStroke_1.Transparency = 0.15

	UICorner_1.Parent = Template
	UICorner_1.CornerRadius = UDim.new(0,4)

	Text_1.Name = "Text"
	Text_1.Parent = Template
	Text_1.AnchorPoint = Vector2.new(0, 0.5)
	Text_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Text_1.BackgroundTransparency = 1
	Text_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Text_1.BorderSizePixel = 0
	Text_1.Position = UDim2.new(0, 0,0.5, 0)
	Text_1.Size = UDim2.new(1, (Padding and -Padding) or -15 ,1, 0)

	UIListLayout_1.Parent = Text_1
	UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

	Title_1.Name = "Title"
	Title_1.Parent = Text_1
	Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Title_1.BackgroundTransparency = 1
	Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Title_1.BorderSizePixel = 0
	Title_1.LayoutOrder = -1
	Title_1.Size = UDim2.new(1, 0,0, 13)
	Title_1.Font = Enum.Font.GothamSemibold
	Title_1.RichText = true
	Title_1.Text = Title
	Title_1.TextColor3 = Color3.fromRGB(235,235,235)
	Title_1.TextSize = 13
	Title_1.TextXAlignment = Enum.TextXAlignment.Left

	UIPadding_1.Parent = Text_1
	UIPadding_1.PaddingBottom = UDim.new(0,2)
	UIPadding_1.PaddingLeft = UDim.new(0,15)

	Scaler_1.Name = "Scaler"
	Scaler_1.Parent = Template
	Scaler_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Scaler_1.BackgroundTransparency = 1
	Scaler_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Scaler_1.BorderSizePixel = 0
	Scaler_1.Size = UDim2.new(1, 0,1, 0)

	UIListLayout_2.Parent = Scaler_1
	UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Right
	UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

	UIPadding_2.Parent = Scaler_1
	UIPadding_2.PaddingRight = UDim.new(0, 20)

	if Desc then
		Desc_1.Name = "Desc"
		Desc_1.Parent = Text_1
		Desc_1.BackgroundColor3 = Color3.fromRGB(145,145,145)
		Desc_1.BackgroundTransparency = 1
		Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Desc_1.BorderSizePixel = 0
		Desc_1.Size = UDim2.new(1, 0,0, 20)
		Desc_1.Font = Enum.Font.GothamMedium
		Desc_1.RichText = true
		Desc_1.Text = Desc
		Desc_1.TextColor3 = Color3.fromRGB(145,145,145)
		Desc_1.TextSize = 11
		Desc_1.TextWrapped = true
		Desc_1.TextXAlignment = Enum.TextXAlignment.Left

		Desc_1:GetPropertyChangedSignal("TextBounds"):Connect(function()
			Desc_1.Size = UDim2.new(1, 0, 0, Desc_1.TextBounds.Y)

			Template.Size = UDim2.new(
				1, 0,
				0,
				math.max(55, UIListLayout_1.AbsoluteContentSize.Y + 25)
			)
		end)
	else
		Title_1:GetPropertyChangedSignal("TextBounds"):Connect(function()
			Title_1.Size = UDim2.new(1, 0, 0, Title_1.TextBounds.Y)

			Template.Size = UDim2.new(
				1, 0,
				0,
				math.max(50, UIListLayout_1.AbsoluteContentSize.Y + 25)
			)
		end)
	end

	return Template
end

local keywords = {
	lua = {
		"and", "break", "or", "else", "elseif", "if", "then", "until", "repeat", "while", "do", "for", "in", "end",
		"local", "return", "function", "export",
	},
	rbx = {
		"game", "workspace", "script", "math", "string", "table", "task", "wait", "select", "next", "Enum",
		"tick", "assert", "shared", "loadstring", "tonumber", "tostring", "type",
		"typeof", "unpack", "Instance", "CFrame", "Vector3", "Vector2", "Color3", "UDim", "UDim2", "Ray", "BrickColor",
		"OverlapParams", "RaycastParams", "Axes", "Random", "Region3", "Rect", "TweenInfo",
		"collectgarbage", "not", "utf8", "pcall", "xpcall", "_G", "setmetatable", "getmetatable", "os", "pairs", "ipairs"
	},
	operators = {
		"#", "+", "-", "*", "%", "/", "^", "=", "~", "=", "<", ">",
	}
}

local colors = {
	numbers = Color3.fromHex("#FAB387"),
	boolean = Color3.fromHex("#FAB387"),
	operator = Color3.fromHex("#94E2D5"),
	lua = Color3.fromHex("#CBA6F7"),
	rbx = Color3.fromHex("#F38BA8"),
	str = Color3.fromHex("#A6E3A1"),
	comment = Color3.fromHex("#9399B2"),
	null = Color3.fromHex("#F38BA8"),
	call = Color3.fromHex("#89B4FA"),    
	self_call = Color3.fromHex("#89B4FA"),
	local_property = Color3.fromHex("#CBA6F7"),
}

local function createKeywordSet(keywords)
	local keywordSet = {}
	for _, keyword in ipairs(keywords) do
		keywordSet[keyword] = true
	end
	return keywordSet
end

local luaSet = createKeywordSet(keywords.lua)
local rbxSet = createKeywordSet(keywords.rbx)
local operatorsSet = createKeywordSet(keywords.operators)

local function getHighlight(tokens, index)
	local token = tokens[index]

	if colors[token .. "_color"] then
		return colors[token .. "_color"]
	end

	if tonumber(token) then
		return colors.numbers
	elseif token == "nil" then
		return colors.null
	elseif token:sub(1, 2) == "--" then
		return colors.comment
	elseif operatorsSet[token] then
		return colors.operator
	elseif luaSet[token] then
		return colors.lua
	elseif rbxSet[token] then
		return colors.rbx
	elseif token:sub(1, 1) == "\"" or token:sub(1, 1) == "\'" then
		return colors.str
	elseif token == "true" or token == "false" then
		return colors.boolean
	end

	if tokens[index + 1] == "(" then
		if tokens[index - 1] == ":" then
			return colors.self_call
		end

		return colors.call
	end

	if tokens[index - 1] == "." then
		if tokens[index - 2] == "Enum" then
			return colors.rbx
		end

		return colors.local_property
	end
end

function Liquid:Init(source)
	local tokens = {}
	local currentToken = ""

	local inString = false
	local inComment = false
	local commentPersist = false

	for i = 1, #source do
		local character = source:sub(i, i)

		if inComment then
			if character == "\n" and not commentPersist then
				table.insert(tokens, currentToken)
				table.insert(tokens, character)
				currentToken = ""

				inComment = false
			elseif source:sub(i - 1, i) == "]]" and commentPersist then
				currentToken = currentToken .. "]"

				table.insert(tokens, currentToken)
				currentToken = ""

				inComment = false
				commentPersist = false
			else
				currentToken = currentToken .. character
			end
		elseif inString then
			if character == inString and source:sub(i-1, i-1) ~= "\\" or character == "\n" then
				currentToken = currentToken .. character
				inString = false
			else
				currentToken = currentToken .. character
			end
		else
			if source:sub(i, i + 1) == "--" then
				table.insert(tokens, currentToken)
				currentToken = "-"
				inComment = true
				commentPersist = source:sub(i + 2, i + 3) == "[["
			elseif character == "\"" or character == "\'" then
				table.insert(tokens, currentToken)
				currentToken = character
				inString = character
			elseif operatorsSet[character] then
				table.insert(tokens, currentToken)
				table.insert(tokens, character)
				currentToken = ""
			elseif character:match("[%w_]") then
				currentToken = currentToken .. character
			else
				table.insert(tokens, currentToken)
				table.insert(tokens, character)
				currentToken = ""
			end
		end
	end

	table.insert(tokens, currentToken)

	local highlighted = {}

	for i, token in ipairs(tokens) do
		local highlight = getHighlight(tokens, i)

		if highlight then
			local syntax = string.format("<font color = \"#%s\">%s</font>", highlight:ToHex(), token:gsub("<", "&lt;"):gsub(">", "&gt;"))

			table.insert(highlighted, syntax)
		else
			table.insert(highlighted, token)
		end
	end

	return table.concat(highlighted)
end

function Liquid:Window(configs)
	local Logo = configs.Logo or 123458176076183
	local Title = configs.Title or 'Liquid'
	local Description = configs.Description or 'This is The Liquid Library.'
	local Transparent = configs.Transparent or false
	local Keybind = configs.Keybind or Enum.KeyCode.LeftControl
	local Highlight = configs.Highligh or Color3.fromRGB(72, 138, 182)

	local MaxSize = Vector2.new(800, 600)
	local MinSize = Vector2.new(450, 320)
	local RuntimeScaler = 1

	local LiquidUI = Instance.new("ScreenGui") do
		LiquidUI.Name = "Liquid"
		LiquidUI.Parent = self:Parent()
		LiquidUI.ZIndexBehavior = Enum.ZIndexBehavior.Global
		LiquidUI.IgnoreGuiInset = true
	end

	local Background_1 = Instance.new("Frame")
	local UICorner_1 = Instance.new("UICorner")
	local UIStroke_1 = Instance.new("UIStroke")
	local Shadow_1 = Instance.new("ImageLabel")
	local Effect_1 = Instance.new("Frame")
	local Grid_1 = Instance.new("ImageLabel")
	local UICorner_2 = Instance.new("UICorner")
	local GridDark_1 = Instance.new("ImageLabel")
	local UICorner_3 = Instance.new("UICorner")
	local ShadowCorner_1 = Instance.new("ImageLabel")

	Background_1.Name = "Background"
	Background_1.Parent = LiquidUI
	Background_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Background_1.BackgroundColor3 = Color3.fromRGB(14,15,20)
	Background_1.BackgroundTransparency = Transparent and 0.16 or 0
	Background_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Background_1.BorderSizePixel = 0
	Background_1.Position = UDim2.new(0.5, 0,0.5, 0)
	Background_1.Size = Liquid:VectorToUdim(if Mobile then MinSize else MaxSize)

	UICorner_1.Parent = Background_1

	UIStroke_1.Parent = Background_1
	UIStroke_1.Color = Color3.fromRGB(8,13,42)
	UIStroke_1.Thickness = 0.5

	Liquid.Blured = Liquid:BlurFrame(Background_1)

	Shadow_1.Name = "Shadow"
	Shadow_1.Parent = Background_1
	Shadow_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow_1.BackgroundColor3 = Color3.fromRGB(0,0,0)
	Shadow_1.BackgroundTransparency = 1
	Shadow_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Shadow_1.BorderSizePixel = 0
	Shadow_1.Position = UDim2.new(0.5, 0,0.5, 0)
	Shadow_1.Size = UDim2.new(1, 120,1, 120)
	Shadow_1.ZIndex = 0
	Shadow_1.Image = "rbxassetid://8992230677"
	Shadow_1.ImageColor3 = Color3.fromRGB(0,0,0)
	Shadow_1.ImageTransparency = 0.5
	Shadow_1.ScaleType = Enum.ScaleType.Slice
	Shadow_1.SliceCenter = Rect.new(99, 99, 99, 99)

	Effect_1.Name = "Effect"
	Effect_1.Parent = Background_1
	Effect_1.BackgroundColor3 = Color3.fromRGB(22,20,31)
	Effect_1.BackgroundTransparency = 1
	Effect_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Effect_1.BorderSizePixel = 0
	Effect_1.Size = UDim2.new(1, 0,1, 0)

	Grid_1.Name = "Grid"
	Grid_1.Parent = Effect_1
	Grid_1.BackgroundColor3 = Color3.fromRGB(22, 20, 31)
	Grid_1.BackgroundTransparency = 1
	Grid_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Grid_1.BorderSizePixel = 0
	Grid_1.Size = UDim2.new(1, 0,1, 0)
	Grid_1.Image = "rbxassetid://9968344105"
	Grid_1.ImageTransparency = 0.9750000238418579
	Grid_1.ScaleType = Enum.ScaleType.Tile
	Grid_1.TileSize = UDim2.new(0, 128,0, 128)

	UICorner_2.Parent = Grid_1

	GridDark_1.Name = "GridDark"
	GridDark_1.Parent = Effect_1
	GridDark_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	GridDark_1.BackgroundTransparency = 1
	GridDark_1.BorderColor3 = Color3.fromRGB(0,0,0)
	GridDark_1.BorderSizePixel = 0
	GridDark_1.Size = UDim2.new(1, 0,1, 0)
	GridDark_1.Image = "rbxassetid://9968344227"
	GridDark_1.ImageTransparency = 0.949999988079071
	GridDark_1.ScaleType = Enum.ScaleType.Tile
	GridDark_1.TileSize = UDim2.new(0, 128,0, 128)

	UICorner_3.Parent = GridDark_1

	ShadowCorner_1.Name = "ShadowCorner"
	ShadowCorner_1.Parent = Background_1
	ShadowCorner_1.AnchorPoint = Vector2.new(0.5, 0.5)
	ShadowCorner_1.BackgroundColor3 = Color3.fromRGB(0,0,0)
	ShadowCorner_1.BackgroundTransparency = 1
	ShadowCorner_1.BorderColor3 = Color3.fromRGB(0,0,0)
	ShadowCorner_1.BorderSizePixel = 0
	ShadowCorner_1.Position = UDim2.new(0.5, 0,0.5, 3)
	ShadowCorner_1.Size = UDim2.new(1, 24,1, 24)
	ShadowCorner_1.ZIndex = 0
	ShadowCorner_1.Image = "rbxassetid://138260268144845"
	ShadowCorner_1.ImageColor3 = Color3.fromRGB(0,0,0)
	ShadowCorner_1.ImageTransparency = 0.5
	ShadowCorner_1.ScaleType = Enum.ScaleType.Slice
	ShadowCorner_1.SliceCenter = Rect.new(99, 99, 99, 99)

	local ScaleUI = Instance.new('UIScale') do
		ScaleUI.Scale = RuntimeScaler
		ScaleUI.Parent = LiquidUI
	end

	local LiquidToggle = Instance.new("ScreenGui") do
		LiquidToggle.Name = "Liquid"
		LiquidToggle.Parent = self:Parent()
		LiquidToggle.ZIndexBehavior = Enum.ZIndexBehavior.Global
		LiquidToggle.IgnoreGuiInset = true
	end

	local On = true
	local closeopenui

	local Toggle = Instance.new("ImageLabel") do
		local Input_1 = Instance.new("TextButton")
		Toggle.Name = "Toggle"
		Toggle.Parent = LiquidToggle
		Toggle.AnchorPoint = Vector2.new(1, 0.5)
		Toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Toggle.BackgroundTransparency = 1
		Toggle.BorderColor3 = Color3.fromRGB(0,0,0)
		Toggle.BorderSizePixel = 0
		Toggle.Position = UDim2.new(0.015, 0,0.5, 0)
		Toggle.Size = UDim2.new(0, 7,0, 200)
		Toggle.Image = "rbxassetid://80999662900595"
		Toggle.ImageTransparency = 0.699999988079071
		Toggle.ScaleType = Enum.ScaleType.Slice
		Toggle.SliceCenter = Rect.new(256, 256, 256, 256)
		Toggle.SliceScale = 0.38671875

		Input_1.Name = "Input"
		Input_1.Parent = Toggle
		Input_1.Active = true
		Input_1.AnchorPoint = Vector2.new(0.5, 0.5)
		Input_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Input_1.BackgroundTransparency = 1
		Input_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Input_1.BorderSizePixel = 0
		Input_1.Position = UDim2.new(0.5, 0,0.5, 0)
		Input_1.Size = UDim2.new(1, 25,1, 25)
		Input_1.Font = Enum.Font.SourceSans
		Input_1.Text = ""
		Input_1.TextSize = 14
		Input_1.ZIndex = 99

		closeopenui = function(value)
			Liquid:Tween({
				v = Toggle,
				t = 0.2,
				s = "Back",
				d = "Out",
				g = {ImageTransparency = 0.3}
			}):Play()

			delay(0.05, function()
				Liquid:Tween({
					v = Toggle,
					t = 0.2,
					s = "Back",
					d = "Out",
					g = {ImageTransparency = 0.7}
				}):Play()
			end)

			if value then
				Liquid:Tween({
					v = ScaleUI,
					t = 0.5,
					s = "Sine",
					d = "Out",
					g = {Scale = 0}
				}):Play()
				Liquid:Tween({
					v = Background_1,
					t = 0.3,
					s = "Back",
					d = "In",
					g = {Position = UDim2.new(0.5, 0, 1, 0)}
				}):Play()
			else
				Liquid:Tween({
					v = ScaleUI,
					t = 0.3,
					s = "Sine",
					d = "Out",
					g = {Scale = RuntimeScaler}
				}):Play()
				Liquid:Tween({
					v = Background_1,
					t = 0.3,
					s = "Back",
					d = "Out",
					g = {Position = UDim2.new(0.5, 0,0.5, 0)}
				}):Play()
			end
		end

		Input_1.MouseButton1Click:Connect(function()
			closeopenui(On)
			On = not On
		end)

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not gameProcessed and input.KeyCode == Keybind then
				closeopenui(On)
				On = not On
			end
		end)
	end

	local Header = Instance.new("Frame")
	local Window_1 = Instance.new("Frame")
	local UIListLayout_1 = Instance.new("UIListLayout")
	local Corner_1 = Instance.new("Frame")
	local Info_1 = Instance.new("Frame")
	local UIListLayout_2 = Instance.new("UIListLayout")
	local UIPadding_1 = Instance.new("UIPadding")
	local Text_1 = Instance.new("Frame")
	local Title_1 = Instance.new("TextLabel")
	local UIListLayout_3 = Instance.new("UIListLayout")
	local Desc_1 = Instance.new("TextLabel")
	local Logo_1 = Instance.new("ImageLabel")
	local HeadButton_1 = Instance.new("Frame")
	local UIListLayout_4 = Instance.new("UIListLayout")
	local UIPadding_2 = Instance.new("UIPadding")
	local MaxSize_1 = Instance.new("Frame")
	local asset_1 = Instance.new("ImageLabel")
	local Destroy_1 = Instance.new("Frame")
	local asset_2 = Instance.new("ImageLabel")
	local Minisize_1 = Instance.new("Frame")
	local asset_3 = Instance.new("ImageLabel")
	local UIPadding_3 = Instance.new("UIPadding")

	Header.Name = "Header"
	Header.Parent = Background_1
	Header.BackgroundColor3 = Color3.fromRGB(19,18,24)
	Header.BackgroundTransparency = 1
	Header.BorderColor3 = Color3.fromRGB(0,0,0)
	Header.BorderSizePixel = 0
	Header.Size = UDim2.new(1, 0,0, 45)

	Window_1.Name = "Window"
	Window_1.Parent = Header
	Window_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Window_1.BackgroundTransparency = 1
	Window_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Window_1.BorderSizePixel = 0
	Window_1.Size = UDim2.new(1, 0,1, 0)

	UIListLayout_1.Parent = Window_1
	UIListLayout_1.Padding = UDim.new(0,5)
	UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

	Corner_1.Name = "Corner"
	Corner_1.Parent = Window_1
	Corner_1.AnchorPoint = Vector2.new(0, 0.5)
	Corner_1.BackgroundColor3 = Color3.fromRGB(29,29,28)
	Corner_1.BackgroundTransparency = 1
	Corner_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Corner_1.BorderSizePixel = 0
	Corner_1.Position = UDim2.new(0, 0,0.5, 0)
	Corner_1.Size = UDim2.new(1, 0,0, 40)

	Info_1.Name = "Info"
	Info_1.Parent = Corner_1
	Info_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Info_1.BackgroundTransparency = 1
	Info_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Info_1.BorderSizePixel = 0
	Info_1.Size = UDim2.new(1, 0,1, 0)

	UIListLayout_2.Parent = Info_1
	UIListLayout_2.Padding = UDim.new(0,10)
	UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

	UIPadding_1.Parent = Info_1
	UIPadding_1.PaddingLeft = UDim.new(0,8)

	Text_1.Name = "Text"
	Text_1.Parent = Info_1
	Text_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Text_1.BackgroundTransparency = 1
	Text_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Text_1.BorderSizePixel = 0
	Text_1.Position = UDim2.new(0, 0,0.100000001, 0)
	Text_1.Size = UDim2.new(0, 111,0, 32)

	Title_1.Name = "Title"
	Title_1.Parent = Text_1
	Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Title_1.BackgroundTransparency = 1
	Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Title_1.BorderSizePixel = 0
	Title_1.Size = UDim2.new(0, 200,0, 14)
	Title_1.Font = Enum.Font.GothamSemibold
	Title_1.RichText = true
	Title_1.Text = Title
	Title_1.TextColor3 = Color3.fromRGB(235,235,235)
	Title_1.TextSize = 14
	Title_1.TextXAlignment = Enum.TextXAlignment.Left

	UIListLayout_3.Parent = Text_1
	UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_3.VerticalAlignment = Enum.VerticalAlignment.Center

	Desc_1.Name = "Desc"
	Desc_1.Parent = Text_1
	Desc_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Desc_1.BackgroundTransparency = 1
	Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Desc_1.BorderSizePixel = 0
	Desc_1.Size = UDim2.new(0, 200,0, 14)
	Desc_1.Font = Enum.Font.GothamSemibold
	Desc_1.RichText = true
	Desc_1.Text = Description
	Desc_1.TextColor3 = Color3.fromRGB(145, 145, 145)
	Desc_1.TextSize = 10
	Desc_1.TextTransparency = 0
	Desc_1.TextXAlignment = Enum.TextXAlignment.Left

	Logo_1.Name = "Logo"
	Logo_1.Parent = Info_1
	Logo_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Logo_1.BackgroundTransparency = 1
	Logo_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Logo_1.BorderSizePixel = 0
	Logo_1.LayoutOrder = -1
	Logo_1.Size = UDim2.new(0, 22,0, 22)
	Logo_1.Image = Liquid:Asset(Logo)

	HeadButton_1.Name = "HeadButton"
	HeadButton_1.Parent = Corner_1
	HeadButton_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	HeadButton_1.BackgroundTransparency = 1
	HeadButton_1.BorderColor3 = Color3.fromRGB(0,0,0)
	HeadButton_1.BorderSizePixel = 0
	HeadButton_1.Size = UDim2.new(1, 0,1, 0)

	UIListLayout_4.Parent = HeadButton_1
	UIListLayout_4.Padding = UDim.new(0,7)
	UIListLayout_4.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_4.HorizontalAlignment = Enum.HorizontalAlignment.Right
	UIListLayout_4.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_4.VerticalAlignment = Enum.VerticalAlignment.Center

	UIPadding_2.Parent = HeadButton_1
	UIPadding_2.PaddingBottom = UDim.new(0,4)
	UIPadding_2.PaddingRight = UDim.new(0,3)

	MaxSize_1.Name = "MaxSize"
	MaxSize_1.Parent = HeadButton_1
	MaxSize_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	MaxSize_1.BackgroundTransparency = 1
	MaxSize_1.BorderColor3 = Color3.fromRGB(0,0,0)
	MaxSize_1.BorderSizePixel = 0
	MaxSize_1.LayoutOrder = 998
	MaxSize_1.Size = UDim2.new(0, 25,0, 25)

	asset_1.Name = "asset"
	asset_1.Parent = MaxSize_1
	asset_1.AnchorPoint = Vector2.new(0.5, 0.5)
	asset_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	asset_1.BackgroundTransparency = 1
	asset_1.BorderColor3 = Color3.fromRGB(0,0,0)
	asset_1.BorderSizePixel = 0
	asset_1.Position = UDim2.new(0.5, 0,0.5, 0)
	asset_1.Size = UDim2.new(0, 16,0, 16)
	asset_1.Image = "rbxassetid://9886659406"

	Destroy_1.Name = "Destroy"
	Destroy_1.Parent = HeadButton_1
	Destroy_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Destroy_1.BackgroundTransparency = 1
	Destroy_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Destroy_1.BorderSizePixel = 0
	Destroy_1.LayoutOrder = 999
	Destroy_1.Size = UDim2.new(0, 25,0, 25)

	asset_2.Name = "asset"
	asset_2.Parent = Destroy_1
	asset_2.AnchorPoint = Vector2.new(0.5, 0.5)
	asset_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
	asset_2.BackgroundTransparency = 1
	asset_2.BorderColor3 = Color3.fromRGB(0,0,0)
	asset_2.BorderSizePixel = 0
	asset_2.Position = UDim2.new(0.5, 0,0.5, 0)
	asset_2.Size = UDim2.new(0, 16,0, 16)
	asset_2.Image = "rbxassetid://9886659671"

	Minisize_1.Name = "Minisize"
	Minisize_1.Parent = HeadButton_1
	Minisize_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Minisize_1.BackgroundTransparency = 1
	Minisize_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Minisize_1.BorderSizePixel = 0
	Minisize_1.LayoutOrder = 995
	Minisize_1.Size = UDim2.new(0, 25,0, 25)

	asset_3.Name = "asset"
	asset_3.Parent = Minisize_1
	asset_3.AnchorPoint = Vector2.new(0.5, 0.5)
	asset_3.BackgroundColor3 = Color3.fromRGB(255,255,255)
	asset_3.BackgroundTransparency = 1
	asset_3.BorderColor3 = Color3.fromRGB(0,0,0)
	asset_3.BorderSizePixel = 0
	asset_3.Position = UDim2.new(0.5, 0,0.5, 0)
	asset_3.Size = UDim2.new(0, 16,0, 16)
	asset_3.Image = "rbxassetid://9886659276"

	UIPadding_3.Parent = Window_1
	UIPadding_3.PaddingLeft = UDim.new(0,4)
	UIPadding_3.PaddingRight = UDim.new(0,5)
	UIPadding_3.PaddingTop = UDim.new(0,3)

	if not Mobile then
		local MinSize = Vector2.new(450, 320)
		local MaxSize = Vector2.new(800, 600)
		local LastSize = Background_1.Size
		local Threshold = 100
		local MaxButton = Liquid:Button(MaxSize_1)

		local function Maxs(value)
			if value then
				if Background_1.Size.Y.Offset ~= MaxSize.Y then
					local MaxY = Liquid:Tween({
						v = Background_1,
						t = 0.2,
						s = "Exponential",
						d = "Out",
						g = {Size = UDim2.new(0, Background_1.Size.X.Offset, 0, MaxSize.Y)}
					})

					MaxY:Play()
					MaxY.Completed:Wait()
				end

				if Background_1.Size.X.Offset ~= MaxSize.X then
					Liquid:Tween({
						v = Background_1,
						t = 0.2,
						s = "Exponential",
						d = "Out",
						g = {Size = UDim2.new(0, MaxSize.X, 0, Background_1.Size.Y.Offset)}
					}):Play()
				end
			else
				if Background_1.Size.X.Offset ~= MinSize.X then
					local MinX = Liquid:Tween({
						v = Background_1,
						t = 0.2,
						s = "Exponential",
						d = "Out",
						g = {Size = UDim2.new(0, MinSize.X, 0, Background_1.Size.Y.Offset)}
					})

					MinX:Play()
					MinX.Completed:Wait()
				end

				if Background_1.Size.Y.Offset ~= MinSize.Y then
					Liquid:Tween({
						v = Background_1,
						t = 0.2,
						s = "Exponential",
						d = "Out",
						g = {Size = UDim2.new(0, Background_1.Size.X.Offset, 0, MinSize.Y)}
					}):Play()
				end
			end
		end

		MaxButton.MouseButton1Click:Connect(function()
			LastSize = Background_1.Size

			local curX = LastSize.X.Offset
			local curY = LastSize.Y.Offset

			local distanceToMin = math.sqrt((curX - MinSize.X)^2 + (curY - MinSize.Y)^2)
			local distanceToMax = math.sqrt((curX - MaxSize.X)^2 + (curY - MaxSize.Y)^2)

			if distanceToMin <= Threshold then
				Maxs(true)
			elseif distanceToMax <= Threshold then
				Maxs(false)
			else
				Maxs(true)
			end
		end)
	else
		MaxSize_1.Visible = false
	end

	do
		local MinisizeButton = Liquid:Button(Minisize_1)

		MinisizeButton.MouseButton1Click:Connect(function()
			closeopenui(On)
			On = not On
		end)
	end

	do
		local CloseButton = Liquid:Button(Destroy_1)

		CloseButton.MouseButton1Click:Connect(function()
			LiquidUI:Destroy()
			LiquidToggle:Destroy()
		end)
	end

	local Components = Instance.new("Frame")
	local Draggable_1 = Instance.new("ImageLabel")
	local Input_1 = Instance.new("TextButton")
	local Size_1 = Instance.new("Frame")

	Components.Name = "Components"
	Components.Parent = Background_1
	Components.AnchorPoint = Vector2.new(0.5, 0.5)
	Components.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Components.BackgroundTransparency = 1
	Components.BorderColor3 = Color3.fromRGB(0,0,0)
	Components.BorderSizePixel = 0
	Components.Position = UDim2.new(0.5, 0,0.5, 0)
	Components.Size = UDim2.new(1, 0,1, 0)

	Draggable_1.Name = "Draggable"
	Draggable_1.Parent = Components
	Draggable_1.AnchorPoint = Vector2.new(0.5, 0)
	Draggable_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Draggable_1.BackgroundTransparency = 1
	Draggable_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Draggable_1.BorderSizePixel = 0
	Draggable_1.Position = UDim2.new(0.5, 0,1, 4)
	Draggable_1.Size = UDim2.new(0, 200,0, 4)
	Draggable_1.Image = "rbxassetid://80999662900595"
	Draggable_1.ImageTransparency = 0.800000011920929
	Draggable_1.ScaleType = Enum.ScaleType.Slice
	Draggable_1.SliceCenter = Rect.new(256, 256, 256, 256)
	Draggable_1.SliceScale = 0.38671875

	Input_1.Name = "Input"
	Input_1.Parent = Draggable_1
	Input_1.Active = true
	Input_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Input_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Input_1.BackgroundTransparency = 1
	Input_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Input_1.BorderSizePixel = 0
	Input_1.Position = UDim2.new(0.5, 0,0.5, 0)
	Input_1.Size = UDim2.new(1, 12,1, 12)
	Input_1.Font = Enum.Font.SourceSans
	Input_1.Text = ""
	Input_1.TextSize = 14

	Size_1.Name = "Size"
	Size_1.Parent = Components
	Size_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Size_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Size_1.BackgroundTransparency = 1
	Size_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Size_1.BorderSizePixel = 0
	Size_1.Position = UDim2.new(1, 0,1, 0)
	Size_1.Size = UDim2.new(0, 40,0, 40)
	Size_1.ZIndex = -99

	Liquid:Draggable(Input_1, Background_1)
	Liquid:Draggable(Header, Background_1)
	Liquid:Resize(Size_1, Background_1, MinSize, MaxSize, 2)

	local TabsScale = Instance.new("Frame")
	local Tabs_1 = Instance.new("Frame")
	local TabsScrolling_1 = Instance.new("ScrollingFrame")
	local UIListLayout_1 = Instance.new("UIListLayout")
	local UIPadding_1 = Instance.new("UIPadding")
	local LineTab_1 = Instance.new("Frame")
	local UIPadding_2 = Instance.new("UIPadding")

	TabsScale.Name = "TabsScale"
	TabsScale.Parent = Background_1
	TabsScale.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TabsScale.BackgroundTransparency = 1
	TabsScale.BorderColor3 = Color3.fromRGB(0,0,0)
	TabsScale.BorderSizePixel = 0
	TabsScale.Size = UDim2.new(1, 0,1, 0)

	Tabs_1.Name = "Tabs"
	Tabs_1.Parent = TabsScale
	Tabs_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Tabs_1.BackgroundTransparency = 1
	Tabs_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Tabs_1.BorderSizePixel = 0
	Tabs_1.Size = UDim2.new(0, 45,1, 0)

	TabsScrolling_1.Name = "TabsScrolling"
	TabsScrolling_1.Parent = Tabs_1
	TabsScrolling_1.Active = true
	TabsScrolling_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TabsScrolling_1.BackgroundTransparency = 1
	TabsScrolling_1.BorderColor3 = Color3.fromRGB(0,0,0)
	TabsScrolling_1.BorderSizePixel = 0
	TabsScrolling_1.Size = UDim2.new(1, 0,1, 0)
	TabsScrolling_1.ClipsDescendants = true
	TabsScrolling_1.AutomaticCanvasSize = Enum.AutomaticSize.None
	TabsScrolling_1.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
	TabsScrolling_1.CanvasPosition = Vector2.new(0, 0)
	TabsScrolling_1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
	TabsScrolling_1.HorizontalScrollBarInset = Enum.ScrollBarInset.None
	TabsScrolling_1.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	TabsScrolling_1.ScrollBarImageColor3 = Color3.fromRGB(0,0,0)
	TabsScrolling_1.ScrollBarImageTransparency = 1
	TabsScrolling_1.ScrollBarThickness = 0
	TabsScrolling_1.ScrollingDirection = Enum.ScrollingDirection.XY
	TabsScrolling_1.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
	TabsScrolling_1.VerticalScrollBarInset = Enum.ScrollBarInset.None
	TabsScrolling_1.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

	UIListLayout_1.Parent = TabsScrolling_1
	UIListLayout_1.Padding = UDim.new(0,3)
	UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder

	UIListLayout_1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabsScrolling_1.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_1.AbsoluteContentSize.Y + 15)
	end)

	UIPadding_1.Parent = TabsScrolling_1
	UIPadding_1.PaddingBottom = UDim.new(0,5)
	UIPadding_1.PaddingTop = UDim.new(0,5)

	LineTab_1.Name = "LineTab"
	LineTab_1.Parent = Tabs_1
	LineTab_1.BackgroundColor3 = Color3.fromRGB(65,65,65)
	LineTab_1.BackgroundTransparency = 0.5
	LineTab_1.BorderColor3 = Color3.fromRGB(0,0,0)
	LineTab_1.BorderSizePixel = 0
	LineTab_1.Position = UDim2.new(1, 0,0, 0)
	LineTab_1.Size = UDim2.new(0, 1,1, 0)

	UIPadding_2.Parent = TabsScale
	UIPadding_2.PaddingTop = UDim.new(0,46)

	local PageScale = Instance.new("Frame")
	local Page_1 = Instance.new("Frame")
	local UIPadding_1 = Instance.new("UIPadding")
	local UIPadding_2 = Instance.new("UIPadding")
	local LineUpper_1 = Instance.new("Frame")

	PageScale.Name = "PageScale"
	PageScale.Parent = Background_1
	PageScale.BackgroundColor3 = Color3.fromRGB(255,255,255)
	PageScale.BackgroundTransparency = 1
	PageScale.BorderColor3 = Color3.fromRGB(0,0,0)
	PageScale.BorderSizePixel = 0
	PageScale.Size = UDim2.new(1, 0,1, 0)

	Page_1.Name = "Page"
	Page_1.Parent = PageScale
	Page_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Page_1.BackgroundTransparency = 1
	Page_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Page_1.BorderSizePixel = 0
	Page_1.Size = UDim2.new(1, 0,1, 0)

	UIPadding_1.Parent = Page_1
	UIPadding_1.PaddingLeft = UDim.new(0,45)

	UIPadding_2.Parent = PageScale
	UIPadding_2.PaddingLeft = UDim.new(0,1)
	UIPadding_2.PaddingRight = UDim.new(0,1)
	UIPadding_2.PaddingTop = UDim.new(0,45)

	LineUpper_1.Name = "LineUpper"
	LineUpper_1.Parent = PageScale
	LineUpper_1.BackgroundColor3 = Color3.fromRGB(65,65,65)
	LineUpper_1.BackgroundTransparency = 0.5
	LineUpper_1.BorderColor3 = Color3.fromRGB(0,0,0)
	LineUpper_1.BorderSizePixel = 0
	LineUpper_1.Size = UDim2.new(1, 0,0, 1)

	local ListTabs = {
		Value = false
	}

	function ListTabs:Tabs(icon)
		local Addtab = Instance.new("Frame")
		local UICorner_1 = Instance.new("UICorner")
		local Icon_1 = Instance.new("ImageLabel")
		local Button = Liquid:Button(Addtab)

		Addtab.Name = "Addtab"
		Addtab.Parent = TabsScrolling_1
		Addtab.BackgroundColor3 = Color3.fromRGB(100,100,100)
		Addtab.BackgroundTransparency = 1
		Addtab.BorderColor3 = Color3.fromRGB(0,0,0)
		Addtab.BorderSizePixel = 0
		Addtab.Size = UDim2.new(0, 35,0, 35)

		UICorner_1.Parent = Addtab
		UICorner_1.CornerRadius = UDim.new(0,5)

		Icon_1.Name = "Icon"
		Icon_1.Parent = Addtab
		Icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
		Icon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Icon_1.BackgroundTransparency = 1
		Icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Icon_1.BorderSizePixel = 0
		Icon_1.Position = UDim2.new(0.5, 0,0.5, 0)
		Icon_1.Size = UDim2.new(0, 15,0, 15)
		Icon_1.ImageTransparency = 0.5
		Icon_1.Image = icon and Liquid:Asset(icon) or 0

		local SelectLine = Instance.new("Frame")
		local UICorner_1 = Instance.new("UICorner")

		SelectLine.Name = "SelectLine"
		SelectLine.Parent = Addtab
		SelectLine.BackgroundTransparency = 1
		SelectLine.AnchorPoint = Vector2.new(0.5, 0.5)
		SelectLine.BackgroundColor3 = Highlight
		SelectLine.BorderColor3 = Color3.fromRGB(0,0,0)
		SelectLine.BorderSizePixel = 0
		SelectLine.Position = UDim2.new(0, 0,0.5, 0)
		SelectLine.Size = UDim2.new(0, 4,0, 16)

		UICorner_1.Parent = SelectLine
		UICorner_1.CornerRadius = UDim.new(1,0)

		local AddPage = Instance.new("Frame")
		local UIPadding_1 = Instance.new("UIPadding")
		local PageScrolling_1 = Instance.new("ScrollingFrame")
		local UIListLayout_1 = Instance.new("UIListLayout")

		AddPage.Name = "AddPage"
		AddPage.Parent = Page_1
		AddPage.BackgroundColor3 = Color3.fromRGB(255,255,255)
		AddPage.BackgroundTransparency = 1
		AddPage.BorderColor3 = Color3.fromRGB(0,0,0)
		AddPage.BorderSizePixel = 0
		AddPage.Size = UDim2.new(1, 0,1, 0)
		AddPage.Visible = false
		AddPage.Position = UDim2.new(0, 0, 0, 15)

		UIPadding_1.Parent = PageScrolling_1
		UIPadding_1.PaddingBottom = UDim.new(0,5)
		UIPadding_1.PaddingLeft = UDim.new(0,5)
		UIPadding_1.PaddingRight = UDim.new(0,5)
		UIPadding_1.PaddingTop = UDim.new(0,7)

		PageScrolling_1.Name = "PageScrolling"
		PageScrolling_1.Parent = AddPage
		PageScrolling_1.Active = true
		PageScrolling_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		PageScrolling_1.BackgroundTransparency = 1
		PageScrolling_1.BorderColor3 = Color3.fromRGB(0,0,0)
		PageScrolling_1.BorderSizePixel = 0
		PageScrolling_1.Size = UDim2.new(1, 0,1, 0)
		PageScrolling_1.ClipsDescendants = true
		PageScrolling_1.AutomaticCanvasSize = Enum.AutomaticSize.None
		PageScrolling_1.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
		PageScrolling_1.CanvasPosition = Vector2.new(0, 0)
		PageScrolling_1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
		PageScrolling_1.HorizontalScrollBarInset = Enum.ScrollBarInset.None
		PageScrolling_1.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
		PageScrolling_1.ScrollBarThickness = 0
		PageScrolling_1.ScrollingDirection = Enum.ScrollingDirection.XY
		PageScrolling_1.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
		PageScrolling_1.VerticalScrollBarInset = Enum.ScrollBarInset.None
		PageScrolling_1.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

		UIListLayout_1.Parent = PageScrolling_1
		UIListLayout_1.Padding = UDim.new(0,5)
		UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder

		UIListLayout_1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			PageScrolling_1.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_1.AbsoluteContentSize.Y + 15)
		end)

		local function OnSelect()
			for _, v in pairs(Page_1:GetChildren()) do
				if v.Name == "AddPage" then
					v.Visible = false
					v.Position = UDim2.new(0, 0, 0, 15)
				end
			end

			for _, v in pairs(TabsScrolling_1:GetChildren()) do
				if v.Name == "Addtab" then
					Liquid:Tween({
						v = v,
						t = 0.2,
						s = "Exponential",
						d = "Out",
						g = {BackgroundTransparency = 1}
					}):Play()

					Liquid:Tween({
						v = v.SelectLine,
						t = 0.2,
						s = "Exponential",
						d = "Out",
						g = { BackgroundTransparency = 1 }
					}):Play()

					Liquid:Tween({
						v = v.Icon,
						t = 0.2,
						s = "Exponential",
						d = "Out",
						g = { ImageTransparency = 0.5 }
					}):Play()
				end
			end

			Liquid:Tween({
				v = Addtab,
				t = 0.2,
				s = "Exponential",
				d = "Out",
				g = {BackgroundTransparency = 0.89}
			}):Play()

			Liquid:Tween({
				v = Icon_1,
				t = 0.2,
				s = "Exponential",
				d = "Out",
				g = { ImageTransparency = 0 }
			}):Play()

			Liquid:Tween({
				v = SelectLine,
				t = 0.2,
				s = "Exponential",
				d = "Out",
				g = { BackgroundTransparency = 0 }
			}):Play()

			SelectLine.Size = UDim2.new(0, 4,0, 0)
			task.delay(0.05, function()
				Liquid:Tween({
					v = SelectLine,
					t = 0.3,
					s = "Back",
					d = "Out",
					g = { Size = UDim2.new(0, 4,0, 16) }
				}):Play()
			end)

			AddPage.Visible = true

			Liquid:Tween({
				v = AddPage,
				t = 0.3,
				s = "Back",
				d = "Out",
				g = {Position = UDim2.new(0, 0,0, 0)}
			}):Play()
		end

		task.delay(0.1, function()
			if not ListTabs.Value then
				ListTabs.Value = true

				Liquid:Tween({
					v = Addtab,
					t = 0.2,
					s = "Exponential",
					d = "Out",
					g = {BackgroundTransparency = 0.89}
				}):Play()

				Liquid:Tween({
					v = Icon_1,
					t = 0.2,
					s = "Exponential",
					d = "Out",
					g = { ImageTransparency = 0 }
				}):Play()

				Liquid:Tween({
					v = SelectLine,
					t = 0.2,
					s = "Exponential",
					d = "Out",
					g = { BackgroundTransparency = 0 }
				}):Play()

				SelectLine.Size = UDim2.new(0, 4,0, 0)
				task.delay(0.05, function()
					Liquid:Tween({
						v = SelectLine,
						t = 0.3,
						s = "Back",
						d = "Out",
						g = { Size = UDim2.new(0, 4,0, 16) }
					}):Play()
				end)

				AddPage.Visible = true

				Liquid:Tween({
					v = AddPage,
					t = 0.3,
					s = "Back",
					d = "Out",
					g = {Position = UDim2.new(0, 0,0, 0)}
				}):Play()
			end
		end)

		Button.MouseButton1Click:Connect(OnSelect)

		local __index = {}

		function __index:Select()
			OnSelect()
		end

		function __index:Section(configs)
			local Title = configs.Title or 'Section'
			local Icon = configs.Icon or nil

			local Section = Instance.new("Frame")
			local UIListLayout_1 = Instance.new("UIListLayout")
			local Title_1 = Instance.new("TextLabel")
			local Icon_1 = Instance.new("ImageLabel")
			local UIPadding_1 = Instance.new("UIPadding")

			Section.Name = "Section"
			Section.Parent = PageScrolling_1
			Section.AnchorPoint = Vector2.new(0.5, 0.5)
			Section.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Section.BackgroundTransparency = 1
			Section.BorderColor3 = Color3.fromRGB(0,0,0)
			Section.BorderSizePixel = 0
			Section.Position = UDim2.new(0.5, 0,0.5, 0)
			Section.Size = UDim2.new(1, 0,0, 20)

			UIListLayout_1.Parent = Section
			UIListLayout_1.Padding = UDim.new(0,5)
			UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

			Title_1.Name = "Title"
			Title_1.Parent = Section
			Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Title_1.BackgroundTransparency = 1
			Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Title_1.BorderSizePixel = 0
			Title_1.LayoutOrder = -1
			Title_1.Position = UDim2.new(0.052873563, 0,-0.25, 0)
			Title_1.Size = UDim2.new(0.899999976, 0,0, 15)
			Title_1.Font = Enum.Font.GothamBold
			Title_1.RichText = true
			Title_1.Text = Title
			Title_1.TextColor3 = Color3.fromRGB(235,235,235)
			Title_1.TextSize = 15
			Title_1.TextTransparency = 0.2
			Title_1.TextXAlignment = Enum.TextXAlignment.Left

			if Icon then
				Icon_1.Name = "Icon"
				Icon_1.Parent = Section
				Icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Icon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Icon_1.BackgroundTransparency = 1
				Icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Icon_1.BorderSizePixel = 0
				Icon_1.LayoutOrder = -5
				Icon_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Icon_1.Size = UDim2.new(0, 16,0, 16)
				Icon_1.Image = Liquid:Asset(Icon)
				Icon_1.ImageTransparency = 0.2
			end

			UIPadding_1.Parent = Section
			UIPadding_1.PaddingBottom = UDim.new(0,10)
			UIPadding_1.PaddingLeft = UDim.new(0,5)
			UIPadding_1.PaddingRight = UDim.new(0,5)
			UIPadding_1.PaddingTop = UDim.new(0,10)

			local Setting = {}

			function Setting:Visible(value)
				Section.Visible = value
			end

			return Setting
		end

		function __index:Paragraph(configs)
			local Title = configs.Title or "Title"
			local Desc = configs.Desc or nil

			local Template = Liquid:Template(PageScrolling_1, Title, Desc, nil)

			local Setting = {}

			function Setting:SetTitle(Text)
				Template.Text.Title.Text = Text
			end

			function Setting:SetDesc(Text)
				Template.Text.Desc.Text = Text
			end

			function Setting:SetAll(texts)
				Template.Text.Title.Text = texts[1]
				Template.Text.Desc.Text = texts[2]
			end

			function Setting:Visible(value)
				Template.Visible = value
			end

			function Setting:GetFrame()
				return Template
			end

			function Setting:Slider(configs)
				local Icon = configs.Icon or nil
				local Min = configs.Min or 1
				local Max = configs.Max or 10
				local Value = configs.Value or Min
				local Rounding = configs.Rounding or 0
				local Callback = configs.Callback or (function( ... )
					return ...
				end)

				local Template = Instance.new("Frame")
				local UIStroke_1 = Instance.new("UIStroke")
				local UICorner_1 = Instance.new("UICorner")
				local Slider_1 = Instance.new("Frame")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local Icon_1 = Instance.new("ImageLabel")
				local UIPadding_1 = Instance.new("UIPadding")
				local DarkBar_1 = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local ActiveBar_1 = Instance.new("Frame")
				local UICorner_3 = Instance.new("UICorner")
				local Circle_1 = Instance.new("Frame")
				local UICorner_4 = Instance.new("UICorner")
				local Slide_1 = Instance.new("Frame")
				local Scaler_1 = Instance.new("Frame")
				local UIPadding_2 = Instance.new("UIPadding")
				local Textbox_1 = Instance.new("Frame")
				local UICorner_5 = Instance.new("UICorner")
				local UIStroke_2 = Instance.new("UIStroke")
				local UIPadding_3 = Instance.new("UIPadding")
				local Icon_2 = Instance.new("ImageLabel")
				local UIListLayout_2 = Instance.new("UIListLayout")
				local Value_1 = Instance.new("TextBox")
				local UIListLayout_3 = Instance.new("UIListLayout")

				local Button = Liquid:Button(Slide_1)

				Template.Name = "Template"
				Template.Parent = PageScrolling_1
				Template.BackgroundColor3 = Color3.fromRGB(70,70,70)
				Template.BackgroundTransparency = 0.8199999928474426
				Template.BorderColor3 = Color3.fromRGB(0,0,0)
				Template.BorderSizePixel = 0
				Template.Size = UDim2.new(1, 0,0, 50)

				UIStroke_1.Parent = Template
				UIStroke_1.Color = Color3.fromRGB(25,25,25)
				UIStroke_1.Thickness = 1
				UIStroke_1.Transparency = 0.15

				UICorner_1.Parent = Template
				UICorner_1.CornerRadius = UDim.new(0,4)

				Slider_1.Name = "Slider"
				Slider_1.Parent = Template
				Slider_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Slider_1.BackgroundTransparency = 1
				Slider_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Slider_1.BorderSizePixel = 0
				Slider_1.Size = UDim2.new(1, 0,1, 0)

				UIListLayout_1.Parent = Slider_1
				UIListLayout_1.Padding = UDim.new(0,20)
				UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

				Icon_1.Name = "Icon"
				Icon_1.Parent = Slider_1
				Icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Icon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Icon_1.BackgroundTransparency = 1
				Icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Icon_1.BorderSizePixel = 0
				Icon_1.LayoutOrder = -5
				Icon_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Icon_1.Size = UDim2.new(0, 20,0, 20)
				Icon_1.Image = Liquid:Asset(Icon)
				Icon_1.ImageTransparency = 0.30000001192092896

				UIPadding_1.Parent = Slider_1
				UIPadding_1.PaddingLeft = UDim.new(0,15)

				DarkBar_1.Name = "DarkBar"
				DarkBar_1.Parent = Slider_1
				DarkBar_1.BackgroundColor3 = Color3.fromRGB(0,0,0)
				DarkBar_1.BackgroundTransparency = 0.75
				DarkBar_1.BorderColor3 = Color3.fromRGB(0,0,0)
				DarkBar_1.BorderSizePixel = 0
				DarkBar_1.Size = UDim2.new(1, -125,0, 5)

				UICorner_2.Parent = DarkBar_1

				ActiveBar_1.Name = "ActiveBar"
				ActiveBar_1.Parent = DarkBar_1
				ActiveBar_1.BackgroundColor3 = Highlight
				ActiveBar_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ActiveBar_1.BorderSizePixel = 0
				ActiveBar_1.Size = UDim2.new(0.5, 0,1, 0)

				UICorner_3.Parent = ActiveBar_1

				Circle_1.Name = "Circle"
				Circle_1.Parent = ActiveBar_1
				Circle_1.AnchorPoint = Vector2.new(1, 0.5)
				Circle_1.BackgroundColor3 = Highlight
				Circle_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Circle_1.BorderSizePixel = 0
				Circle_1.Position = UDim2.new(1, 0,0.5, 0)
				Circle_1.Size = UDim2.new(0, 15,0, 15)

				UICorner_4.Parent = Circle_1
				UICorner_4.CornerRadius = UDim.new(1,0)

				Slide_1.Name = "Slide"
				Slide_1.Parent = DarkBar_1
				Slide_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Slide_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Slide_1.BackgroundTransparency = 1
				Slide_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Slide_1.BorderSizePixel = 0
				Slide_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Slide_1.Size = UDim2.new(1, 10,1, 20)

				Scaler_1.Name = "Scaler"
				Scaler_1.Parent = Template
				Scaler_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Scaler_1.BackgroundTransparency = 1
				Scaler_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Scaler_1.BorderSizePixel = 0
				Scaler_1.Size = UDim2.new(1, 0,1, 0)

				UIPadding_2.Parent = Scaler_1
				UIPadding_2.PaddingRight = UDim.new(0,15)

				Textbox_1.Name = "Textbox"
				Textbox_1.Parent = Scaler_1
				Textbox_1.BackgroundColor3 = Color3.fromRGB(0,0,0)
				Textbox_1.BackgroundTransparency = 0.8999999761581421
				Textbox_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Textbox_1.BorderSizePixel = 0
				Textbox_1.Position = UDim2.new(0.850467265, 0,0.301587313, 0)
				Textbox_1.Size = UDim2.new(0, 60,0, 25)

				UICorner_5.Parent = Textbox_1
				UICorner_5.CornerRadius = UDim.new(0,5)

				UIStroke_2.Parent = Textbox_1
				UIStroke_2.Color = Color3.fromRGB(75,75,75)
				UIStroke_2.Thickness = 1

				UIPadding_3.Parent = Textbox_1
				UIPadding_3.PaddingRight = UDim.new(0,5)

				Icon_2.Name = "Icon"
				Icon_2.Parent = Textbox_1
				Icon_2.AnchorPoint = Vector2.new(0.5, 0.5)
				Icon_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Icon_2.BackgroundTransparency = 1
				Icon_2.BorderColor3 = Color3.fromRGB(0,0,0)
				Icon_2.BorderSizePixel = 0
				Icon_2.Position = UDim2.new(0.5, 0,0.5, 0)
				Icon_2.Size = UDim2.new(0, 15,0, 15)
				Icon_2.Image = "rbxassetid://123909267283672"
				Icon_2.ImageTransparency = 0.10000000149011612

				UIListLayout_2.Parent = Textbox_1
				UIListLayout_2.Padding = UDim.new(0,5)
				UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
				UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Right
				UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

				Value_1.Name = "Value"
				Value_1.Parent = Textbox_1
				Value_1.Active = true
				Value_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Value_1.BackgroundTransparency = 1
				Value_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Value_1.BorderSizePixel = 0
				Value_1.Size = UDim2.new(1, -25,1, 0)
				Value_1.Font = Enum.Font.GothamMedium
				Value_1.PlaceholderColor3 = Color3.fromRGB(100,100,100)
				Value_1.PlaceholderText = ""
				Value_1.Text = "N/A"
				Value_1.TextColor3 = Color3.fromRGB(145,145,145)
				Value_1.TextSize = 12
				Value_1.TextXAlignment = Enum.TextXAlignment.Left

				UIListLayout_3.Parent = Scaler_1
				UIListLayout_3.HorizontalAlignment = Enum.HorizontalAlignment.Right
				UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_3.VerticalAlignment = Enum.VerticalAlignment.Center

				local function roundToDecimal(value, decimals)
					local factor = 10 ^ decimals
					return math.floor(value * factor + 0.5) / factor
				end

				local function updateSlider(value)
					value = math.clamp(value, Min, Max)
					value = roundToDecimal(value, Rounding)
					Liquid:Tween({
						v = ActiveBar_1,
						t = 0.5,
						s = "Exponential",
						d = "Out",
						g = {Size = UDim2.new((value - Min) / (Max - Min), 0, 1, 0)}
					}):Play()

					local startValue = tonumber(Value_1.Text) or 0
					local targetValue = value

					local steps = 5
					local currentValue = startValue

					for i = 1, steps do
						task.wait(0.01 / steps)
						currentValue = currentValue + (targetValue - startValue) / steps
						Value_1.Text = tostring(roundToDecimal(currentValue, Rounding))
					end

					Value_1.Text = tostring(roundToDecimal(targetValue, Rounding))

					Callback(value)
				end

				updateSlider(Value or 0)

				local function move(input)
					local sliderBar = DarkBar_1
					local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
					local value = relativeX * (Max - Min) + Min
					updateSlider(value)
				end

				Value_1.Focused:Connect(function()
					Slider_1.Visible = false

					Liquid:Tween({
						v = Textbox_1,
						t = 0.5,
						s = "Exponential",
						d = "Out",
						g = {
							Size = UDim2.new(1, -15, 0, 25)
						}
					}):Play()

					UIStroke_2.Color = Highlight
				end)

				Value_1.FocusLost:Connect(function()
					Liquid:Tween({
						v = Textbox_1,
						t = 0.5,
						s = "Exponential",
						d = "Out",
						g = {
							Size = UDim2.new(0, 60, 0, 25)
						}
					}):Play()

					delay(0.1, function()
						Slider_1.Visible = true
						UIStroke_2.Color = Color3.fromRGB(75,75,75)

						local value = tonumber(Value_1.Text) or Min
						updateSlider(value)
					end)
				end)

				local dragging = false

				Button.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						move(input)
					end
				end)

				Button.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						move(input)
					end
				end)

				local Setting = {}

				function Setting:SetValue(val)
					updateSlider(val)
				end

				return Setting
			end

			return Setting
		end

		function __index:Button(configs)
			local Title = configs.Title or "Title"
			local Desc = configs.Desc or nil
			local Callback = configs.Callback or (function( ... )
				return ...
			end)

			local Template = Liquid:Template(PageScrolling_1, Title, Desc, 65)
			local Button = Liquid:Button(Template)

			local Arrow = Instance.new("ImageLabel")
			Arrow.Name = "Arrow"
			Arrow.Parent = Template.Scaler
			Arrow.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Arrow.BackgroundTransparency = 1
			Arrow.BorderColor3 = Color3.fromRGB(0,0,0)
			Arrow.BorderSizePixel = 0
			Arrow.Size = UDim2.new(0, 16,0, 16)
			Arrow.Image = "rbxassetid://10709791437"

			local Setting = {}

			local function OnClick()
				for _, v in pairs(Page_1:GetChildren()) do
					if v.Name == "Dropdown" and v.Visible then
						return
					end
				end

				Callback(Setting)

				Liquid:Effect(Button, Template)
			end

			Button.MouseButton1Click:Connect(OnClick)

			function Setting:Fire()
				return Callback(self)
			end

			function Setting:SetCallback(func)
				Callback = func
			end

			function Setting:SetTitle(Text)
				Template.Text.Title.Text = Text
			end

			function Setting:SetDesc(Text)
				Template.Text.Desc.Text = Text
			end

			function Setting:SetAll(texts)
				Template.Text.Title.Text = texts[1]
				Template.Text.Desc.Text = texts[2]
			end

			function Setting:Visible(value)
				Template.Visible = value
			end

			function Setting:GetFrame()
				return Template
			end

			return Setting
		end

		function __index:Toggle(configs)
			local Title = configs.Title or 'Title'
			local Desc = configs.Desc or nil
			local Value = configs.Value or false
			local Callback = configs.Callback or (function( ... )
				return ...
			end)

			local Template = Liquid:Template(PageScrolling_1, Title, Desc, 65)
			local Button = Liquid:Button(Template)

			local CheckBackground = Instance.new("Frame")
			local UICorner_1 = Instance.new("UICorner")
			local UIStroke_1 = Instance.new("UIStroke")
			local Checker_1 = Instance.new("Frame")
			local UICorner_2 = Instance.new("UICorner")
			local Icon_1 = Instance.new("ImageLabel")

			CheckBackground.Name = "CheckBackground"
			CheckBackground.Parent = Template.Scaler
			CheckBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			CheckBackground.BackgroundTransparency = 0.9
			CheckBackground.BorderColor3 = Color3.fromRGB(0,0,0)
			CheckBackground.BorderSizePixel = 0
			CheckBackground.Size = UDim2.new(0, 22,0, 22)

			UICorner_1.Parent = CheckBackground
			UICorner_1.CornerRadius = UDim.new(0,5)

			UIStroke_1.Parent = CheckBackground
			UIStroke_1.Color = Color3.fromRGB(75,75,75)
			UIStroke_1.Thickness = 1

			Checker_1.Name = "Checker"
			Checker_1.Parent = CheckBackground
			Checker_1.BackgroundColor3 = Highlight
			Checker_1.BackgroundTransparency = 1
			Checker_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Checker_1.BorderSizePixel = 0
			Checker_1.Size = UDim2.new(1, 0,1, 0)

			UICorner_2.Parent = Checker_1
			UICorner_2.CornerRadius = UDim.new(0,5)

			Icon_1.Name = "Icon"
			Icon_1.Parent = Checker_1
			Icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
			Icon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Icon_1.BackgroundTransparency = 1
			Icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Icon_1.BorderSizePixel = 0
			Icon_1.Position = UDim2.new(0.5, 0,0.5, 0)
			Icon_1.Size = UDim2.new(0.6, 0,0.6, 0)
			Icon_1.Image = "rbxassetid://121742282171603"
			Icon_1.ImageColor3 = Color3.fromRGB(0,0,0)
			Icon_1.ImageTransparency = 1

			local Setting = {}

			local function OnChanged(value)
				for _, v in pairs(Page_1:GetChildren()) do
					if v.Name == "Dropdown" and v.Visible then
						return
					end
				end

				if value then 
					Callback(Setting, value)
					Icon_1.Size = UDim2.new(0.85, 0,0.85, 0)

					Liquid:Tween({
						v = Checker_1,
						t = 0.5,
						s = "Exponential",
						d = "Out",
						g = {
							BackgroundTransparency = 0
						}
					}):Play()

					Liquid:Tween({
						v = Icon_1,
						t = 0.5,
						s = "Exponential",
						d = "Out",
						g = {
							ImageTransparency = 0
						}
					}):Play()

					Liquid:Tween({
						v = Icon_1,
						t = 0.75,
						s = "Exponential",
						d = "Out",
						g = {
							Size = UDim2.new(0.6, 0,0.6, 0)
						}
					}):Play()

					UIStroke_1.Color = Color3.fromRGB(30, 30, 30)
				else
					Callback(Setting, value)
					Liquid:Tween({
						v = Checker_1,
						t = 0.5,
						s = "Exponential",
						d = "Out",
						g = {
							BackgroundTransparency = 1
						}
					}):Play()

					Liquid:Tween({
						v = Icon_1,
						t = 0.5,
						s = "Exponential",
						d = "Out",
						g = {
							ImageTransparency = 1
						}
					}):Play()

					UIStroke_1.Color = Color3.fromRGB(75,75,75)
				end

				Liquid:Effect(Button, Template)
			end

			Button.MouseButton1Click:Connect(function()
				for _, v in pairs(Page_1:GetChildren()) do
					if v.Name == "Dropdown" and v.Visible then
						return
					end
				end
				
				Value = not Value
				OnChanged(Value)
			end)

			OnChanged(Value)

			function Setting:SetValue(value)
				Value = value
				OnChanged(value)
			end

			function Setting:SetTitle(Text)
				Template.Text.Title.Text = Text
			end

			function Setting:SetDesc(Text)
				Template.Text.Desc.Text = Text
			end

			function Setting:SetAll(texts)
				Template.Text.Title.Text = texts[1]
				Template.Text.Desc.Text = texts[2]
			end

			function Setting:Visible(value)
				Template.Visible = value
			end

			function Setting:GetFrame()
				return Template
			end

			return Setting
		end

		function __index:Textbox(configs)
			local Title = configs.Title or "Title"
			local Desc = configs.Desc or nil
			local Value = configs.Value or "N/A"
			local PlaceHolder = configs.PlaceHolder or " ...... "
			local Callback = configs.Callback or (function( ... )
				return ...
			end)

			local Template = Liquid:Template(PageScrolling_1, Title, Desc, 120)

			local Setting = {}

			function Setting:SetTitle(Text)
				Template.Text.Title.Text = Text
			end

			function Setting:SetDesc(Text)
				Template.Text.Desc.Text = Text
			end

			function Setting:SetAll(texts)
				Template.Text.Title.Text = texts[1]
				Template.Text.Desc.Text = texts[2]
			end

			function Setting:Visible(value)
				Template.Visible = value
			end

			function Setting:GetFrame()
				return Template
			end

			local Textbox = Instance.new("Frame")
			local UICorner_1 = Instance.new("UICorner")
			local UIStroke_1 = Instance.new("UIStroke")
			local UIPadding_1 = Instance.new("UIPadding")
			local Icon_1 = Instance.new("ImageLabel")
			local UIListLayout_1 = Instance.new("UIListLayout")
			local TextBox_1 = Instance.new("TextBox")

			Textbox.Name = "Textbox"
			Textbox.Parent = Template.Scaler
			Textbox.BackgroundColor3 = Color3.fromRGB(0,0,0)
			Textbox.BackgroundTransparency = 0.9
			Textbox.BorderColor3 = Color3.fromRGB(0,0,0)
			Textbox.BorderSizePixel = 0
			Textbox.Position = UDim2.new(0.850467265, 0,0.301587313, 0)
			Textbox.Size = UDim2.new(0, 85,0, 25)

			UICorner_1.Parent = Textbox
			UICorner_1.CornerRadius = UDim.new(0,5)

			UIStroke_1.Parent = Textbox
			UIStroke_1.Color = Color3.fromRGB(75,75,75)
			UIStroke_1.Thickness = 1

			UIPadding_1.Parent = Textbox
			UIPadding_1.PaddingRight = UDim.new(0,5)

			Icon_1.Name = "Icon"
			Icon_1.Parent = Textbox
			Icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
			Icon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Icon_1.BackgroundTransparency = 1
			Icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Icon_1.BorderSizePixel = 0
			Icon_1.Position = UDim2.new(0.5, 0,0.5, 0)
			Icon_1.Size = UDim2.new(0, 15,0, 15)
			Icon_1.Image = "rbxassetid://123909267283672"
			Icon_1.ImageTransparency = 0.10000000149011612

			UIListLayout_1.Parent = Textbox
			UIListLayout_1.Padding = UDim.new(0,5)
			UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Right
			UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

			TextBox_1.Parent = Textbox
			TextBox_1.Active = true
			TextBox_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			TextBox_1.BackgroundTransparency = 1
			TextBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
			TextBox_1.BorderSizePixel = 0
			TextBox_1.CursorPosition = -1
			TextBox_1.Size = UDim2.new(1, -25,1, 0)
			TextBox_1.Font = Enum.Font.GothamMedium
			TextBox_1.PlaceholderColor3 = Color3.fromRGB(100,100,100)
			TextBox_1.PlaceholderText = PlaceHolder
			TextBox_1.Text = tostring(Value)
			TextBox_1.TextColor3 = Color3.fromRGB(145,145,145)
			TextBox_1.TextSize = 12
			TextBox_1.TextXAlignment = Enum.TextXAlignment.Left
			TextBox_1.TextTruncate = Enum.TextTruncate.AtEnd

			TextBox_1.Focused:Connect(function()
				Template.Text.Visible = false

				Liquid:Tween({
					v = Textbox,
					t = 0.5,
					s = "Exponential",
					d = "Out",
					g = {
						Size = UDim2.new(1, -15, 0, 25)
					}
				}):Play()

				UIStroke_1.Color = Highlight
			end)

			TextBox_1.FocusLost:Connect(function()
				Value = tostring(TextBox_1.Text)

				Callback(Setting, Value)

				Template.Text.Visible = true
				UIStroke_1.Color = Color3.fromRGB(75,75,75)

				Liquid:Tween({
					v = Textbox,
					t = 0.5,
					s = "Exponential",
					d = "Out",
					g = {
						Size = UDim2.new(0, 85, 0, 25)
					}
				}):Play()
			end)

			function Setting:SetValue(value)
				TextBox_1.Text = tostring(value)
				Value = tostring(TextBox_1.Text)
			end

			return Setting
		end

		function __index:Slider(configs)
			local Icon = configs.Icon or nil
			local Min = configs.Min or 1
			local Max = configs.Max or 10
			local Value = configs.Value or Min
			local Rounding = configs.Rounding or 0
			local Callback = configs.Callback or (function( ... )
				return ...
			end)

			local Template = Instance.new("Frame")
			local UIStroke_1 = Instance.new("UIStroke")
			local UICorner_1 = Instance.new("UICorner")
			local Slider_1 = Instance.new("Frame")
			local UIListLayout_1 = Instance.new("UIListLayout")
			local Icon_1 = Instance.new("ImageLabel")
			local UIPadding_1 = Instance.new("UIPadding")
			local DarkBar_1 = Instance.new("Frame")
			local UICorner_2 = Instance.new("UICorner")
			local ActiveBar_1 = Instance.new("Frame")
			local UICorner_3 = Instance.new("UICorner")
			local Circle_1 = Instance.new("Frame")
			local UICorner_4 = Instance.new("UICorner")
			local Slide_1 = Instance.new("Frame")
			local Scaler_1 = Instance.new("Frame")
			local UIPadding_2 = Instance.new("UIPadding")
			local Textbox_1 = Instance.new("Frame")
			local UICorner_5 = Instance.new("UICorner")
			local UIStroke_2 = Instance.new("UIStroke")
			local UIPadding_3 = Instance.new("UIPadding")
			local Icon_2 = Instance.new("ImageLabel")
			local UIListLayout_2 = Instance.new("UIListLayout")
			local Value_1 = Instance.new("TextBox")
			local UIListLayout_3 = Instance.new("UIListLayout")

			local Button = Liquid:Button(Slide_1)

			Template.Name = "Template"
			Template.Parent = PageScrolling_1
			Template.BackgroundColor3 = Color3.fromRGB(70,70,70)
			Template.BackgroundTransparency = 0.8199999928474426
			Template.BorderColor3 = Color3.fromRGB(0,0,0)
			Template.BorderSizePixel = 0
			Template.Size = UDim2.new(1, 0,0, 50)

			UIStroke_1.Parent = Template
			UIStroke_1.Color = Color3.fromRGB(25,25,25)
			UIStroke_1.Thickness = 1
			UIStroke_1.Transparency = 0.15

			UICorner_1.Parent = Template
			UICorner_1.CornerRadius = UDim.new(0,4)

			Slider_1.Name = "Slider"
			Slider_1.Parent = Template
			Slider_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Slider_1.BackgroundTransparency = 1
			Slider_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Slider_1.BorderSizePixel = 0
			Slider_1.Size = UDim2.new(1, 0,1, 0)

			UIListLayout_1.Parent = Slider_1
			UIListLayout_1.Padding = UDim.new(0,20)
			UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

			Icon_1.Name = "Icon"
			Icon_1.Parent = Slider_1
			Icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
			Icon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Icon_1.BackgroundTransparency = 1
			Icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Icon_1.BorderSizePixel = 0
			Icon_1.LayoutOrder = -5
			Icon_1.Position = UDim2.new(0.5, 0,0.5, 0)
			Icon_1.Size = UDim2.new(0, 20,0, 20)
			Icon_1.Image = Liquid:Asset(Icon)
			Icon_1.ImageTransparency = 0.30000001192092896

			UIPadding_1.Parent = Slider_1
			UIPadding_1.PaddingLeft = UDim.new(0,15)

			DarkBar_1.Name = "DarkBar"
			DarkBar_1.Parent = Slider_1
			DarkBar_1.BackgroundColor3 = Color3.fromRGB(0,0,0)
			DarkBar_1.BackgroundTransparency = 0.75
			DarkBar_1.BorderColor3 = Color3.fromRGB(0,0,0)
			DarkBar_1.BorderSizePixel = 0
			DarkBar_1.Size = UDim2.new(1, -125,0, 5)

			UICorner_2.Parent = DarkBar_1

			ActiveBar_1.Name = "ActiveBar"
			ActiveBar_1.Parent = DarkBar_1
			ActiveBar_1.BackgroundColor3 = Highlight
			ActiveBar_1.BorderColor3 = Color3.fromRGB(0,0,0)
			ActiveBar_1.BorderSizePixel = 0
			ActiveBar_1.Size = UDim2.new(0.5, 0,1, 0)

			UICorner_3.Parent = ActiveBar_1

			Circle_1.Name = "Circle"
			Circle_1.Parent = ActiveBar_1
			Circle_1.AnchorPoint = Vector2.new(1, 0.5)
			Circle_1.BackgroundColor3 = Highlight
			Circle_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Circle_1.BorderSizePixel = 0
			Circle_1.Position = UDim2.new(1, 0,0.5, 0)
			Circle_1.Size = UDim2.new(0, 15,0, 15)

			UICorner_4.Parent = Circle_1
			UICorner_4.CornerRadius = UDim.new(1,0)

			Slide_1.Name = "Slide"
			Slide_1.Parent = DarkBar_1
			Slide_1.AnchorPoint = Vector2.new(0.5, 0.5)
			Slide_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Slide_1.BackgroundTransparency = 1
			Slide_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Slide_1.BorderSizePixel = 0
			Slide_1.Position = UDim2.new(0.5, 0,0.5, 0)
			Slide_1.Size = UDim2.new(1, 10,1, 20)

			Scaler_1.Name = "Scaler"
			Scaler_1.Parent = Template
			Scaler_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Scaler_1.BackgroundTransparency = 1
			Scaler_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Scaler_1.BorderSizePixel = 0
			Scaler_1.Size = UDim2.new(1, 0,1, 0)

			UIPadding_2.Parent = Scaler_1
			UIPadding_2.PaddingRight = UDim.new(0,15)

			Textbox_1.Name = "Textbox"
			Textbox_1.Parent = Scaler_1
			Textbox_1.BackgroundColor3 = Color3.fromRGB(0,0,0)
			Textbox_1.BackgroundTransparency = 0.8999999761581421
			Textbox_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Textbox_1.BorderSizePixel = 0
			Textbox_1.Position = UDim2.new(0.850467265, 0,0.301587313, 0)
			Textbox_1.Size = UDim2.new(0, 60,0, 25)

			UICorner_5.Parent = Textbox_1
			UICorner_5.CornerRadius = UDim.new(0,5)

			UIStroke_2.Parent = Textbox_1
			UIStroke_2.Color = Color3.fromRGB(75,75,75)
			UIStroke_2.Thickness = 1

			UIPadding_3.Parent = Textbox_1
			UIPadding_3.PaddingRight = UDim.new(0,5)

			Icon_2.Name = "Icon"
			Icon_2.Parent = Textbox_1
			Icon_2.AnchorPoint = Vector2.new(0.5, 0.5)
			Icon_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Icon_2.BackgroundTransparency = 1
			Icon_2.BorderColor3 = Color3.fromRGB(0,0,0)
			Icon_2.BorderSizePixel = 0
			Icon_2.Position = UDim2.new(0.5, 0,0.5, 0)
			Icon_2.Size = UDim2.new(0, 15,0, 15)
			Icon_2.Image = "rbxassetid://123909267283672"
			Icon_2.ImageTransparency = 0.10000000149011612

			UIListLayout_2.Parent = Textbox_1
			UIListLayout_2.Padding = UDim.new(0,5)
			UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Right
			UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

			Value_1.Name = "Value"
			Value_1.Parent = Textbox_1
			Value_1.Active = true
			Value_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Value_1.BackgroundTransparency = 1
			Value_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Value_1.BorderSizePixel = 0
			Value_1.Size = UDim2.new(1, -25,1, 0)
			Value_1.Font = Enum.Font.GothamMedium
			Value_1.PlaceholderColor3 = Color3.fromRGB(100,100,100)
			Value_1.PlaceholderText = tostring(Value)
			Value_1.Text = "N/A"
			Value_1.TextColor3 = Color3.fromRGB(145,145,145)
			Value_1.TextSize = 12
			Value_1.TextXAlignment = Enum.TextXAlignment.Left

			UIListLayout_3.Parent = Scaler_1
			UIListLayout_3.HorizontalAlignment = Enum.HorizontalAlignment.Right
			UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_3.VerticalAlignment = Enum.VerticalAlignment.Center

			local function roundToDecimal(value, decimals)
				local factor = 10 ^ decimals
				return math.floor(value * factor + 0.5) / factor
			end

			local function updateSlider(value)
				value = math.clamp(value, Min, Max)
				value = roundToDecimal(value, Rounding)
				Liquid:Tween({
					v = ActiveBar_1,
					t = 0.5,
					s = "Exponential",
					d = "Out",
					g = {Size = UDim2.new((value - Min) / (Max - Min), 0, 1, 0)}
				}):Play()

				local startValue = tonumber(Value_1.Text) or 0
				local targetValue = value

				local steps = 5
				local currentValue = startValue

				for i = 1, steps do
					task.wait(0.01 / steps)
					currentValue = currentValue + (targetValue - startValue) / steps
					Value_1.Text = tostring(roundToDecimal(currentValue, Rounding))
				end

				Value_1.Text = tostring(roundToDecimal(targetValue, Rounding))

				Callback(value)
			end

			updateSlider(Value or 0)

			local function move(input)
				local sliderBar = DarkBar_1
				local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
				local value = relativeX * (Max - Min) + Min
				updateSlider(value)
			end

			Value_1.Focused:Connect(function()
				Slider_1.Visible = false

				Liquid:Tween({
					v = Textbox_1,
					t = 0.5,
					s = "Exponential",
					d = "Out",
					g = {
						Size = UDim2.new(1, -15, 0, 25)
					}
				}):Play()

				UIStroke_2.Color = Highlight
			end)

			Value_1.FocusLost:Connect(function()
				Liquid:Tween({
					v = Textbox_1,
					t = 0.5,
					s = "Exponential",
					d = "Out",
					g = {
						Size = UDim2.new(0, 60, 0, 25)
					}
				}):Play()

				delay(0.1, function()
					Slider_1.Visible = true
					UIStroke_2.Color = Color3.fromRGB(75,75,75)

					local value = tonumber(Value_1.Text) or Min
					updateSlider(value)
				end)
			end)

			local dragging = false

			Button.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					for _, v in pairs(Page_1:GetChildren()) do
						if v.Name == "Dropdown" and v.Visible then
							return
						end
					end

					dragging = true
					move(input)
				end
			end)

			Button.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then

					dragging = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					for _, v in pairs(Page_1:GetChildren()) do
						if v.Name == "Dropdown" and v.Visible then
							return
						end
					end

					move(input)
				end
			end)

			local Setting = {}

			function Setting:SetValue(val)
				updateSlider(val)
			end

			return Setting
		end

		function __index:Input(options)
			local Title = options.Title or "Title"
			local Desc = options.Desc or nil
			local Key = options.Key or Enum.KeyCode.RightControl
			local Value = options.Value or false
			local Callback = options.Callback or (function( ... )
				return ...
			end)

			local Template = Liquid:Template(PageScrolling_1, Title, Desc, 125)

			local Setting = {}

			function Setting:SetTitle(Text)
				Template.Text.Title.Text = Text
			end

			function Setting:SetDesc(Text)
				Template.Text.Desc.Text = Text
			end

			function Setting:SetAll(texts)
				Template.Text.Title.Text = texts[1]
				Template.Text.Desc.Text = texts[2]
			end

			function Setting:Visible(value)
				Template.Visible = value
			end

			function Setting:GetFrame()
				return Template
			end

			local Bind = Instance.new("Frame")
			local UICorner_1 = Instance.new("UICorner")
			local UIStroke_1 = Instance.new("UIStroke")
			local UIPadding_1 = Instance.new("UIPadding")
			local Icon_1 = Instance.new("ImageLabel")
			local UIListLayout_1 = Instance.new("UIListLayout")
			local TextBox_1 = Instance.new("TextLabel")

			local Button1 = Liquid:Button(Icon_1)
			local Button2 = Liquid:Button(TextBox_1)

			Bind.Name = "Bind"
			Bind.Parent = Template.Scaler
			Bind.BackgroundColor3 = Color3.fromRGB(0,0,0)
			Bind.BackgroundTransparency = 0.8999999761581421
			Bind.BorderColor3 = Color3.fromRGB(0,0,0)
			Bind.BorderSizePixel = 0
			Bind.Position = UDim2.new(0.850467265, 0,0.301587313, 0)
			Bind.Size = UDim2.new(0, 85,0, 25)

			UICorner_1.Parent = Bind
			UICorner_1.CornerRadius = UDim.new(0,5)

			UIStroke_1.Parent = Bind
			UIStroke_1.Color = Color3.fromRGB(75,75,75)
			UIStroke_1.Thickness = 1

			UIPadding_1.Parent = Bind
			UIPadding_1.PaddingRight = UDim.new(0,5)

			Icon_1.Name = "Icon"
			Icon_1.Parent = Bind
			Icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
			Icon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Icon_1.BackgroundTransparency = 1
			Icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Icon_1.BorderSizePixel = 0
			Icon_1.Position = UDim2.new(0.5, 0,0.5, 0)
			Icon_1.Size = UDim2.new(0, 15,0, 15)
			Icon_1.Image = "rbxassetid://91697619966971"
			Icon_1.ImageTransparency = 0.10000000149011612

			UIListLayout_1.Parent = Bind
			UIListLayout_1.Padding = UDim.new(0,5)
			UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Right
			UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

			TextBox_1.Parent = Bind
			TextBox_1.Active = true
			TextBox_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			TextBox_1.BackgroundTransparency = 1
			TextBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
			TextBox_1.BorderSizePixel = 0
			TextBox_1.Size = UDim2.new(1, -25,1, 0)
			TextBox_1.Font = Enum.Font.GothamMedium
			TextBox_1.Text = tostring(Key):gsub("Enum.KeyCode.", "")
			TextBox_1.TextColor3 = Color3.fromRGB(145,145,145)
			TextBox_1.TextSize = 12
			TextBox_1.TextTruncate = Enum.TextTruncate.AtEnd
			TextBox_1.TextXAlignment = Enum.TextXAlignment.Left

			local function changeKey()
				for _, v in pairs(Page_1:GetChildren()) do
					if v.Name == "Dropdown" and v.Visible then
						return
					end
				end

				TextBox_1.Text = " ...... "
				Template.Text.Visible = false

				Liquid:Tween({
					v = Bind,
					t = 0.5,
					s = "Exponential",
					d = "Out",
					g = {
						Size = UDim2.new(1, -15, 0, 25)
					}
				}):Play()

				UIStroke_1.Color = Highlight

				local connection

				connection = UserInputService.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Keyboard then
						Key = input.KeyCode

						TextBox_1.Text = tostring(Key):gsub("Enum.KeyCode.", "")

						connection:Disconnect()
						Callback(Setting, Key, Value)

						Template.Text.Visible = true
						UIStroke_1.Color = Color3.fromRGB(75,75,75)

						local targetWidth = TextBox_1.TextBounds.X + 30
						local clampedWidth = math.clamp(targetWidth, 40, 85)

						Liquid:Tween({
							v = Bind,
							t = 0.5,
							s = "Exponential",
							d = "Out",
							g = {
								Size = UDim2.new(0, clampedWidth, 0, 25)
							}
						}):Play()
					end
				end)
			end

			UserInputService.InputEnded:Connect(function(input)
				if input.KeyCode == Key then
					Value = not Value
					Callback(Setting, Key, Value)
				end
			end)

			task.defer(Callback, Key, Value)

			Button1.MouseButton1Click:Connect(changeKey)
			Button2.MouseButton1Click:Connect(changeKey)

			function Setting:SetValue(value)
				Value = value
			end

			function Setting:SetBind(key)
				Key = key
			end

			return Setting
		end

		function __index:Dropdown(configs)
			local Title = configs.Title or "Title"
			local List = configs.List or {}
			local Value = configs.Value or List[1] or "N/A"
			local Multi = configs.Multi or false
			local Callback = configs.Callback or (function( ... )
				return ...
			end)

			local Template = Liquid:Template(PageScrolling_1, Title, "N/A", 65)
			local Button = Liquid:Button(Template)

			local Arrow = Instance.new("ImageLabel")
			Arrow.Parent = Template.Scaler
			Arrow.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Arrow.BackgroundTransparency = 1
			Arrow.BorderColor3 = Color3.fromRGB(0,0,0)
			Arrow.BorderSizePixel = 0
			Arrow.Size = UDim2.new(0, 16,0, 16)
			Arrow.Image = "rbxassetid://132291592681506"
			Arrow.ImageTransparency = 0.35

			local StartXY = 175

			local Setting = {}

			function Setting:SetTitle(Text)
				Template.Text.Title.Text = Text
			end

			local function SetDesc(Text)
				Template.Text.Desc.Text = Text
			end

			function Setting:Visible(value)
				Template.Visible = value
			end

			function Setting:GetFrame()
				return Template
			end

			local function Settext()
				if typeof(Value) == 'table' then
					SetDesc(table.concat(Value, ", "))
				else
					SetDesc(tostring(Value))
				end
			end

			Settext()

			local Dropdown = Instance.new("Frame")
			local UICorner_1 = Instance.new("UICorner")
			local UIStroke_1 = Instance.new("UIStroke")
			local Scaler_1 = Instance.new("Frame")
			local Search_1 = Instance.new("Frame")
			local UICorner_2 = Instance.new("UICorner")
			local UIListLayout_1 = Instance.new("UIListLayout")
			local Icon_1 = Instance.new("ImageLabel")
			local UIPadding_1 = Instance.new("UIPadding")
			local TextBox_1 = Instance.new("TextBox")
			local UIListLayout_2 = Instance.new("UIListLayout")
			local UIPadding_2 = Instance.new("UIPadding")
			local LineUpper_1 = Instance.new("Frame")
			local ListScrolling_1 = Instance.new("ScrollingFrame")
			local UIListLayout_3 = Instance.new("UIListLayout")
			local Shadow_1 = Instance.new("ImageLabel")

			local YPS = 55

			Dropdown.Name = "Dropdown"
			Dropdown.Parent = Page_1
			Dropdown.AnchorPoint = Vector2.new(1, 0)
			Dropdown.BackgroundColor3 = Color3.fromRGB(30,30,30)
			Dropdown.BackgroundTransparency = 0.075
			Dropdown.BorderColor3 = Color3.fromRGB(0,0,0)
			Dropdown.BorderSizePixel = 0
			Dropdown.Position = UDim2.new(1, -20,0, 10)
			Dropdown.Size = UDim2.new(0, StartXY,0, YPS)
			Dropdown.Visible = false

			local NORE = Instance.new("Frame")
			local UICorner_1s = Instance.new("UICorner")
			local Title_1 = Instance.new("TextLabel")

			NORE.Name = "NORE"
			NORE.Parent = ListScrolling_1
			NORE.AnchorPoint = Vector2.new(0.5, 0.5)
			NORE.BackgroundColor3 = Color3.fromRGB(255,255,255)
			NORE.BackgroundTransparency = 0.95
			NORE.BorderColor3 = Color3.fromRGB(0,0,0)
			NORE.BorderSizePixel = 0
			NORE.Size = UDim2.new(1, -10,0, 30)
			NORE.Visible = false

			UICorner_1s.Parent = NORE
			UICorner_1s.CornerRadius = UDim.new(0,10)

			Title_1.Name = "Title"
			Title_1.Parent = NORE
			Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Title_1.BackgroundTransparency = 1
			Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Title_1.BorderSizePixel = 0
			Title_1.Size = UDim2.new(1, 0,1, 0)
			Title_1.Font = Enum.Font.GothamMedium
			Title_1.Text = "No results found."
			Title_1.TextColor3 = Color3.fromRGB(255,255,255)
			Title_1.TextSize = 12
			Title_1.TextTransparency = 0.5
			Title_1.TextTruncate = Enum.TextTruncate.AtEnd

			UICorner_1.Parent = Dropdown
			UICorner_1.CornerRadius = UDim.new(0,10)

			UIStroke_1.Parent = Dropdown
			UIStroke_1.Color = Color3.fromRGB(65,65,65)
			UIStroke_1.Thickness = 0.5

			Scaler_1.Name = "Scaler"
			Scaler_1.Parent = Dropdown
			Scaler_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Scaler_1.BackgroundTransparency = 1
			Scaler_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Scaler_1.BorderSizePixel = 0
			Scaler_1.Size = UDim2.new(1, 0,1, 0)

			Search_1.Name = "Search"
			Search_1.Parent = Scaler_1
			Search_1.AnchorPoint = Vector2.new(0.5, 0.5)
			Search_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Search_1.BackgroundTransparency = 0.949999988079071
			Search_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Search_1.BorderSizePixel = 0
			Search_1.Size = UDim2.new(1, -10,0, 30)

			UICorner_2.Parent = Search_1
			UICorner_2.CornerRadius = UDim.new(0,10)

			UIListLayout_1.Parent = Search_1
			UIListLayout_1.Padding = UDim.new(0,7)
			UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

			Icon_1.Name = "Icon"
			Icon_1.Parent = Search_1
			Icon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Icon_1.BackgroundTransparency = 1
			Icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Icon_1.BorderSizePixel = 0
			Icon_1.Size = UDim2.new(0, 15,0, 15)
			Icon_1.Image = "rbxassetid://125928820284709"
			Icon_1.ImageTransparency = 0.5

			UIPadding_1.Parent = Search_1
			UIPadding_1.PaddingLeft = UDim.new(0,7)

			TextBox_1.Parent = Search_1
			TextBox_1.Active = true
			TextBox_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			TextBox_1.BackgroundTransparency = 1
			TextBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
			TextBox_1.BorderSizePixel = 0
			TextBox_1.Size = UDim2.new(1, -35,1, 0)
			TextBox_1.Font = Enum.Font.GothamMedium
			TextBox_1.PlaceholderColor3 = Color3.fromRGB(178,178,178)
			TextBox_1.PlaceholderText = "Search"
			TextBox_1.Text = ""
			TextBox_1.TextColor3 = Color3.fromRGB(255,255,255)
			TextBox_1.TextSize = 12
			TextBox_1.TextTransparency = 0.5
			TextBox_1.TextXAlignment = Enum.TextXAlignment.Left
			TextBox_1.ZIndex = Button.ZIndex + 1
			TextBox_1.TextTruncate = Enum.TextTruncate.AtEnd

			TextBox_1.Focused:Connect(function()
				Liquid:Tween({
					v = TextBox_1,
					t = 0.5,
					s = "Exponential",
					d = "Out",
					g = {
						TextTransparency = 0.1
					}
				}):Play()

				Liquid:Tween({
					v = Icon_1,
					t = 0.5,
					s = "Exponential",
					d = "Out",
					g = {
						ImageTransparency = 0.35
					}
				}):Play()
			end)

			TextBox_1.Changed:Connect(function()
				local targetX = StartXY + TextBox_1.TextBounds.X
				local maxX = Page_1.AbsoluteSize.Y - 25

				local finalX = math.min(targetX, maxX)

				Dropdown.Size = UDim2.new(0, finalX, 0, Dropdown.Size.Y.Offset)
			end)

			UIListLayout_2.Parent = Scaler_1
			UIListLayout_2.Padding = UDim.new(0,5)
			UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder

			UIPadding_2.Parent = Scaler_1
			UIPadding_2.PaddingBottom = UDim.new(0,5)
			UIPadding_2.PaddingTop = UDim.new(0,5)

			LineUpper_1.Name = "LineUpper"
			LineUpper_1.Parent = Scaler_1
			LineUpper_1.BackgroundColor3 = Color3.fromRGB(65,65,65)
			LineUpper_1.BackgroundTransparency = 0.5
			LineUpper_1.BorderColor3 = Color3.fromRGB(0,0,0)
			LineUpper_1.BorderSizePixel = 0
			LineUpper_1.Size = UDim2.new(1, 0,0, 1)

			ListScrolling_1.Name = "ListScrolling"
			ListScrolling_1.Parent = Scaler_1
			ListScrolling_1.Active = true
			ListScrolling_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			ListScrolling_1.BackgroundTransparency = 1
			ListScrolling_1.BorderColor3 = Color3.fromRGB(0,0,0)
			ListScrolling_1.BorderSizePixel = 0
			ListScrolling_1.Size = UDim2.new(1, 0,1, -40)
			ListScrolling_1.ClipsDescendants = true
			ListScrolling_1.AutomaticCanvasSize = Enum.AutomaticSize.None
			ListScrolling_1.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
			ListScrolling_1.CanvasPosition = Vector2.new(0, 0)
			ListScrolling_1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
			ListScrolling_1.HorizontalScrollBarInset = Enum.ScrollBarInset.None
			ListScrolling_1.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
			ListScrolling_1.ScrollBarImageColor3 = Color3.fromRGB(0,0,0)
			ListScrolling_1.ScrollBarImageTransparency = 1
			ListScrolling_1.ScrollBarThickness = 0
			ListScrolling_1.ScrollingDirection = Enum.ScrollingDirection.XY
			ListScrolling_1.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
			ListScrolling_1.VerticalScrollBarInset = Enum.ScrollBarInset.None
			ListScrolling_1.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

			UIListLayout_3.Parent = ListScrolling_1
			UIListLayout_3.Padding = UDim.new(0,5)
			UIListLayout_3.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder

			UIListLayout_3:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				ListScrolling_1.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_3.AbsoluteContentSize.Y + 15)
			end)

			Shadow_1.Name = "Shadow"
			Shadow_1.Parent = Dropdown
			Shadow_1.AnchorPoint = Vector2.new(0.5, 0.5)
			Shadow_1.BackgroundColor3 = Color3.fromRGB(0,0,0)
			Shadow_1.BackgroundTransparency = 1
			Shadow_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Shadow_1.BorderSizePixel = 0
			Shadow_1.Position = UDim2.new(0.5, 0,0.5, 0)
			Shadow_1.Size = UDim2.new(1, 120,1, 120)
			Shadow_1.ZIndex = 0
			Shadow_1.Image = "rbxassetid://8992230677"
			Shadow_1.ImageColor3 = Color3.fromRGB(0,0,0)
			Shadow_1.ImageTransparency = 0.5
			Shadow_1.ScaleType = Enum.ScaleType.Slice
			Shadow_1.SliceCenter = Rect.new(99, 99, 99, 99)

			local function GetMaxY()
				local targetHeight = UIListLayout_3.AbsoluteContentSize.Y + 55
				local maxHeight = Page_1.AbsoluteSize.Y - 20
				local finalHeight = math.min(targetHeight, maxHeight)

				return finalHeight
			end

			local isOpen = false

			UserInputService.InputBegan:Connect(function(A)
				local mouse = LocalPlayer:GetMouse()
				local mx, my = mouse.X, mouse.Y
				local DBP, DBS = Dropdown.AbsolutePosition, Dropdown.AbsoluteSize

				local function inside(pos, size)
					return mx >= pos.X and mx <= pos.X + size.X and my >= pos.Y and my <= pos.Y + size.Y
				end

				if A.UserInputType == Enum.UserInputType.MouseButton1 or A.UserInputType == Enum.UserInputType.Touch then
					if not inside(DBP, DBS) then
						isOpen = false
						Dropdown.Visible = false
						Dropdown.Position = UDim2.new(1, 0,0, 10)
						Dropdown.Size = UDim2.new(0, StartXY,0,YPS)
					end
				end
			end)

			local function OnDropdownOpen()
				for _, v in pairs(Page_1:GetChildren()) do
					if v.Name == "Dropdown" and v.Visible then
						return
					end
				end

				isOpen = not isOpen

				Liquid:Effect(Button, Template)

				if isOpen then
					Dropdown.Visible = true

					local One = Liquid:Tween({
						v = Dropdown,
						t = 0.3,
						s = "Back",
						d = "Out",
						g = {Position = UDim2.new(1, -10,0, 10)}
					})
					One:Play()


					One.Completed:Connect(function()
						Liquid:Tween({
							v = Dropdown,
							t = 0.75,
							s = "Exponential",
							d = "Out",
							g = {
								Size = UDim2.new(0, StartXY, 0, GetMaxY())
							}
						}):Play()
					end)
				else
					Dropdown.Visible = false
					Dropdown.Position = UDim2.new(1, 0,0, 10)
					Dropdown.Size = UDim2.new(0, StartXY,0, YPS)
				end
			end

			TextBox_1.FocusLost:Connect(function()
				Liquid:Tween({
					v = TextBox_1,
					t = 0.5,
					s = "Exponential",
					d = "Out",
					g = {
						TextTransparency = 0.5
					}
				}):Play()

				Liquid:Tween({
					v = Icon_1,
					t = 0.5,
					s = "Exponential",
					d = "Out",
					g = {
						ImageTransparency = 0.5
					}
				}):Play()

				local SearchT = string.lower(TextBox_1.Text)
				local found = false

				for i, v in pairs(ListScrolling_1:GetChildren()) do
					if v:IsA("Frame") and v.Name == 'AddList' then
						local labelText = string.lower(v.Scaler.Title.Text)

						if string.find(labelText, SearchT, 1, true) then
							v.Visible = true
							found = true
						else
							v.Visible = false
						end
					end
				end

				NORE.Visible = not found

				Liquid:Tween({
					v = Dropdown,
					t = 0.75,
					s = "Exponential",
					d = "Out",
					g = {
						Size = UDim2.new(0, StartXY, 0, GetMaxY())
					}
				}):Play()
			end)

			local Counter = 0
			local selectedItem

			function Setting:Clear(a)
				local function shouldClear(v)
					if a == nil then
						return true
					elseif type(a) == "string" then
						return v.Scaler.Title.Text == a
					elseif type(a) == "table" then
						for _, name in ipairs(a) do
							if v.Scaler.Title.Text == name then
								return true
							end
						end
					end

					return false
				end

				for _, v in ipairs(ListScrolling_1:GetChildren()) do
					if v:IsA("Frame") and shouldClear(v) then
						if selectedItem and v.Scaler.Title.Text == selectedItem then
							selectedItem = nil
							SetDesc("N/A")
						end
						v:Destroy()
					end
				end

				if selectedItem == a or Template.Text.Desc.Text == a then
					selectedItem = nil
					SetDesc("N/A")
				end

				if a == nil then
					selectedItem = nil
					SetDesc("N/A")
				end
			end

			local selectedValues = {}

			local function isValueInTable(val, tbl)
				if type(tbl) ~= "table" then
					return false
				end

				for _, v in pairs(tbl) do
					if v == val then
						return true
					end
				end

				return false
			end

			function Setting:AddList(options)
				Counter += 1

				local Name = options.Name or "UNKNOW" .. Counter
				local Icon = options.Icon or nil

				local AddList = Instance.new("Frame")
				local Scaler_1 = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local UIPadding_1 = Instance.new("UIPadding")
				local Icon_1 = Instance.new("ImageLabel")
				local Title_1 = Instance.new("TextLabel")

				local SelectLine = Instance.new("Frame")
				local UICorner_1s = Instance.new("UICorner")

				local Click = Liquid:Button(AddList)

				SelectLine.Name = "SelectLine"
				SelectLine.Parent = Scaler_1
				SelectLine.AnchorPoint = Vector2.new(0.5, 0.5)
				SelectLine.BackgroundColor3 = Highlight
				SelectLine.BorderColor3 = Color3.fromRGB(0,0,0)
				SelectLine.BorderSizePixel = 0
				SelectLine.LayoutOrder = -5
				SelectLine.BackgroundTransparency = 1
				SelectLine.Position = UDim2.new(0, 0,0.5, 0)
				SelectLine.Size = UDim2.new(0, 4,0, 16)
				SelectLine.Visible = false

				UICorner_1s.Parent = SelectLine
				UICorner_1s.CornerRadius = UDim.new(1,0)

				AddList.Name = "AddList"
				AddList.Parent = ListScrolling_1
				AddList.AnchorPoint = Vector2.new(0.5, 0.5)
				AddList.BackgroundColor3 = Color3.fromRGB(255,255,255)
				AddList.BackgroundTransparency = 1
				AddList.BorderColor3 = Color3.fromRGB(0,0,0)
				AddList.BorderSizePixel = 0
				AddList.Size = UDim2.new(1, -10,0, 30)

				Scaler_1.Name = "Scaler"
				Scaler_1.Parent = AddList
				Scaler_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Scaler_1.BackgroundTransparency = 1
				Scaler_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Scaler_1.BorderSizePixel = 0
				Scaler_1.Size = UDim2.new(1, 0,1, 0)

				UICorner_1.Parent = Scaler_1
				UICorner_1.CornerRadius = UDim.new(0,10)

				UIListLayout_1.Parent = Scaler_1
				UIListLayout_1.Padding = UDim.new(0,7)
				UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

				UIPadding_1.Parent = Scaler_1
				UIPadding_1.PaddingLeft = UDim.new(0,7)

				if Icon then
					Icon_1.Name = "Icon"
					Icon_1.Parent = Scaler_1
					Icon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					Icon_1.BackgroundTransparency = 1
					Icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
					Icon_1.BorderSizePixel = 0
					Icon_1.LayoutOrder = -4
					Icon_1.Size = UDim2.new(0, 15,0, 15)
					Icon_1.Image = Liquid:Asset(Icon)
					Icon_1.ImageTransparency = 0.5
				end

				Title_1.Name = "Title"
				Title_1.Parent = Scaler_1
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Size = UDim2.new(0, 100,1, 0)
				Title_1.Font = Enum.Font.GothamMedium
				Title_1.Text = Name
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 12
				Title_1.TextTransparency = 0.5
				Title_1.TextTruncate = Enum.TextTruncate.AtEnd
				Title_1.TextXAlignment = Enum.TextXAlignment.Left

				local function OnValue(value)
					if value then
						SelectLine.Visible = true

						Liquid:Tween({
							v = SelectLine,
							t = 0.2,
							s = "Exponential",
							d = "Out",
							g = { BackgroundTransparency = 0 }
						}):Play()

						SelectLine.Size = UDim2.new(0, 4,0, 0)

						Liquid:Tween({
							v = Title_1,
							t = 0.5,
							s = "Exponential",
							d = "Out",
							g = {TextTransparency = 0.1}
						}):Play()

						Liquid:Tween({
							v = Scaler_1,
							t = 0.5,
							s = "Exponential",
							d = "Out",
							g = {BackgroundTransparency = 0.95}
						}):Play()

						if Icon then
							Liquid:Tween({
								v = Icon_1,
								t = 0.5,
								s = "Exponential",
								d = "Out",
								g = {ImageTransparency = 0.3}
							}):Play()
						end

						task.delay(0.05, function()
							Liquid:Tween({
								v = SelectLine,
								t = 0.3,
								s = "Back",
								d = "Out",
								g = { Size = UDim2.new(0, 4,0, 16) }
							}):Play()
						end)
					else
						Liquid:Tween({
							v = SelectLine,
							t = 0.2,
							s = "Exponential",
							d = "Out",
							g = { BackgroundTransparency = 1 }
						}):Play()

						Liquid:Tween({
							v = SelectLine,
							t = 0.3,
							s = "Exponential",
							d = "In",
							g = { Size = UDim2.new(0, 4,0, 16) }
						}):Play()

						Liquid:Tween({
							v = Title_1,
							t = 0.5,
							s = "Exponential",
							d = "Out",
							g = {TextTransparency = 0.5}
						}):Play()

						Liquid:Tween({
							v = Scaler_1,
							t = 0.5,
							s = "Exponential",
							d = "Out",
							g = {BackgroundTransparency = 1}
						}):Play()

						if Icon then
							Liquid:Tween({
								v = Icon_1,
								t = 0.5,
								s = "Exponential",
								d = "Out",
								g = {ImageTransparency = 0.5}
							}):Play()
						end

						SelectLine.Visible = false
					end
				end

				local function OnSelected()
					if Multi then
						if selectedValues[Name] then
							selectedValues[Name] = nil
							OnValue(false)
						else
							selectedValues[Name] = true
							OnValue(true)
						end

						local selectedList = {}

						for i, v in pairs(selectedValues) do
							table.insert(selectedList, i)
						end

						if #selectedList > 0 then
							table.sort(selectedList)
							Value = selectedList
							Settext()
						else
							SetDesc("N/A")
						end

						pcall(Callback, selectedList)
					else
						for i,v in pairs(ListScrolling_1:GetChildren()) do
							if v:IsA("Frame") and v.Name == 'AddList' then
								Liquid:Tween({
									v = v.Scaler.SelectLine,
									t = 0.2,
									s = "Exponential",
									d = "Out",
									g = { BackgroundTransparency = 1 }
								}):Play()

								Liquid:Tween({
									v = v.Scaler.SelectLine,
									t = 0.3,
									s = "Exponential",
									d = "In",
									g = { Size = UDim2.new(0, 4,0, 16) }
								}):Play()

								Liquid:Tween({
									v = v.Scaler.Title,
									t = 0.5,
									s = "Exponential",
									d = "Out",
									g = {TextTransparency = 0.5}
								}):Play()

								Liquid:Tween({
									v = v.Scaler,
									t = 0.5,
									s = "Exponential",
									d = "Out",
									g = {BackgroundTransparency = 1}
								}):Play()

								if v.Scaler:FindFirstChild('Icon') then
									Liquid:Tween({
										v = v.Scaler.Icon,
										t = 0.5,
										s = "Exponential",
										d = "Out",
										g = {ImageTransparency = 0.5}
									}):Play()
								end

								v.Scaler.SelectLine.Visible = false
							end
						end

						OnValue(true)
						Value = Name
						Settext()
						pcall(Callback, Value)
					end
				end

				delay(0,function()
					if Multi then
						if isValueInTable(Name, Value) then
							selectedValues[Name] = true

							OnValue(true)

							local selectedList = {}

							for i, v in pairs(selectedValues) do
								table.insert(selectedList, i)
							end

							if #selectedList > 0 then
								Settext()
							else
								SetDesc("N/A")
							end

							pcall(Callback, selectedList)
						end
					else
						if Name == Value then
							Value = Name
							OnValue(true)
							Settext()
							pcall(Callback, Value)
						end
					end
				end)

				Click.MouseButton1Click:Connect(OnSelected)
			end

			for _, name in ipairs(List) do
				local Name = name.Title
				local Icon = name.Icon or nil

				Setting:AddList({
					Name = Name,
					Icon = Icon
				})
			end

			Settext()

			Button.MouseButton1Click:Connect(OnDropdownOpen)

			return Setting
		end

		function __index:CodeBlock(configs)
			local Header = configs.Header or 'packages.luau'
			local CodeInput = configs.Code or 'print("Liquid Components")'
			local Icon = configs.Icon or 120013312151116

			local Template = Instance.new("Frame")
			local UIStroke_1 = Instance.new("UIStroke")
			local UICorner_1 = Instance.new("UICorner")
			local Scaler_1 = Instance.new("Frame")
			local UIPadding_1 = Instance.new("UIPadding")
			local Header_1 = Instance.new("Frame")
			local UICorner_2 = Instance.new("UICorner")
			local UIStroke_2 = Instance.new("UIStroke")
			local UIPadding_2 = Instance.new("UIPadding")
			local Icon_1 = Instance.new("ImageLabel")
			local UIListLayout_1 = Instance.new("UIListLayout")
			local Text_1 = Instance.new("TextLabel")
			local LineTab_1 = Instance.new("Frame")
			local Copy_1 = Instance.new("ImageLabel")
			local UIListLayout_2 = Instance.new("UIListLayout")
			local Body_1 = Instance.new("Frame")
			local UICorner_3 = Instance.new("UICorner")
			local UIStroke_3 = Instance.new("UIStroke")
			local UIPadding_3 = Instance.new("UIPadding")
			local UIListLayout_3 = Instance.new("UIListLayout")
			local Code_1 = Instance.new("TextLabel")

			Template.Name = "Template"
			Template.Parent = PageScrolling_1
			Template.BackgroundColor3 = Color3.fromRGB(70,70,70)
			Template.BackgroundTransparency = 0.8199999928474426
			Template.BorderColor3 = Color3.fromRGB(0,0,0)
			Template.BorderSizePixel = 0
			Template.Size = UDim2.new(1, 0,0, 225)

			UIStroke_1.Parent = Template
			UIStroke_1.Color = Color3.fromRGB(25,25,25)
			UIStroke_1.Thickness = 1
			UIStroke_1.Transparency = 0.15

			UICorner_1.Parent = Template
			UICorner_1.CornerRadius = UDim.new(0,4)

			Scaler_1.Name = "Scaler"
			Scaler_1.Parent = Template
			Scaler_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Scaler_1.BackgroundTransparency = 1
			Scaler_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Scaler_1.BorderSizePixel = 0
			Scaler_1.Size = UDim2.new(1, 0,1, 0)

			UIPadding_1.Parent = Scaler_1
			UIPadding_1.PaddingBottom = UDim.new(0,15)
			UIPadding_1.PaddingLeft = UDim.new(0,15)
			UIPadding_1.PaddingRight = UDim.new(0,15)
			UIPadding_1.PaddingTop = UDim.new(0,15)

			Header_1.Name = "Header"
			Header_1.Parent = Scaler_1
			Header_1.BackgroundColor3 = Color3.fromRGB(0,0,0)
			Header_1.BackgroundTransparency = 0.8999999761581421
			Header_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Header_1.BorderSizePixel = 0
			Header_1.LayoutOrder = 999
			Header_1.Position = UDim2.new(0.850467265, 0,0.301587313, 0)
			Header_1.Size = UDim2.new(1, 0,0, 30)

			UICorner_2.Parent = Header_1
			UICorner_2.CornerRadius = UDim.new(0,5)

			UIStroke_2.Parent = Header_1
			UIStroke_2.Color = Color3.fromRGB(75,75,75)
			UIStroke_2.Thickness = 1

			UIPadding_2.Parent = Header_1
			UIPadding_2.PaddingLeft = UDim.new(0,10)
			UIPadding_2.PaddingRight = UDim.new(0,10)

			Icon_1.Name = "Icon"
			Icon_1.Parent = Header_1
			Icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
			Icon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Icon_1.BackgroundTransparency = 1
			Icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Icon_1.BorderSizePixel = 0
			Icon_1.LayoutOrder = -5
			Icon_1.Position = UDim2.new(0.5, 0,0.5, 0)
			Icon_1.Size = UDim2.new(0, 15,0, 15)
			Icon_1.Image = Liquid:Asset(Icon)
			Icon_1.ImageTransparency = 0.10000000149011612

			UIListLayout_1.Parent = Header_1
			UIListLayout_1.Padding = UDim.new(0,10)
			UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

			Text_1.Name = "Text"
			Text_1.Parent = Header_1
			Text_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Text_1.BackgroundTransparency = 1
			Text_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Text_1.BorderSizePixel = 0
			Text_1.Size = UDim2.new(1, -60,1, 0)
			Text_1.Font = Enum.Font.GothamMedium
			Text_1.RichText = true
			Text_1.Text = Header
			Text_1.TextColor3 = Color3.fromRGB(204,204,204)
			Text_1.TextSize = 13
			Text_1.TextXAlignment = Enum.TextXAlignment.Left
			Text_1.TextTruncate = Enum.TextTruncate.AtEnd

			LineTab_1.Name = "LineTab"
			LineTab_1.Parent = Header_1
			LineTab_1.BackgroundColor3 = Color3.fromRGB(65,65,65)
			LineTab_1.BackgroundTransparency = 0.5
			LineTab_1.BorderColor3 = Color3.fromRGB(0,0,0)
			LineTab_1.BorderSizePixel = 0
			LineTab_1.LayoutOrder = -4
			LineTab_1.Position = UDim2.new(1, 0,0, 0)
			LineTab_1.Size = UDim2.new(0, 1,1, 0)

			Copy_1.Name = "Copy"
			Copy_1.Parent = Header_1
			Copy_1.AnchorPoint = Vector2.new(0.5, 0.5)
			Copy_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Copy_1.BackgroundTransparency = 1
			Copy_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Copy_1.BorderSizePixel = 0
			Copy_1.LayoutOrder = 5555
			Copy_1.Position = UDim2.new(0.5, 0,0.5, 0)
			Copy_1.Size = UDim2.new(0, 15,0, 15)
			Copy_1.Image = "rbxassetid://78020815235467"
			Copy_1.ImageTransparency = 0.10000000149011612

			UIListLayout_2.Parent = Scaler_1
			UIListLayout_2.Padding = UDim.new(0,7)
			UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder

			Body_1.Name = "Body"
			Body_1.Parent = Scaler_1
			Body_1.BackgroundColor3 = Color3.fromRGB(0,0,0)
			Body_1.BackgroundTransparency = 0.75
			Body_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Body_1.BorderSizePixel = 0
			Body_1.LayoutOrder = 999
			Body_1.Position = UDim2.new(0.850467265, 0,0.301587313, 0)
			Body_1.Size = UDim2.new(1, 0,0, 160)
			Body_1.ClipsDescendants = true

			UICorner_3.Parent = Body_1
			UICorner_3.CornerRadius = UDim.new(0,5)

			UIStroke_3.Parent = Body_1
			UIStroke_3.Color = Color3.fromRGB(75,75,75)
			UIStroke_3.Thickness = 1

			UIPadding_3.Parent = Body_1
			UIPadding_3.PaddingBottom = UDim.new(0,10)
			UIPadding_3.PaddingLeft = UDim.new(0,15)
			UIPadding_3.PaddingRight = UDim.new(0,15)
			UIPadding_3.PaddingTop = UDim.new(0,10)

			UIListLayout_3.Parent = Body_1
			UIListLayout_3.Padding = UDim.new(0,10)
			UIListLayout_3.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_3.VerticalAlignment = Enum.VerticalAlignment.Center

			Code_1.Name = "Code"
			Code_1.Parent = Body_1
			Code_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Code_1.BackgroundTransparency = 1
			Code_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Code_1.BorderSizePixel = 0
			Code_1.Size = UDim2.new(1, 0,1, 0)
			Code_1.Font = Enum.Font.GothamMedium
			Code_1.RichText = true
			Code_1.Text = Liquid:Init(CodeInput)
			Code_1.TextColor3 = Color3.fromRGB(204,204,204)
			Code_1.TextSize = 13
			Code_1.TextXAlignment = Enum.TextXAlignment.Left
			Code_1.TextYAlignment = Enum.TextYAlignment.Top
			Code_1.TextWrapped = true

			Code_1:GetPropertyChangedSignal('TextBounds'):Connect(function()
				Body_1.Size = UDim2.new(1, 0, 0, math.max(34, Code_1.TextBounds.Y + 15))
			end)

			UIListLayout_2:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
				Template.Size = UDim2.new(1, 0,0, UIListLayout_2.AbsoluteContentSize.Y + 30)
			end)

			local Setting = {}

			function Setting:SetCode(input)
				CodeInput = input
				Code_1.Text = Liquid:Init(CodeInput)
			end

			local Button = Liquid:Button(Copy_1)

			Button.MouseButton1Click:Connect(function()
				Copy_1.Image = "rbxassetid://121742282171603"

				delay(0.75, function()
					Copy_1.Image = "rbxassetid://78020815235467"
				end)

				pcall(setclipboard, CodeInput)
			end)

			return Setting
		end

		return __index
	end

	function ListTabs:SetTransparent(value)
		if value then
			Background_1.BackgroundTransparency = 0.16
		else
			Background_1.BackgroundTransparency = 0
		end
	end

	function ListTabs:SetKeybind(value)
		Keybind = value
	end

	function ListTabs:Close()
		On = false
		closeopenui(true)
	end

	function ListTabs:Open()
		On = true
		closeopenui(false)
	end

	function ListTabs:Toggle()
		On = not On
		closeopenui(On)
	end

	function ListTabs:Destroy()
		LiquidUI:Destroy()
		LiquidToggle:Destroy()
	end

	function ListTabs:GetPath()
		return LiquidUI
	end

	function ListTabs:GetWindowSettings()
		return configs
	end

	function ListTabs:GetWindowSetting(index)
		return configs[index]
	end

	function ListTabs:TweenScale(size)
		RuntimeScaler = size

		Liquid:Tween({
			v = ScaleUI,
			t = 0.2,
			s = "Exponential",
			d = "Out",
			g = {Scale = RuntimeScaler}
		}):Play()
	end

	function ListTabs:GetScale()
		return ScaleUI.Scale
	end

	function ListTabs:TweenSize(udim)
		Liquid:Tween({
			v = Background_1,
			t = 0.2,
			s = "Exponential",
			d = "Out",
			g = {Size = udim}
		}):Play()
	end

	local LiquidNotify = Instance.new("ScreenGui")
	local History_1 = Instance.new("Frame")
	local UIListLayout_1 = Instance.new("UIListLayout")
	local UIPadding_1 = Instance.new("UIPadding")

	LiquidNotify.Name = "LiquidNotify"
	LiquidNotify.Parent = Liquid:Parent()
	LiquidNotify.ZIndexBehavior = Enum.ZIndexBehavior.Global
	LiquidNotify.IgnoreGuiInset = true

	History_1.Name = "History"
	History_1.Parent = LiquidNotify
	History_1.AnchorPoint = Vector2.new(1, 0.5)
	History_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	History_1.BackgroundTransparency = 1
	History_1.BorderColor3 = Color3.fromRGB(0,0,0)
	History_1.BorderSizePixel = 0
	History_1.Position = UDim2.new(1, 0,0.5, 0)
	History_1.Size = UDim2.new(0, 320,1, 0)

	UIListLayout_1.Parent = History_1
	UIListLayout_1.Padding = UDim.new(0,10)
	UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Right
	UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Bottom

	UIPadding_1.Parent = History_1
	UIPadding_1.PaddingBottom = UDim.new(0,10)
	UIPadding_1.PaddingLeft = UDim.new(0,10)
	UIPadding_1.PaddingRight = UDim.new(0,10)
	UIPadding_1.PaddingTop = UDim.new(0,10)

	function ListTabs:Notification(options)
		local Title = options.Title or 'Notification'
		local Desc = options.Desc or nil
		local Duration = options.Duration or 9e9
		local Icon = options.Icon or nil

		local Template = Instance.new("Frame")
		local UIStroke_1 = Instance.new("UIStroke")
		local UICorner_1 = Instance.new("UICorner")
		local Scaler_1 = Instance.new("Frame")
		local Icon_1 = Instance.new("ImageLabel")
		local UIListLayout_1 = Instance.new("UIListLayout")
		local UIPadding_1 = Instance.new("UIPadding")
		local Text_1 = Instance.new("Frame")
		local UIListLayout_2 = Instance.new("UIListLayout")
		local Title_1 = Instance.new("TextLabel")
		local UIPadding_2 = Instance.new("UIPadding")
		local Desc_1 = Instance.new("TextLabel")
		local Shadow_1 = Instance.new("ImageLabel")

		Template.Name = "Template"
		Template.Parent = History_1
		Template.BackgroundColor3 = Color3.fromRGB(14,15,20)
		Template.BackgroundTransparency = 1
		Template.BorderColor3 = Color3.fromRGB(0,0,0)
		Template.BorderSizePixel = 0
		Template.Size = UDim2.new(0, 0, 0, 55)
		Template.Position = UDim2.new(0.5, 0, 0, 0)
		Template.AnchorPoint = Vector2.new(0.5, 0)

		UIStroke_1.Parent = Template
		UIStroke_1.Color = Color3.fromRGB(25,25,25)
		UIStroke_1.Thickness = 1
		UIStroke_1.Transparency = 1

		UICorner_1.Parent = Template
		UICorner_1.CornerRadius = UDim.new(0,4)

		Scaler_1.Name = "Scaler"
		Scaler_1.Parent = Template
		Scaler_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Scaler_1.BackgroundTransparency = 1
		Scaler_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Scaler_1.BorderSizePixel = 0
		Scaler_1.Size = UDim2.new(1, 0,1, 0)

		if Icon then
			Icon_1.Name = "Icon"
			Icon_1.Parent = Scaler_1
			Icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
			Icon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Icon_1.BackgroundTransparency = 1
			Icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Icon_1.BorderSizePixel = 0
			Icon_1.Position = UDim2.new(0.5, 0,0.5, 0)
			Icon_1.Size = UDim2.new(0, 15,0, 15)
			Icon_1.Image = Liquid:Asset(Icon)
			Icon_1.ImageTransparency = 1
		end

		UIListLayout_1.Parent = Scaler_1
		UIListLayout_1.Padding = UDim.new(0,15)
		UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

		UIPadding_1.Parent = Scaler_1
		UIPadding_1.PaddingRight = UDim.new(0,20)

		Text_1.Name = "Text"
		Text_1.Parent = Scaler_1
		Text_1.AnchorPoint = Vector2.new(1, 0.5)
		Text_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Text_1.BackgroundTransparency = 1
		Text_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Text_1.BorderSizePixel = 0
		Text_1.LayoutOrder = -1
		Text_1.Position = UDim2.new(0, 0,0.5, 0)
		Text_1.ClipsDescendants = true

		if Icon then
			Text_1.Size = UDim2.new(1, -30,1, 0)
		else
			Text_1.Size = UDim2.new(1, 0,1, 0)
		end

		UIListLayout_2.Parent = Text_1
		UIListLayout_2.Padding = UDim.new(0, 2)
		UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

		Title_1.Name = "Title"
		Title_1.Parent = Text_1
		Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Title_1.BackgroundTransparency = 1
		Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Title_1.BorderSizePixel = 0
		Title_1.LayoutOrder = -1
		Title_1.Size = UDim2.new(1, 0,0, 13)
		Title_1.Font = Enum.Font.GothamMedium
		Title_1.RichText = true
		Title_1.Text = Title
		Title_1.TextColor3 = Color3.fromRGB(235,235,235)
		Title_1.TextSize = 13
		Title_1.TextXAlignment = Enum.TextXAlignment.Left
		Title_1.TextTransparency = 1

		UIPadding_2.Parent = Text_1
		UIPadding_2.PaddingBottom = UDim.new(0,2)
		UIPadding_2.PaddingLeft = UDim.new(0,15)
		UIPadding_2.PaddingRight = UDim.new(0,15)
		UIPadding_2.PaddingTop = UDim.new(0,2)

		local finalHeight = 55

		if Desc then
			Desc_1.Name = "Desc"
			Desc_1.Parent = Text_1
			Desc_1.BackgroundColor3 = Color3.fromRGB(145,145,145)
			Desc_1.BackgroundTransparency = 1
			Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Desc_1.BorderSizePixel = 0
			Desc_1.Font = Enum.Font.GothamMedium
			Desc_1.RichText = true
			Desc_1.Size = UDim2.new(1, 0, 0, 0)
			Desc_1.Text = Desc
			Desc_1.TextColor3 = Color3.fromRGB(145,145,145)
			Desc_1.TextSize = 12
			Desc_1.TextXAlignment = Enum.TextXAlignment.Left
			Desc_1.TextYAlignment = Enum.TextYAlignment.Top
			Desc_1.TextTransparency = 1
			Desc_1.TextWrapped = true
			Desc_1.AutomaticSize = Enum.AutomaticSize.Y
		end

		Shadow_1.Name = "Shadow"
		Shadow_1.Parent = Template
		Shadow_1.AnchorPoint = Vector2.new(0.5, 0.5)
		Shadow_1.BackgroundColor3 = Color3.fromRGB(0,0,0)
		Shadow_1.BackgroundTransparency = 1
		Shadow_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Shadow_1.BorderSizePixel = 0
		Shadow_1.Position = UDim2.new(0.5, 0,0.5, 0)
		Shadow_1.Size = UDim2.new(1, 110,1, 110)
		Shadow_1.ZIndex = 0
		Shadow_1.Image = "rbxassetid://8992230677"
		Shadow_1.ImageColor3 = Color3.fromRGB(0,0,0)
		Shadow_1.ImageTransparency = 1
		Shadow_1.ScaleType = Enum.ScaleType.Slice
		Shadow_1.SliceCenter = Rect.new(99, 99, 99, 99)

		Liquid:Tween({
			v = Shadow_1,
			t = 0.4,
			s = "Back",
			d = "Out",
			g = {
				ImageTransparency = 0.65
			}
		}):Play()

		if Desc then
			Liquid:Tween({
				v = Template,
				t = 0.5,
				s = "Back",
				d = "Out",
				g = {
					Size = UDim2.new(1, 0, 0, UIListLayout_1.AbsoluteContentSize.Y + 40),
					BackgroundTransparency = 0.1599999964237213
				}
			}):Play()
		else
			Liquid:Tween({
				v = Template,
				t = 0.5,
				s = "Back",
				d = "Out",
				g = {
					Size = UDim2.new(1, 0, 0, 55),
					BackgroundTransparency = 0.1599999964237213
				}
			}):Play()
		end

		Liquid:Tween({
			v = UIStroke_1,
			t = 0.4,
			s = "Quart",
			d = "Out",
			g = {
				Transparency = 0.15
			}
		}):Play()

		delay(0.2, function()
			Liquid:Tween({
				v = Title_1,
				t = 0.4,
				s = "Quart",
				d = "Out",
				g = {
					TextTransparency = 0
				}
			}):Play()

			if Desc then
				Liquid:Tween({
					v = Desc_1,
					t = 0.4,
					s = "Quart",
					d = "Out",
					g = {
						TextTransparency = 0
					}
				}):Play()
			end

			if Icon then
				Liquid:Tween({
					v = Icon_1,
					t = 0.4,
					s = "Quart",
					d = "Out",
					g = {
						ImageTransparency = 0.5
					}
				}):Play()
			end
		end)

		delay(Duration, function()
			Liquid:Tween({
				v = Title_1,
				t = 0.3,
				s = "Quart",
				d = "In",
				g = {
					TextTransparency = 1
				}
			}):Play()

			if Desc then
				Liquid:Tween({
					v = Desc_1,
					t = 0.3,
					s = "Quart",
					d = "In",
					g = {
						TextTransparency = 1
					}
				}):Play()
			end

			if Icon then
				Liquid:Tween({
					v = Icon_1,
					t = 0.3,
					s = "Quart",
					d = "In",
					g = {
						ImageTransparency = 1
					}
				}):Play()
			end

			delay(0.15, function()
				Liquid:Tween({
					v = Shadow_1,
					t = 0.4,
					s = "Back",
					d = "In",
					g = {
						ImageTransparency = 1
					}
				}):Play()

				Liquid:Tween({
					v = UIStroke_1,
					t = 0.3,
					s = "Quart",
					d = "In",
					g = {
						Transparency = 1
					}
				}):Play()

				local Final = Liquid:Tween({
					v = Template,
					t = 0.5,
					s = "Back",
					d = "In",
					g = {
						Size = UDim2.new(0, 0, 0, finalHeight),
						BackgroundTransparency = 1
					}
				})

				Final:Play()

				Final.Completed:Once(function()
					Template:Destroy()
				end)
			end)
		end)
	end

	function ListTabs:Managers()
		local Setting = self:Tabs(81246215620663) do
			Setting:Section({
				Title = "Appearance",
				Icon = 92721515638108
			})

			Setting:Toggle({
				Title = "Transparent",
				Desc = "Make the background transparent.",
				Value = self:GetWindowSetting('Transparent'),
				Callback = function(_, state)
					self:SetTransparent(state)

					self:Notification({
						Title = state and "Transparent Has been Enabled" or "Transparent Has been Disabled",
						Icon = 96551286443180,
						Duration = 3
					})
				end,
			})
            
            local Textbox = Setting:Textbox({
               Title = "Window Size",
               Desc = "",
               Value = "Size",
               PlaceHolder = "Enter Size Example 550, 320...",
               Callback = function(text)
               Window:TweenSize(UDim2.new(0, text, 0, text))
                 print("Name changed to:", text)
              end
            })

			Setting:Section({
				Title = "Input",
				Icon = 91697619966971
			})

			Setting:Input({
				Title = "Window Shortcut",
				Desc = "A shortcut key that lets you open or close a UI window with one press.",
				Key = Enum.KeyCode.LeftControl,
				Value = true,
				Callback = function(_, key, state)
					self:SetKeybind(key)
				end,
			})

			return Setting
		end
	end

	return ListTabs
end

return Liquid

