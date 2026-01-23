--[[
    User Interface Library
    Made by Late
]]
--// Connections
local GetService = game.GetService
local Connect = game.Loaded.Connect
local Wait = game.Loaded.Wait
local Clone = game.Clone 
local Destroy = game.Destroy 
if (not game:IsLoaded()) then
    local Loaded = game.Loaded
    Loaded.Wait(Loaded);
end
--// Important 
local Setup = {
    Keybind = Enum.KeyCode.LeftControl,
    Transparency = 0.2,
    ThemeMode = "Dark",
    Size = nil,
}
local Theme = { --// (Dark Theme)
    --// Frames:
    Primary = Color3.fromRGB(30, 30, 30),
    Secondary = Color3.fromRGB(35, 35, 35),
    Component = Color3.fromRGB(40, 40, 40),
    Interactables = Color3.fromRGB(45, 45, 45),
    --// Text:
    Tab = Color3.fromRGB(200, 200, 200),
    Title = Color3.fromRGB(240,240,240),
    Description = Color3.fromRGB(200,200,200),
    --// Outlines:
    Shadow = Color3.fromRGB(0, 0, 0),
    Outline = Color3.fromRGB(40, 40, 40),
    --// Image:
    Icon = Color3.fromRGB(220, 220, 220),
}
--// Services & Functions
local Type, Blur = nil
local LocalPlayer = GetService(game, "Players").LocalPlayer;
local Services = {
    Insert = GetService(game, "InsertService");
    Tween = GetService(game, "TweenService");
    Run = GetService(game, "RunService");
    Input = GetService(game, "UserInputService");
}
local Player = {
    Mouse = LocalPlayer:GetMouse();
    GUI = LocalPlayer.PlayerGui;
}
local Tween = function(Object : Instance, Speed : number, Properties : {},  Info : { EasingStyle: Enum?, EasingDirection: Enum? })
    local Style, Direction
    if Info then
        Style, Direction = Info["EasingStyle"], Info["EasingDirection"]
    else
        Style, Direction = Enum.EasingStyle.Sine, Enum.EasingDirection.Out
    end
    return Services.Tween:Create(Object, TweenInfo.new(Speed, Style, Direction), Properties):Play()
end
local SetProperty = function(Object: Instance, Properties: {})
    for Index, Property in next, Properties do
        Object[Index] = (Property);
    end
    return Object
end
local Multiply = function(Value, Amount)
    local New = {
        Value.X.Scale * Amount;
        Value.X.Offset * Amount;
        Value.Y.Scale * Amount;
        Value.Y.Offset * Amount;
    }
    return UDim2.new(unpack(New))
end
local Color = function(Color, Factor, Mode)
    Mode = Mode or Setup.ThemeMode
    if Mode == "Light" then
        return Color3.fromRGB((Color.R * 255) - Factor, (Color.G * 255) - Factor, (Color.B * 255) - Factor)
    else
        return Color3.fromRGB((Color.R * 255) + Factor, (Color.G * 255) + Factor, (Color.B * 255) + Factor)
    end
end
local Drag = function(Canvas)
    if Canvas then
        local Dragging;
        local DragInput;
        local Start;
        local StartPosition;
        local function Update(input)
            local delta = input.Position - Start
            Canvas.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
        end
        Connect(Canvas.InputBegan, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch and not Type then
                Dragging = true
                Start = Input.Position
                StartPosition = Canvas.Position
                Connect(Input.Changed, function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)
        Connect(Canvas.InputChanged, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch and not Type then
                DragInput = Input
            end
        end)
        Connect(Services.Input.InputChanged, function(Input)
            if Input == DragInput and Dragging and not Type then
                Update(Input)
            end
        end)
    end
end
Resizing = { 
    TopLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, -1)};
    TopRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, -1)};
    BottomLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, 1)};
    BottomRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, 1)};
}
Resizeable = function(Tab, Minimum, Maximum)
    task.spawn(function()
        local MousePos, Size, UIPos = nil, nil, nil
        if Tab and Tab:FindFirstChild("Resize") then
            local Positions = Tab:FindFirstChild("Resize")
            for Index, Types in next, Positions:GetChildren() do
                Connect(Types.InputBegan, function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Type = Types
                        MousePos = Vector2.new(Player.Mouse.X, Player.Mouse.Y)
                        Size = Tab.AbsoluteSize
                        UIPos = Tab.Position
                    end
                end)
                Connect(Types.InputEnded, function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Type = nil
                    end
                end)
            end
        end
        local Resize = function(Delta)
            if Type and MousePos and Size and UIPos and Tab:FindFirstChild("Resize")[Type.Name] == Type then
                local Mode = Resizing[Type.Name]
                local NewSize = Vector2.new(Size.X + Delta.X * Mode.X.X, Size.Y + Delta.Y * Mode.Y.Y)
                NewSize = Vector2.new(math.clamp(NewSize.X, Minimum.X, Maximum.X), math.clamp(NewSize.Y, Minimum.Y, Maximum.Y))
                local AnchorOffset = Vector2.new(Tab.AnchorPoint.X * Size.X, Tab.AnchorPoint.Y * Size.Y)
                local NewAnchorOffset = Vector2.new(Tab.AnchorPoint.X * NewSize.X, Tab.AnchorPoint.Y * NewSize.Y)
                local DeltaAnchorOffset = NewAnchorOffset - AnchorOffset
                Tab.Size = UDim2.new(0, NewSize.X, 0, NewSize.Y)
                local NewPosition = UDim2.new(
                    UIPos.X.Scale, 
                    UIPos.X.Offset + DeltaAnchorOffset.X * Mode.X.X,
                    UIPos.Y.Scale,
                    UIPos.Y.Offset + DeltaAnchorOffset.Y * Mode.Y.Y
                )
                Tab.Position = NewPosition
            end
        end
        Connect(Player.Mouse.Move, function()
            if Type then
                Resize(Vector2.new(Player.Mouse.X, Player.Mouse.Y) - MousePos)
            end
        end)
    end)
end
--// Setup [UI]
if (identifyexecutor) then
    Screen = Services.Insert:LoadLocalAsset("rbxassetid://18490507748");
    Blur = loadstring(game:HttpGet("https://gist.githubusercontent.com/MjContiga1/95d2f96ab1afc978cb33d9ef824def05/raw/07f17c2aeac7b647c416b982ea31adacf999be56/Ui%2520blur%2520code.lua"))();
else
    Screen = (script.Parent);
    Blur = require(script.Blur)
end
Screen.Main.Visible = false
xpcall(function()
    Screen.Parent = game.CoreGui
end, function() 
    Screen.Parent = Player.GUI
end)
--// Tables for Data
local Animations = {}
local Blurs = {}
local Components = (Screen:FindFirstChild("Components"));
local Library = {};
local StoredInfo = {
    ["Sections"] = {};
    ["Tabs"] = {}
};
--// Animations [Window]
function Animations:Open(Window: CanvasGroup, Transparency: number, UseCurrentSize: boolean)
    local Original = (UseCurrentSize and Window.Size) or Setup.Size
    local Multiplied = Multiply(Original, 1.1)
    local Shadow = Window:FindFirstChildOfClass("UIStroke")
    SetProperty(Shadow, { Transparency = 1 })
    SetProperty(Window, {
        Size = Multiplied,
        GroupTransparency = 1,
        Visible = true,
    })
    Tween(Shadow, .25, { Transparency = 0.5 })
    Tween(Window, .25, {
        Size = Original,
        GroupTransparency = Transparency or 0,
    })
end
function Animations:Close(Window: CanvasGroup)
    local Original = Window.Size
    local Multiplied = Multiply(Original, 1.1)
    local Shadow = Window:FindFirstChildOfClass("UIStroke")
    SetProperty(Window, {
        Size = Original,
    })
    Tween(Shadow, .25, { Transparency = 1 })
    Tween(Window, .25, {
        Size = Multiplied,
        GroupTransparency = 1,
    })
    task.wait(.25)
    Window.Size = Original
    Window.Visible = false
end
function Animations:Component(Component: any, Custom: boolean)	
    Connect(Component.InputBegan, function() 
        if Custom then
            Tween(Component, .25, { Transparency = .85 });
        else
            Tween(Component, .25, { BackgroundColor3 = Color(Theme.Component, 5, Setup.ThemeMode) });
        end
    end)
    Connect(Component.InputEnded, function() 
        if Custom then
            Tween(Component, .25, { Transparency = 1 });
        else
            Tween(Component, .25, { BackgroundColor3 = Theme.Component });
        end
    end)
end
--// NEW: Improved Floating Icon Implementation
local FloatingIcon = {}
function FloatingIcon:Create()
    local icon = Instance.new("ImageButton")
    icon.Name = "FloatingIcon"
    icon.Image = "rbxassetid://114178849342027"
    icon.Size = UDim2.new(0, 50, 0, 50) -- Medium size square
    icon.Position = UDim2.new(0, 100, 0, 100) -- Default position
    icon.BackgroundTransparency = 1
    icon.Visible = false
    icon.ZIndex = 100
    icon.Active = true
    
    -- Make draggable
    Drag(icon)
    
    -- Create restore button
    local restoreBtn = Instance.new("ImageButton")
    restoreBtn.Name = "RestoreButton"
    restoreBtn.Image = "rbxassetid://7734000129"
    restoreBtn.Size = UDim2.new(0, 20, 0, 20)
    restoreBtn.Position = UDim2.new(0, 5, 0, 5)
    restoreBtn.BackgroundTransparency = 1
    restoreBtn.Visible = true -- Always visible for better UX
    restoreBtn.ZIndex = 101
    restoreBtn.Parent = icon
    
    -- Create exit button
    local exitBtn = Instance.new("ImageButton")
    exitBtn.Name = "ExitButton"
    exitBtn.Image = "rbxassetid://7755372427"
    exitBtn.Size = UDim2.new(0, 20, 0, 20)
    exitBtn.Position = UDim2.new(1, -25, 0, 5)
    exitBtn.BackgroundTransparency = 1
    exitBtn.Visible = true -- Always visible for better UX
    exitBtn.ZIndex = 101
    exitBtn.Parent = icon
    
    -- Add animations
    Animations:Component(restoreBtn, true)
    Animations:Component(exitBtn, true)
    
    icon.Parent = Screen
    return icon
end
--// Library [Window]
function Library:CreateWindow(Settings: { Title: string, Size: UDim2, Transparency: number, MinimizeKeybind: Enum.KeyCode?, Blurring: boolean, Theme: string })
    local Window = Clone(Screen:WaitForChild("Main"));
    local Sidebar = Window:FindFirstChild("Sidebar");
    local Holder = Window:FindFirstChild("Main");
    local BG = Window:FindFirstChild("BackgroundShadow");
    local Tab = Sidebar:FindFirstChild("Tab");
    local Options = {};
    local Examples = {};
    local Opened = true;
    local Maximized = false;
    local BlurEnabled = false
    
    --// NEW: Create floating icon instance
    local floatingIcon = FloatingIcon:Create()
    
    for Index, Example in next, Window:GetDescendants() do
        if Example.Name:find("Example") and not Examples[Example.Name] then
            Examples[Example.Name] = Example
        end
    end
    
    --// NEW: Add window controls to the top right of the entire UI
    -- Create a container for the window controls
    local windowControls = Instance.new("Frame")
    windowControls.Name = "WindowControls"
    windowControls.Size = UDim2.new(0, 60, 0, 30) -- Width of 60 pixels, height of 30 pixels
    windowControls.Position = UDim2.new(1, -60, 0, 0) -- Top right corner
    windowControls.BackgroundTransparency = 1
    windowControls.ZIndex = 10 -- Ensure it's on top of other elements
    windowControls.Parent = Window
    
    -- Create layout for buttons
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = windowControls
    
    -- Create minimize button
    local minimizeBtn = Instance.new("ImageButton")
    minimizeBtn.Name = "MinimizeButton"
    minimizeBtn.Image = "rbxassetid://7734000129"
    minimizeBtn.Size = UDim2.new(0, 20, 0, 20)
    minimizeBtn.BackgroundTransparency = 1
    minimizeBtn.LayoutOrder = 1
    minimizeBtn.ZIndex = 11
    minimizeBtn.Parent = windowControls
    
    -- Create exit button
    local exitBtn = Instance.new("ImageButton")
    exitBtn.Name = "ExitButton"
    exitBtn.Image = "rbxassetid://7755372427"
    exitBtn.Size = UDim2.new(0, 20, 0, 20)
    exitBtn.BackgroundTransparency = 1
    exitBtn.LayoutOrder = 2
    exitBtn.ZIndex = 11
    exitBtn.Parent = windowControls
    
    -- Add button animations
    Animations:Component(minimizeBtn, true)
    Animations:Component(exitBtn, true)
    
    -- Button functionality
    minimizeBtn.MouseButton1Click:Connect(function()
        Window.Visible = false
        Opened = false
        if BlurEnabled then
            Blurs[Settings.Title].root.Parent = nil
        end
        -- Show floating icon
        floatingIcon.Visible = true
        floatingIcon.Position = UDim2.new(0, 100, 0, 100) -- Reset position
    end)
    
    exitBtn.MouseButton1Click:Connect(function()
        Window:Destroy()
        floatingIcon:Destroy()
    end)
    
    -- Floating icon button functionality
    floatingIcon.RestoreButton.MouseButton1Click:Connect(function()
        Window.Visible = true
        Opened = true
        if BlurEnabled then
            Blurs[Settings.Title].root.Parent = workspace.CurrentCamera
        end
        floatingIcon.Visible = false
    end)
    
    floatingIcon.ExitButton.MouseButton1Click:Connect(function()
        Window:Destroy()
        floatingIcon:Destroy()
    end)
    
    --// NEW: Properly structure the sidebar top bar with title and buttons
    local topBar = Sidebar:FindFirstChild("Top")
    if topBar then
        -- Remove any existing title or control elements to avoid duplicates
        for _, child in ipairs(topBar:GetChildren()) do
            if child.Name == "Title" or child.Name == "WindowControls" or child.Name == "TopBarContainer" or child.Name == "TitleContainer" or child.Name == "ButtonContainer" then
                child:Destroy()
            end
        end
        
        -- Create a main container for the top bar content
        local topBarContainer = Instance.new("Frame")
        topBarContainer.Name = "TopBarContainer"
        topBarContainer.Size = UDim2.new(1, 0, 1, 0)
        topBarContainer.Position = UDim2.new(0, 0, 0, 0)
        topBarContainer.BackgroundTransparency = 1
        topBarContainer.Parent = topBar
        
        -- Create layout for the top bar container
        local topBarLayout = Instance.new("UIListLayout")
        topBarLayout.FillDirection = Enum.FillDirection.Horizontal
        topBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        topBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        topBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
        topBarLayout.Padding = UDim.new(0, 0)
        topBarLayout.Parent = topBarContainer
        
        -- Create title container (left side) - takes up all available space
        local titleContainer = Instance.new("Frame")
        titleContainer.Name = "TitleContainer"
        titleContainer.Size = UDim2.new(1, -70, 1, 0) -- Leave space for buttons
        titleContainer.BackgroundTransparency = 1
        titleContainer.LayoutOrder = 1
        titleContainer.Parent = topBarContainer
        
        -- Create title label with auto-sizing
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "Title"
        titleLabel.Text = Settings.Title or "UI Library"
        titleLabel.Font = Enum.Font.GothamSemibold
        titleLabel.TextSize = 14
        titleLabel.TextColor3 = Theme.Title
        titleLabel.Size = UDim2.new(1, -10, 1, 0) -- Full width with padding
        titleLabel.Position = UDim2.new(0, 10, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextScaled = true -- Auto-scale text to fit
        titleLabel.TextWrapped = true -- Wrap text if needed
        titleLabel.Parent = titleContainer
        
        -- Create button container (right side)
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Name = "ButtonContainer"
        buttonContainer.Size = UDim2.new(0, 60, 1, 0)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.LayoutOrder = 2
        buttonContainer.Parent = topBarContainer
        
        -- Create layout for buttons
        local buttonLayout = Instance.new("UIListLayout")
        buttonLayout.FillDirection = Enum.FillDirection.Horizontal
        buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        buttonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
        buttonLayout.Padding = UDim.new(0, 5)
        buttonLayout.Parent = buttonContainer
        
        -- Move existing buttons (like maximize) to the new button container
        for _, button in ipairs(Sidebar.Top.Buttons:GetChildren()) do
            if button:IsA("TextButton") and button.Name ~= "Minimize" and button.Name ~= "Close" then
                button.Parent = buttonContainer
                -- Add animations to moved buttons
                Animations:Component(button, true)
            end
        end
        
        -- Remove the old buttons container
        Sidebar.Top.Buttons:Destroy()
        
        -- Add a function to adjust title size when window is resized
        local function adjustTitleSize()
            -- Calculate available width for title
            local availableWidth = titleContainer.AbsoluteSize.X - 10 -- Subtract padding
            local textWidth = titleLabel.TextBounds.X
            
            -- If text is wider than available space, scale down the font
            if textWidth > availableWidth then
                local scaleFactor = availableWidth / textWidth
                titleLabel.TextSize = math.max(8, 14 * scaleFactor) -- Minimum font size of 8
            else
                titleLabel.TextSize = 14
            end
        end
        
        -- Connect to window resize events
        local resizeConnection
        resizeConnection = Window:GetPropertyChangedSignal("Size"):Connect(function()
            adjustTitleSize()
        end)
        
        -- Initial adjustment
        adjustTitleSize()
    end
    
    --// UI Blur & More
    Drag(Window);
    Resizeable(Window, Vector2.new(411, 271), Vector2.new(9e9, 9e9));
    Setup.Transparency = Settings.Transparency or 0
    Setup.Size = Settings.Size
    Setup.ThemeMode = Settings.Theme or "Dark"
    if Settings.Blurring then
        Blurs[Settings.Title] = Blur.new(Window, 5)
        BlurEnabled = true
    end
    if Settings.MinimizeKeybind then
        Setup.Keybind = Settings.MinimizeKeybind
    end
    --// Animate
    local Close = function()
        if Opened then
            if BlurEnabled then
                Blurs[Settings.Title].root.Parent = nil
            end
            Opened = false
            Animations:Close(Window)
            Window.Visible = false
            -- Show floating icon when minimized
            floatingIcon.Visible = true
        else
            Animations:Open(Window, Setup.Transparency)
            Opened = true
            if BlurEnabled then
                Blurs[Settings.Title].root.Parent = workspace.CurrentCamera
            end
            -- Hide floating icon when restored
            floatingIcon.Visible = false
        end
    end
    
    -- Handle maximize button functionality
    local function handleMaximizeButton()
        if Maximized then
            Maximized = false
            Tween(Window, .15, { Size = Setup.Size });
        else
            Maximized = true
            Tween(Window, .15, { Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0.5, 0.5 )});
        end
    end
    
    -- Connect maximize button if it exists
    local maximizeButton = Sidebar:FindFirstChild("Top", true):FindFirstChild("Maximize")
    if maximizeButton then
        maximizeButton.MouseButton1Click:Connect(handleMaximizeButton)
    end
    
    Services.Input.InputBegan:Connect(function(Input, Focused) 
        if (Input == Setup.Keybind or Input.KeyCode == Setup.Keybind) and not Focused then
            Close()
        end
    end)
    
	--// Tab Functions
function Options:SetTab(Name: string)  
	-- 🔹 Loop through buttons inside the scrollable TabsHolder
	for Index, Button in next, self.TabsHolder:GetChildren() do  
		if Button:IsA("TextButton") then  
			local Opened, SameName = Button.Value, (Button.Name == Name)  
			local Padding = Button:FindFirstChildOfClass("UIPadding")  

			if SameName and not Opened.Value then  
				Tween(Padding, .25, { PaddingLeft = UDim.new(0, 25) })  
				Tween(Button, .25, { BackgroundTransparency = 0.9, Size = UDim2.new(1, -15, 0, 30) })  
				SetProperty(Opened, { Value = true })  
			elseif not SameName and Opened.Value then  
				Tween(Padding, .25, { PaddingLeft = UDim.new(0, 20) })  
				Tween(Button, .25, { BackgroundTransparency = 1, Size = UDim2.new(1, -44, 0, 30) })  
				SetProperty(Opened, { Value = false })  
			end  
		end  
	end  

	-- 🔹 Content switching stays the same
	for Index, Main in next, Holder:GetChildren() do  
		if Main:IsA("CanvasGroup") then  
			local Opened, SameName = Main.Value, (Main.Name == Name)  
			local Scroll = Main:FindFirstChild("ScrollingFrame")  

			if SameName and not Opened.Value then  
				Opened.Value = true  
				Main.Visible = true  

				Tween(Main, .3, { GroupTransparency = 0 })  
				Tween(Scroll["UIPadding"], .3, { PaddingTop = UDim.new(0, 5) })  

			elseif not SameName and Opened.Value then  
				Opened.Value = false  

				Tween(Main, .15, { GroupTransparency = 1 })  
				Tween(Scroll["UIPadding"], .15, { PaddingTop = UDim.new(0, 15) })  

				task.delay(.2, function()  
					Main.Visible = false  
				end)  
			end  
		end  
	end  
end
	
-- Make sure TabsHolder exists (helper)
function Options:EnsureTabsHolder(Example)
	if not self.TabsHolder then
		local TabsHolder = Instance.new("ScrollingFrame")
		TabsHolder.Name = "TabsHolder"
		TabsHolder.Size = UDim2.new(0, 150, 1, 0)
		TabsHolder.Position = UDim2.new(0, 0, 0, 0)
		TabsHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
		TabsHolder.ScrollBarThickness = 6
		TabsHolder.BackgroundTransparency = 1
		TabsHolder.Parent = Example.Parent  

		local UIList = Instance.new("UIListLayout")
		UIList.SortOrder = Enum.SortOrder.LayoutOrder
		UIList.Parent = TabsHolder

		-- auto resize scroll area
		UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			TabsHolder.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
		end)

		self.TabsHolder = TabsHolder
	end
	return self.TabsHolder
end

function Options:AddTabSection(Settings: { Name: string, Order: number })  
	local Example = Examples["SectionExample"];  
	local Section = Clone(Example);  

	local TabsHolder = self:EnsureTabsHolder(Example)

	SetProperty(Section, {   
		Parent = TabsHolder,  
		Text = Settings.Name,  
		Name = Settings.Name,  
		LayoutOrder = Settings.Order,  
		Visible = true  
	});  

	StoredInfo["Sections"][Settings.Name] = {  
		Order = Settings.Order,  
		Object = Section  
	};  
end

function Options:AddTab(Settings: { Title: string, Icon: string, Section: string? })  
	if StoredInfo["Tabs"][Settings.Title] then   
		error("[UI LIB]: A tab with the same name has already been created")   
	end   

	local Example, MainExample = Examples["TabButtonExample"], Examples["MainExample"];  
	local Main = Clone(MainExample);  
	local Tab = Clone(Example);  

	local TabsHolder = self:EnsureTabsHolder(Example)

	if not Settings.Icon then  
		Destroy(Tab["ICO"]);  
	else  
		SetProperty(Tab["ICO"], { Image = Settings.Icon });  
	end  

	StoredInfo["Tabs"][Settings.Title] = { Tab }  
	SetProperty(Tab["TextLabel"], { Text = Settings.Title });  

	SetProperty(Main, {   
		Parent = MainExample.Parent,  
		Name = Settings.Title;  
	});  

	-- ✅ use section order if exists
	local SectionInfo = Settings.Section and StoredInfo["Sections"][Settings.Section]  
	local LayoutOrder = SectionInfo and SectionInfo.Order or (#StoredInfo["Sections"] + 1)

	SetProperty(Tab, {   
		Parent = TabsHolder,  
		LayoutOrder = LayoutOrder,  
		Name = Settings.Title,  
		Visible = true;  
	});  

	Tab.MouseButton1Click:Connect(function()  
		Options:SetTab(Tab.Name);  
	end)  

	return Main.ScrollingFrame  
end

	
	--// Notifications
	
	function Options:Notify(Settings: { Title: string, Description: string, Duration: number }) 
		local Notification = Clone(Components["Notification"]);
		local Title, Description = Options:GetLabels(Notification);
		local Timer = Notification["Timer"];
		
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Notification, {
			Parent = Screen["Frame"],
		})
		
		task.spawn(function() 
			local Duration = Settings.Duration or 2
			local Wait = task.wait;
			
			Animations:Open(Notification, Setup.Transparency, true); Tween(Timer, Duration, { Size = UDim2.new(0, 0, 0, 4) });
			Wait(Duration);
			Animations:Close(Notification);
			Wait(1);
			Notification:Destroy();
		end)
	end

	--// Component Functions

	function Options:GetLabels(Component)
		local Labels = Component:FindFirstChild("Labels")

		return Labels.Title, Labels.Description
	end

function Options:AddSection(Settings: { Name: string, Tab: Instance })   
	local Section = Clone(Components["Section"]);  
	SetProperty(Section, {  
		Text = Settings.Name,  
		Parent = Settings.Tab,  
		Visible = true,  
	})  
end


 function Options:AddButton(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
    local Button = Clone(Components["Button"])
    local Title, Description = Options:GetLabels(Button)

    -- Add right-side image (smaller size)
    local RightImage = Instance.new("ImageLabel")
    RightImage.Name = "RightImage"
    RightImage.Size = UDim2.new(0, 22, 0, 22) -- Smaller size: 16x16 pixels
    RightImage.Position = UDim2.new(1, -41, 0.5, -10) -- Right-aligned, centered vertically
    RightImage.Image = "rbxassetid://7734010488"
    RightImage.BackgroundTransparency = 1
    RightImage.Parent = Button

    Connect(Button.MouseButton1Click, Settings.Callback)
    Animations:Component(Button)
    SetProperty(Title, { Text = Settings.Title })
    SetProperty(Description, { Text = Settings.Description })
    SetProperty(Button, {
        Name = Settings.Title,
        Parent = Settings.Tab,
        Visible = true,
        Size = UDim2.new(1, -20, 0, 0) -- Adjust size to accommodate the image
    })
end
	

	function Options:AddInput(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
		local Input = Clone(Components["Input"]);
		local Title, Description = Options:GetLabels(Input);
		local TextBox = Input["Main"]["Input"];

		Connect(Input.MouseButton1Click, function() 
			TextBox:CaptureFocus()
		end)

		Connect(TextBox.FocusLost, function() 
			Settings.Callback(TextBox.Text)
		end)

		Animations:Component(Input)
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Input, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddToggle(Settings: { Title: string, Description: string, Default: boolean, Tab: Instance, Callback: any }) 
		local Toggle = Clone(Components["Toggle"]);
		local Title, Description = Options:GetLabels(Toggle);

		local On = Toggle["Value"];
		local Main = Toggle["Main"];
		local Circle = Main["Circle"];
		
		local Set = function(Value)
			if Value then
				Tween(Main,   .2, { BackgroundColor3 = Color3.fromRGB(153, 155, 255) });
				Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -16, 0.5, 0) });
			else
				Tween(Main,   .2, { BackgroundColor3 = Theme.Interactables });
				Tween(Circle, .2, { BackgroundColor3 = Theme.Primary, Position = UDim2.new(0, 3, 0.5, 0) });
			end
			
			On.Value = Value
		end 

		Connect(Toggle.MouseButton1Click, function()
			local Value = not On.Value

			Set(Value)
			Settings.Callback(Value)
		end)

		Animations:Component(Toggle);
		Set(Settings.Default);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Toggle, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	
	function Options:AddKeybind(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
	-- This function is unchanged as it is not related to the dropdown issue.
	local Dropdown = Clone(Components["Keybind"])
	local Title, Description = Options:GetLabels(Dropdown)
	local Bind = Dropdown["Main"].Options
	
	local Mouse = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3 }
	local Types = { 
		["Mouse"] = "Enum.UserInputType.MouseButton", 
		["Key"] = "Enum.KeyCode." 
	}
	
	Connect(Dropdown.MouseButton1Click, function()
		local Time = tick()
		local Detect, Finished
		
		SetProperty(Bind, { Text = "..." })
		Detect = Connect(game.UserInputService.InputBegan, function(Key, Focused) 
			local InputType = (Key.UserInputType)
			
			if not Finished and not Focused then
				Finished = (true)
				
				if table.find(Mouse, InputType) then
					Settings.Callback(Key)
					SetProperty(Bind, {
						Text = tostring(InputType):gsub(Types.Mouse, "MB")
					})
				elseif InputType == Enum.UserInputType.Keyboard then
					Settings.Callback(Key)
					SetProperty(Bind, {
						Text = tostring(Key.KeyCode):gsub(Types.Key, "")
					})
				end
			end 
		end)
	end)

	Animations:Component(Dropdown)
	SetProperty(Title, { Text = Settings.Title })
	SetProperty(Description, { Text = Settings.Description })
	SetProperty(Dropdown, {
		Name = Settings.Title,
		Parent = Settings.Tab,
		Visible = true,
	})
end

function Options:AddDropdown(Settings: { Title: string, Description: string, Options: { [string]: any }, Tab: Instance, Callback: any, UpdateFunction: any? }) 
	local Dropdown = Clone(Components["Dropdown"])
	local Title, Description = Options:GetLabels(Dropdown)
	local Text = Dropdown["Main"].Options

	-- A self-contained state object for this specific dropdown instance.
	local state = {
		options = Settings.Options or {},
		selection = nil, -- This will store the key of the selected option
		updateFunction = Settings.UpdateFunction -- Store the update function
	}

	-- Function to refresh the dropdown content
	local function refreshDropdownContent(Example, ScrollingFrame)
		-- Clear existing buttons
		for _, child in ipairs(ScrollingFrame:GetChildren()) do
			if child:IsA("Frame") or child:IsA("TextButton") then
				Destroy(child)
			end
		end
		
		-- Build the UI from the current state.options
		for key, value in pairs(state.options) do
			local Button = Clone(Examples["DropdownButtonExample"])
			if not Button then continue end
			local BtnTitle, BtnDescription = Options:GetLabels(Button)

			SetProperty(BtnTitle, { Text = key })
			Destroy(BtnDescription)
			SetProperty(Button, { 
				Parent = ScrollingFrame,
				Visible = true,
				BackgroundColor3 = (key == state.selection) and Theme.Interactables or Theme.Component
			})

			Connect(Button.MouseButton1Click, function() 
				state.selection = key
				Text.Text = key
				Settings.Callback(value)
				
				-- Close popup
				Tween(BG, .25, { BackgroundTransparency = 1 })
				Animations:Close(Example)
				task.wait(2)
				Destroy(Example)
			end)
		end
	end

	Connect(Dropdown.MouseButton1Click, function()
		local Example = Clone(Examples["DropdownExample"])
		if not Example then return end
		local ScrollingFrame = Example.ScrollingFrame

		-- Standard popup opening logic
		Tween(BG, .25, { BackgroundTransparency = 0.6 })
		SetProperty(Example, { Parent = Window })
		Animations:Open(Example, 0, true)
		
		-- Add refresh button to dropdown popup
		local RefreshButton = Instance.new("TextButton")
		RefreshButton.Size = UDim2.new(0, 60, 0, 30)
		RefreshButton.Position = UDim2.new(1, -70, 0, -5)
		RefreshButton.BackgroundColor3 = Theme.Component
		RefreshButton.Text = "Refresh"
		RefreshButton.TextColor3 = Theme.Title
		RefreshButton.Font = Enum.Font.SourceSansBold
		RefreshButton.TextSize = 12
		RefreshButton.Parent = Example.Top
		
		Connect(RefreshButton.MouseButton1Click, function()
			if state.updateFunction then
				local newOptions = state.updateFunction()
				state.options = newOptions
				refreshDropdownContent(Example, ScrollingFrame)
			end
		end)
		
		for _, Button in ipairs(Example.Top.Buttons:GetChildren()) do
			if Button:IsA("TextButton") then
				Connect(Button.MouseButton1Click, function()
					Tween(BG, .25, { BackgroundTransparency = 1 })
					Animations:Close(Example)
					task.wait(2)
					Destroy(Example)
				end)
			end
		end
		
		-- Build the initial UI
		refreshDropdownContent(Example, ScrollingFrame)
	end)

	Animations:Component(Dropdown)
	SetProperty(Title, { Text = Settings.Title })
	SetProperty(Description, { Text = Settings.Description })
	SetProperty(Dropdown, { Name = Settings.Title, Parent = Settings.Tab, Visible = true })

	-- The controller object that is returned
	local controller = {}
	
	-- The function you will call to update the dropdown's options
	function controller:Update(newOptions)
		if type(newOptions) ~= "table" then
			-- If no options provided, try to use the UpdateFunction
			if state.updateFunction then
				newOptions = state.updateFunction()
			else
				warn("Dropdown:Update requires a table of options or an UpdateFunction.")
				return
			end
		end
		
		-- 1. Update the internal options
		state.options = newOptions
		
		-- 2. Check if the current selection is still valid. If not, reset it.
		if state.selection and not state.options[state.selection] then
			state.selection = nil
			Text.Text = "Select..."
			if Settings.Callback then
				Settings.Callback(nil) -- Optionally notify that the selection was cleared
			end
		end
	end
	
	-- Method to manually trigger the UpdateFunction
	function controller:Refresh()
		if state.updateFunction then
			self:Update(state.updateFunction())
			return true
		end
		return false
	end
	
	-- Method to get current options
	function controller:GetOptions()
		return state.options
	end
	
	-- Method to get current selection
	function controller:GetSelection()
		return state.selection
	end
	
	return controller
end

function Options:AddMultiDropdown(Settings: { Title: string, Description: string, Options: { [string]: any }, Tab: Instance, Callback: any, UpdateFunction: any? })
	local Dropdown = Clone(Components["Dropdown"])
	local Title, Description = Options:GetLabels(Dropdown)
	local Text = Dropdown["Main"].Options
	
	-- Self-contained state object
	local state = {
		options = Settings.Options or {},
		selected = {}, -- Stores keys of selected items
		updateFunction = Settings.UpdateFunction -- Store the update function
	}
	
	local function updateCallback()
		local selectedValues = {}
		for _, key in ipairs(state.selected) do
			if state.options[key] then
				table.insert(selectedValues, state.options[key])
			end
		end
		Settings.Callback(selectedValues)
		Text.Text = #state.selected > 0 and table.concat(state.selected, ", ") or "Select..."
	end
	
	-- Function to refresh the dropdown content
	local function refreshDropdownContent(Example, ScrollingFrame)
		-- Clear existing buttons
		for _, child in ipairs(ScrollingFrame:GetChildren()) do
			if child:IsA("Frame") or child:IsA("TextButton") then
				Destroy(child)
			end
		end
		
		-- Build UI from current state
		for key, value in pairs(state.options) do
			local Button = Clone(Examples["DropdownButtonExample"])
			if not Button then continue end
			local BtnTitle, BtnDescription = Options:GetLabels(Button)
			
			local isSelected = table.find(state.selected, key)
			
			local Checkmark = Instance.new("ImageLabel")
			Checkmark.Name = "Checkmark"
			Checkmark.Size = UDim2.new(0, 16, 0, 16)
			Checkmark.Position = UDim2.new(1, -20, 0.5, -8)
			Checkmark.Image = "rbxassetid://6031068421"
			Checkmark.BackgroundTransparency = 1
			Checkmark.Visible = isSelected and true or false
			Checkmark.Parent = Button
			
			SetProperty(BtnTitle, { Text = key })
			Destroy(BtnDescription)
			SetProperty(Button, {
				Parent = ScrollingFrame,
				Visible = true,
				BackgroundColor3 = isSelected and Theme.Interactables or Theme.Component,
			})
			
			Connect(Button.MouseButton1Click, function()
				local selectionIndex = table.find(state.selected, key)
				if selectionIndex then
					table.remove(state.selected, selectionIndex)
					Checkmark.Visible = false
					Tween(Button, .25, { BackgroundColor3 = Theme.Component })
				else
					table.insert(state.selected, key)
					Checkmark.Visible = true
					Tween(Button, .25, { BackgroundColor3 = Theme.Interactables })
				end
				updateCallback()
			end)
		end
	end
	
	Connect(Dropdown.MouseButton1Click, function()
		local Example = Clone(Examples["DropdownExample"])
		if not Example then return end
		local ScrollingFrame = Example.ScrollingFrame
		
		-- Standard popup opening logic
		Tween(BG, .25, { BackgroundTransparency = 0.6 })
		SetProperty(Example, { Parent = Window })
		Animations:Open(Example, 0, true)
		
		-- Add refresh button to dropdown popup
		local RefreshButton = Instance.new("TextButton")
		RefreshButton.Size = UDim2.new(0, 60, 0, 30)
		RefreshButton.Position = UDim2.new(1, -70, 0, -5)
		RefreshButton.BackgroundColor3 = Theme.Component
		RefreshButton.Text = "Refresh"
		RefreshButton.TextColor3 = Theme.Title
		RefreshButton.Font = Enum.Font.SourceSansBold
		RefreshButton.TextSize = 12
		RefreshButton.Parent = Example.Top
		
		Connect(RefreshButton.MouseButton1Click, function()
			if state.updateFunction then
				local newOptions = state.updateFunction()
				state.options = newOptions
				refreshDropdownContent(Example, ScrollingFrame)
			end
		end)
		
		for _, Button in ipairs(Example.Top.Buttons:GetChildren()) do
			if Button:IsA("TextButton") then
				Connect(Button.MouseButton1Click, function()
					Tween(BG, .25, { BackgroundTransparency = 1 })
					Animations:Close(Example)
					task.wait(2)
					Destroy(Example)
				end)
			end
		end
		
		-- Build the initial UI
		refreshDropdownContent(Example, ScrollingFrame)
	end)

	Animations:Component(Dropdown)
	SetProperty(Title, { Text = Settings.Title })
	SetProperty(Description, { Text = Settings.Description })
	SetProperty(Dropdown, { Name = Settings.Title, Parent = Settings.Tab, Visible = true })
	
	-- The controller object to be returned
	local controller = {}
	
	-- The function you will call to update the options
	function controller:Update(newOptions)
		if type(newOptions) ~= "table" then
			-- If no options provided, try to use the UpdateFunction
			if state.updateFunction then
				newOptions = state.updateFunction()
			else
				warn("MultiDropdown:Update requires a table of options or an UpdateFunction.")
				return
			end
		end
		
		state.options = newOptions
		
		local selectionChanged = false
		local newSelected = {}
		for _, selectedKey in ipairs(state.selected) do
			if state.options[selectedKey] then
				table.insert(newSelected, selectedKey)
			else
				selectionChanged = true
			end
		end
		
		if selectionChanged then
			state.selected = newSelected
			updateCallback()
		end
	end
	
	-- Method to manually trigger the UpdateFunction
	function controller:Refresh()
		if state.updateFunction then
			self:Update(state.updateFunction())
			return true
		end
		return false
	end
	
	-- Method to get current options
	function controller:GetOptions()
		return state.options
	end
	
	-- Method to get current selections
	function controller:GetSelections()
		return state.selected
	end

	return controller
end

	function Options:AddSlider(Settings: { Title: string, Description: string, MaxValue: number, AllowDecimals: boolean, DecimalAmount: number, Tab: Instance, Callback: any }) 
		local Slider = Clone(Components["Slider"]);
		local Title, Description = Options:GetLabels(Slider);

		local Main = Slider["Slider"];
		local Amount = Main["Main"].Input;
		local Slide = Main["Slide"];
		local Fire = Slide["Fire"];
		local Fill = Slide["Highlight"];
		local Circle = Fill["Circle"];

		local Active = false
		local Value = 0
		
		local SetNumber = function(Number)
			if Settings.AllowDecimals then
				local Power = 10 ^ (Settings.DecimalAmount or 2)
				Number = math.floor(Number * Power + 0.5) / Power
			else
				Number = math.round(Number)
			end
			
			return Number
		end

		local Update = function(Number)
			local Scale = (Player.Mouse.X - Slide.AbsolutePosition.X) / Slide.AbsoluteSize.X			
			Scale = (Scale > 1 and 1) or (Scale < 0 and 0) or Scale
			
			if Number then
				Number = (Number > Settings.MaxValue and Settings.MaxValue) or (Number < 0 and 0) or Number
			end
			
			Value = SetNumber(Number or (Scale * Settings.MaxValue))
			Amount.Text = Value
			Fill.Size = UDim2.fromScale((Number and Number / Settings.MaxValue) or Scale, 1)
			Settings.Callback(Value)
		end

		local Activate = function()
			Active = true

			repeat task.wait()
				Update()
			until not Active
		end
		
		Connect(Amount.FocusLost, function() 
			Update(tonumber(Amount.Text) or 0)
		end)

		Connect(Fire.MouseButton1Down, Activate)
		Connect(Services.Input.InputEnded, function(Input) 
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Active = false
			end
		end)

		Fill.Size = UDim2.fromScale(Value, 1);
		Animations:Component(Slider);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Slider, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddParagraph(Settings: { Title: string, Description: string, Tab: Instance, UpdateFunction: any? })
    local Paragraph = Clone(Components["Paragraph"])
    local TitleLabel, DescriptionLabel = Options:GetLabels(Paragraph)

    -- Initial setup
    SetProperty(TitleLabel, { Text = Settings.Title or "Paragraph" })
    SetProperty(DescriptionLabel, { Text = Settings.Description or "" })
    SetProperty(Paragraph, {
        Parent = Settings.Tab,
        Visible = true,
    })

    -- Auto-update if UpdateFunction exists
    if Settings.UpdateFunction then
        task.spawn(function()
            while Paragraph.Parent do
                local newData = Settings.UpdateFunction()
                if newData and type(newData) == "table" then
                    if newData.Title then
                        TitleLabel.Text = newData.Title
                    end
                    if newData.Description then
                        DescriptionLabel.Text = newData.Description
                    end
                end
                task.wait(1) -- update every second
            end
        end)
    end

    return Paragraph
end
            

	local Themes = {
		Names = {	
			["Paragraph"] = function(Label)
				if Label:IsA("TextButton") then
					Label.BackgroundColor3 = Color(Theme.Component, 5, "Dark");
				end
			end,
			
			["Title"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Description"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Description
				end
			end,
			
			["Section"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Options"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
				end
			end,
			
			["Notification"] = function(Label)
				if Label:IsA("CanvasGroup") then
					Label.BackgroundColor3 = Theme.Primary
					Label.UIStroke.Color = Theme.Outline
				end
			end,

			["TextLabel"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent:FindFirstChild("List") then
					Label.TextColor3 = Theme.Tab
				end
			end,

			["Main"] = function(Label)
				if Label:IsA("Frame") then

					if Label.Parent == Window then
						Label.BackgroundColor3 = Theme.Secondary
					elseif Label.Parent:FindFirstChild("Value") then
						local Toggle = Label.Parent.Value 
						local Circle = Label:FindFirstChild("Circle")
						
						if not Toggle.Value then
							Label.BackgroundColor3 = Theme.Interactables
							Label.Circle.BackgroundColor3 = Theme.Primary
						end
					else
						Label.BackgroundColor3 = Theme.Interactables
					end
				elseif Label:FindFirstChild("Padding") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Amount"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Interactables
				end
			end,

			["Slide"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Interactables
				end
			end,

			["Input"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				elseif Label:FindFirstChild("Labels") then
					Label.BackgroundColor3 = Theme.Component
				elseif Label:IsA("TextBox") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Outline"] = function(Stroke)
				if Stroke:IsA("UIStroke") then
					Stroke.Color = Theme.Outline
				end
			end,

			["DropdownExample"] = function(Label)
				Label.BackgroundColor3 = Theme.Secondary
			end,

			["Underline"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Outline
				end
			end,
		},

		Classes = {
			["ImageLabel"] = function(Label)
				if Label.Image ~= "rbxassetid://6644618143" then
					Label.ImageColor3 = Theme.Icon
				end
			end,

			["TextLabel"] = function(Label)
				if Label:FindFirstChild("Padding") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["TextButton"] = function(Label)
				if Label:FindFirstChild("Labels") then
					Label.BackgroundColor3 = Theme.Component
				end
			end,

			["ScrollingFrame"] = function(Label)
				Label.ScrollBarImageColor3 = Theme.Component
			end,
		},
	}

	function Options:SetTheme(Info)
		Theme = Info or Theme

		Window.BackgroundColor3 = Theme.Primary
		Holder.BackgroundColor3 = Theme.Secondary
		Window.UIStroke.Color = Theme.Shadow

		for Index, Descendant in next, Screen:GetDescendants() do
			local Name, Class =  Themes.Names[Descendant.Name],  Themes.Classes[Descendant.ClassName]

			if Name then
				Name(Descendant);
			elseif Class then
				Class(Descendant);
			end
		end
	end

	--// Changing Settings

	function Options:SetSetting(Setting, Value) --// Available settings - Size, Transparency, Blur, Theme
		if Setting == "Size" then
			
			Window.Size = Value
			Setup.Size = Value
			
		elseif Setting == "Transparency" then
			
			Window.GroupTransparency = Value
			Setup.Transparency = Value
			
			for Index, Notification in next, Screen:GetDescendants() do
				if Notification:IsA("CanvasGroup") and Notification.Name == "Notification" then
					Notification.GroupTransparency = Value
				end
			end
			
		elseif Setting == "Blur" then
			
			local AlreadyBlurred, Root = Blurs[Settings.Title], nil
			
			if AlreadyBlurred then
				Root = Blurs[Settings.Title]["root"]
			end
			
			if Value then
				BlurEnabled = true

				if not AlreadyBlurred or not Root then
					Blurs[Settings.Title] = Blur.new(Window, 5)
				elseif Root and not Root.Parent then
					Root.Parent = workspace.CurrentCamera
				end
			elseif not Value and (AlreadyBlurred and Root and Root.Parent) then
				Root.Parent = nil
				BlurEnabled = false
			end
			
		elseif Setting == "Theme" and typeof(Value) == "table" then
			
			Options:SetTheme(Value)
			
		elseif Setting == "Keybind" then
			
			Setup.Keybind = Value
			
		else
			warn("Tried to change a setting that doesn't exist or isn't available to change.")
		end
	end

	SetProperty(Window, { Size = Settings.Size, Visible = true, Parent = Screen });
	Animations:Open(Window, Settings.Transparency or 0)

	return Options
end


return Library
