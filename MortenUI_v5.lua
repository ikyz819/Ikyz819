local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = game:GetService("Players").LocalPlayer
local getcustomasset = getcustomasset or getsynasset
local httpget = game.HttpGet or (syn and syn.request)

local function LoadCustomAsset(pathOrUrl)
    -- If already rbx asset, return directly
    if typeof(pathOrUrl) == "string" and pathOrUrl:find("rbxassetid://") then
        return pathOrUrl
    end

    -- If it's already a local file
    if isfile and isfile(pathOrUrl) then
        return getcustomasset(pathOrUrl)
    end

    -- If it's a URL, download it
    if typeof(pathOrUrl) == "string" and pathOrUrl:match("^https?://") then
        local fileName = "MortenUI_" .. tostring(math.random(1000,9999)) .. ".png"

        if writefile and game.HttpGet then
            local success, data = pcall(function()
                return game:HttpGet(pathOrUrl)
            end)

            if success and data then
                writefile(fileName, data)
                return getcustomasset(fileName)
            end
        end
    end

    -- Fallback (prevents crash)
    return "rbxassetid://7072719338"
end

local function Create(class, props, children)
	local obj = Instance.new(class)
	for k,v in pairs(props or {}) do obj[k] = v end
	for _,c in pairs(children or {}) do c.Parent = obj end
	return obj
end

local Library = {}
Library.__index = Library
Library.ToggleKey = Enum.KeyCode.RightShift

function Library.SettingManager()
	local Manager = {}
	function Manager:AddToTab(tab)
		tab:Paragraph({
			Title = "UI Settings",
			Content = "Manage the interface settings and keybindings here."
		})

		tab:Keybind({
			Name = "UI Toggle Key",
			Default = Library.ToggleKey,
			OnChange = function(New)
				Library.ToggleKey = New
			end
		})

		tab:Button({
			Name = "Unload UI",
			Callback = function()
				local core = gethui() or Player:WaitForChild("PlayerGui")
				local gui = core:FindFirstChild("DcusHub_v2.3 UI") or Player.PlayerGui:FindFirstChild("DcusHub_v2.3 UI")
				if gui then gui:Destroy() end
			end
		})
	end
	return Manager
end

function Library:New(config)
	local self = setmetatable({}, Library)

	self.Gui = Create("ScreenGui", {
		Name = "DcusHub_v2.3 UI",
		ResetOnSpawn = false,
		Parent = gethui()
	})

	self.Main = Create("Frame", {
		Size = UDim2.fromOffset(550, 320),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(15, 15, 20),
		BorderSizePixel = 0,
		Parent = self.Gui
	}, {
		Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
		Create("UIStroke", {Color = Color3.fromRGB(45, 45, 60), Thickness = 1.5})
	})

	self.Top = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 55),
		BackgroundColor3 = Color3.fromRGB(20, 20, 28),
		Parent = self.Main
	}, {
		Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
		Create("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, -1),
			BackgroundColor3 = Color3.fromRGB(45, 45, 60),
			BorderSizePixel = 0,
		})
	})
    
	-- Icon beside the title
	local IconFrame = Create("Frame", {
		Size = UDim2.fromOffset(32, 32),
		Position = UDim2.fromOffset(14, 11),
		BackgroundColor3 = Color3.fromRGB(80, 150, 255),
		BackgroundTransparency = 0.85,
		Parent = self.Top
	}, {
		Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
		Create("UIStroke", {Color = Color3.fromRGB(80, 150, 255), Thickness = 1, Transparency = 0.5}),
		Create("ImageLabel", {
			Image = LoadCustomAsset(config.Icon),
			Size = UDim2.fromOffset(20, 20),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ImageColor3 = Color3.fromRGB(80, 150, 255),
		})
	})

	Create("TextLabel", {
		Text = config.Title or "Dcus Hub",
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = "Left",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(54, 8),
		Size = UDim2.new(0, 200, 0, 20),
		Parent = self.Top
	})

	Create("TextLabel", {
		Text = config.Footer or "Premium Interface • v2.3",
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = Color3.fromRGB(100, 100, 130),
		TextXAlignment = "Left",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 200, 0, 20),
		Position = UDim2.fromOffset(54, 28),
		Parent = self.Top
	})

	self.Container = Create("Frame", {
		Size = UDim2.new(1, 0, 1, -55),
		Position = UDim2.fromOffset(0, 55),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Visible = true,
		ZIndex = 1,
		Parent = self.Main
	})

	-- Minimize button in top bar
	local MinimizeBtn = Create("TextButton", {
		Text = "—",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = Color3.fromRGB(180, 180, 200),
		BackgroundColor3 = Color3.fromRGB(30, 30, 45),
		Size = UDim2.fromOffset(28, 28),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		ZIndex = 50,
		Parent = self.Top
	}, {
		Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
		Create("UIStroke", {Color = Color3.fromRGB(60, 60, 80), Thickness = 1})
	})

	-- Floating bubble: shown when UI is minimized, draggable on mobile
	local Bubble = Create("ImageButton", {
		Image = config.Icon, -- replace with your image id
		BackgroundColor3 = Color3.fromRGB(15, 15, 20),
		Size = UDim2.fromOffset(52, 52),
		Position = UDim2.new(0, 326, 0, -38),
		ZIndex = 200,
		Visible = false,
		Parent = self.Gui
	}, {
		Create("UICorner", {CornerRadius = UDim.new(0, 14)}),
	})

	-- Make bubble draggable (touch + mouse)
	do
		local dragging, dragStart, startPos
		local moved = false
		Bubble.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				moved = false
				dragStart = input.Position
				startPos = Bubble.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		UIS.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				if delta.Magnitude > 5 then moved = true end
				Bubble.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y
				)
			end
		end)
		Bubble.MouseButton1Click:Connect(function()
			if not moved then self:ToggleUI() end
		end)
	end

	self.Sidebar = Create("Frame", {
		Size = UDim2.new(0, 150, 1, -16),
		Position = UDim2.fromOffset(10, 8),
		BackgroundColor3 = Color3.fromRGB(20, 20, 28),
		Parent = self.Container
	}, {
		Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
		Create("UIStroke", {Color = Color3.fromRGB(45, 45, 60), Thickness = 1}),
	})

	self.TabHighlight = Create("Frame", {
		Size = UDim2.new(1, -16, 0, 34),
		Position = UDim2.fromOffset(8, 8),
		BackgroundColor3 = Color3.fromRGB(80, 150, 255),
		BackgroundTransparency = 0.9,
		Visible = false,
		ZIndex = 2,
		Parent = self.Sidebar
	}, {
		Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
		Create("UIStroke", {Color = Color3.fromRGB(80, 150, 255), Thickness = 1, Transparency = 0.6})
	})

	self.TabHolder = Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 3,
		Parent = self.Sidebar
	}, {
		Create("UIListLayout", {Padding = UDim.new(0, 5)}),
		Create("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})
	})

	self.Pages = Create("Frame", {
		Size = UDim2.new(1, -180, 1, -16),
		Position = UDim2.fromOffset(170, 8),
		BackgroundTransparency = 1,
		Parent = self.Container
	})

	do
		local dragging, dragInput, dragStart, startPos
		local function update(input)
			local delta = input.Position - dragStart
			self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end

		self.Top.InputBegan:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				dragging = true
				dragStart = input.Position
				startPos = self.Main.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		UIS.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				update(input)
			end
		end)
	end

	-- Built-in ToggleUI (WindUI-style slide animation)
	self.Open = true

	local KeyHint = Create("TextLabel", {
		Text = "[" .. Library.ToggleKey.Name .. "]",
		Font = Enum.Font.GothamMedium,
		TextSize = 10,
		TextColor3 = Color3.fromRGB(60, 60, 85),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -115, 0, 0),
		Size = UDim2.new(0, 65, 1, 0),
		TextXAlignment = "Center",
		Parent = self.Top
	})

	function self:ToggleUI()
		self.Open = not self.Open
		if self.Open then
			-- Restore: hide bubble, show main UI
			Bubble.Visible = false
			self.Main.Visible = true
			self.Main.Position = UDim2.new(0.5, 0, 0.42, 0)
			self.Main.Size = UDim2.fromOffset(500, 340)
			TweenService:Create(self.Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(550, 380)
			}):Play()
		else
			-- Minimize: slide out main UI, show bubble
			local hide = TweenService:Create(self.Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
				Position = UDim2.new(0.5, 0, 0.56, 0),
				Size = UDim2.fromOffset(440, 300)
			})
			hide:Play()
			hide.Completed:Connect(function()
				if not self.Open then
					self.Main.Visible = false
					Bubble.Visible = true
				end
			end)
		end
	end

	MinimizeBtn.MouseButton1Click:Connect(function()
		self:ToggleUI()
	end)

	UIS.InputBegan:Connect(function(input, gpe)
		if not gpe and input.KeyCode == Library.ToggleKey then
			self:ToggleUI()
			KeyHint.Text = "[" .. Library.ToggleKey.Name .. "]"
		end
	end)

	function Library:Notify(config)
		local title = config.Title or "Notification"
		local content = config.Content or "Notification Content"
		local duration = config.Time or 5
		local btn1 = config.Button1
		local btn2 = config.Button2
		local btnAreaH = (btn1 or btn2) and 36 or 0
		local NotifGui = gethui():FindFirstChild("DcusNotifications")
		if not NotifGui then
			NotifGui = Create("ScreenGui", {
				Name = "DcusNotifications",
				Parent = gethui(),
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			})
		end

		local Holder = NotifGui:FindFirstChild("NotifHolder")
		if not Holder then
			Holder = Create("Frame", {
				Name = "NotifHolder",
				Parent = NotifGui,
				Size = UDim2.new(0, 260, 1, -20),
				Position = UDim2.new(1, -270, 0, 10),
				BackgroundTransparency = 1
			}, {
				Create("UIListLayout", {
					VerticalAlignment = "Top",
					HorizontalAlignment = "Right",
					Padding = UDim.new(0, 10)
				})
			})
		end

		-- 通知本体の作成
		local Notif = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundColor3 = Color3.fromRGB(20, 20, 28),
			BackgroundTransparency = 1, 
			Parent = Holder
		}, {
			Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
			Create("UIStroke", {Color = Color3.fromRGB(80, 150, 255), Thickness = 1.2, Transparency = 1})
		})

		local TitleLabel = Create("TextLabel", {
			Text = title:upper(),
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = Color3.fromRGB(80, 150, 255),
			BackgroundTransparency = 1,
			TextTransparency = 1,
			Position = UDim2.fromOffset(12, 8),
			Size = UDim2.new(1, -24, 0, 15),
			TextXAlignment = "Left",
			Parent = Notif
		})

		local Divider = Create("Frame", {
			Size = UDim2.new(1, -24, 0, 1),
			Position = UDim2.fromOffset(12, 26),
			BackgroundColor3 = Color3.fromRGB(45, 45, 60),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Parent = Notif
		})

		local ContentLabel = Create("TextLabel", {
			Text = content,
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextColor3 = Color3.fromRGB(180, 180, 200),
			BackgroundTransparency = 1,
			TextTransparency = 1,
			Position = UDim2.fromOffset(12, 32),
			Size = UDim2.new(1, -24, 0, 0),
			TextXAlignment = "Left",
			TextYAlignment = "Top",
			TextWrapped = true,
			Parent = Notif
		})

		local ts = game:GetService("TextService"):GetTextSize(content, 12, Enum.Font.GothamMedium, Vector2.new(236, 10000))
		local targetSizeY = ts.Y + 45 + btnAreaH
		Notif.Position = UDim2.new(1, 50, 0, 0)

		if btn1 or btn2 then
			local BtnRow = Create("Frame", {
				Size = UDim2.new(1, -24, 0, 26),
				Position = UDim2.new(0, 12, 1, -32),
				BackgroundTransparency = 1,
				Parent = Notif
			}, {
				Create("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 8),
					VerticalAlignment = Enum.VerticalAlignment.Center
				})
			})
			local function MakeBtn(cfg, primary)
				if not cfg then return end
				local B = Create("TextButton", {
					Text = cfg.Text or "OK",
					Font = Enum.Font.GothamBold,
					TextSize = 11,
					TextColor3 = primary and Color3.fromRGB(255,255,255) or Color3.fromRGB(180,180,200),
					BackgroundColor3 = primary and Color3.fromRGB(80,150,255) or Color3.fromRGB(35,35,50),
					Size = btn2 and UDim2.new(0.5, -4, 1, 0) or UDim2.new(1, 0, 1, 0),
					Parent = BtnRow
				}, {
					Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
					Create("UIStroke", {Color = primary and Color3.fromRGB(80,150,255) or Color3.fromRGB(55,55,70), Thickness = 1})
				})
				B.MouseButton1Click:Connect(function()
					if cfg.Callback then cfg.Callback() end
					Notif:Destroy()
				end)
			end
			MakeBtn(btn1, true)
			MakeBtn(btn2, false)
		end

		local showTween = TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0,
			Size = UDim2.new(1, 0, 0, targetSizeY)
		})

		TweenService:Create(Notif.UIStroke, TweenInfo.new(0.5), {Transparency = 0}):Play()
		TweenService:Create(TitleLabel, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
		TweenService:Create(Divider, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
		TweenService:Create(ContentLabel, TweenInfo.new(0.5), {TextTransparency = 0}):Play()

		showTween:Play()
		task.delay(duration, function()
			local hideTween = TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0) 
			})

			TweenService:Create(Notif.UIStroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
			TweenService:Create(TitleLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
			TweenService:Create(Divider, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
			TweenService:Create(ContentLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()

			hideTween:Play()
			hideTween.Completed:Connect(function()
				Notif:Destroy()
			end)
		end)
	end

	function self:NewTab(name)
		local Tab = {}

		local TabBg = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = Color3.fromRGB(25, 25, 35),
			Parent = self.TabHolder
		}, {
			Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
			Create("UIStroke", {Color = Color3.fromRGB(45, 45, 60), Thickness = 1})
		})

		local Dot = Create("Frame", {
			Size = UDim2.fromOffset(4, 4),
			Position = UDim2.new(0, 10, 0.5, -2),
			BackgroundColor3 = Color3.fromRGB(150, 150, 170),
			Parent = TabBg
		}, { Create("UICorner", {CornerRadius = UDim.new(1, 0)}) })

		local TabBtn = Create("TextButton", {
			Text = name,
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			TextColor3 = Color3.fromRGB(150, 150, 170),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Parent = TabBg
		})

		local Page = Create("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Visible = false,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Color3.fromRGB(80, 150, 255),
			CanvasSize = UDim2.new(0, 0, 0, 0), 
			Parent = self.Pages
		}, {
			Create("UIListLayout", {
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder 
			}),
			Create("UIPadding", {
				PaddingTop = UDim.new(0, 2), 
				PaddingLeft = UDim.new(0, 2), 
				PaddingRight = UDim.new(0, 8)
			})
		})

		local UIListLayout = Page:FindFirstChildOfClass("UIListLayout")

		local function UpdateCanvasSize()
			Page.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 15)
		end
		UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)
		task.spawn(UpdateCanvasSize)

		TabBtn.MouseButton1Click:Connect(function()
			self.TabHighlight.Visible = true
			local yPos = TabBg.AbsolutePosition.Y - self.Sidebar.AbsolutePosition.Y
			TweenService:Create(self.TabHighlight, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(8, yPos)
			}):Play()

			for _, p in pairs(self.Pages:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
			for _, bg in pairs(self.TabHolder:GetChildren()) do
				if bg:IsA("Frame") and bg:FindFirstChild("Frame") then
					TweenService:Create(bg:FindFirstChildOfClass("TextButton"), TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 170)}):Play()
					TweenService:Create(bg:FindFirstChild("Frame"), TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(150, 150, 170)}):Play()
				end
			end
			Page.Visible = true
			TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			TweenService:Create(Dot, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 150, 255)}):Play()
		end)

		function Tab:Button(config)
			local text = config.Name or config.Text or "Button"
			local callback = config.Callback or function() end

			local BtnBg = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 45),
				BackgroundColor3 = Color3.fromRGB(22, 22, 30),
				Parent = Page
			}, {
				Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
				Create("UIStroke", {Color = Color3.fromRGB(45, 45, 60), Thickness = 1})
			})

			Create("TextLabel", {
				Text = text,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				TextColor3 = Color3.fromRGB(200, 200, 220),
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(15, 0),
				Size = UDim2.new(1, -100, 1, 0),
				TextXAlignment = "Left",
				Parent = BtnBg
			})

			local RunBadge = Create("Frame", {
				Size = UDim2.fromOffset(45, 22),
				Position = UDim2.new(1, -55, 0.5, -11),
				BackgroundColor3 = Color3.fromRGB(40, 40, 55),
				Parent = BtnBg
			}, {
				Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
				Create("UIStroke", {Color = Color3.fromRGB(60, 60, 80), Thickness = 1}),
				Create("TextLabel", {
					Text = "Run",
					Font = Enum.Font.GothamBold,
					TextSize = 11,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Parent = nil
				})
			})
			RunBadge:FindFirstChild("TextLabel").Parent = RunBadge

			-- Optional keybind badge shown left of Run badge
			local keybind = config.Keybind
			if keybind then
				local KeyBadge = Create("Frame", {
					Size = UDim2.fromOffset(36, 22),
					Position = UDim2.new(1, -97, 0.5, -11),
					BackgroundColor3 = Color3.fromRGB(30, 30, 45),
					Parent = BtnBg
				}, {
					Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
					Create("UIStroke", {Color = Color3.fromRGB(80, 150, 255), Thickness = 1, Transparency = 0.5}),
					Create("TextLabel", {
						Text = keybind.Name or "?",
						Font = Enum.Font.GothamBold,
						TextSize = 10,
						TextColor3 = Color3.fromRGB(80, 150, 255),
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
						Parent = nil
					})
				})
				KeyBadge:FindFirstChild("TextLabel").Parent = KeyBadge

				UIS.InputBegan:Connect(function(input, gpe)
					if not gpe and input.KeyCode == keybind then
						TweenService:Create(BtnBg, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(28, 32, 50)}):Play()
						TweenService:Create(RunBadge, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(80, 150, 255)}):Play()
						task.delay(0.15, function()
							TweenService:Create(BtnBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 22, 30)}):Play()
							TweenService:Create(RunBadge, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
						end)
						callback()
					end
				end)
			end

			local Hit = Create("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = BtnBg})
			Hit.MouseButton1Down:Connect(function()
				TweenService:Create(BtnBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 32, 50)}):Play()
				TweenService:Create(RunBadge, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 150, 255)}):Play()
			end)
			Hit.MouseButton1Up:Connect(function()
				TweenService:Create(BtnBg, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(22, 22, 30)}):Play()
				TweenService:Create(RunBadge, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
				callback()
			end)
		end

		function Tab:Toggle(config)
			local text = config.Name or "Toggle"
			local callback = config.Callback or function() end
			local state = config.Default or false

			local TglBg = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 45),
				BackgroundColor3 = Color3.fromRGB(22, 22, 30),
				Parent = Page
			}, {
				Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
				Create("UIStroke", {Color = Color3.fromRGB(45, 45, 60), Thickness = 1})
			})

			Create("TextLabel", {
				Text = text,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				TextColor3 = Color3.fromRGB(200, 200, 220),
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(15, 0),
				Size = UDim2.new(1, -70, 1, 0),
				TextXAlignment = "Left",
				Parent = TglBg
			})

			local Switch = Create("Frame", {
				Size = UDim2.fromOffset(40, 20),
				Position = UDim2.new(1, -50, 0.5, -10),
				BackgroundColor3 = state and Color3.fromRGB(80, 150, 255) or Color3.fromRGB(40, 40, 55),
				Parent = TglBg
			}, {
				Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
				Create("UIStroke", {Color = Color3.fromRGB(60, 60, 80), Thickness = 1})
			})

			local Knob = Create("Frame", {
				Size = UDim2.fromOffset(16, 16),
				Position = state and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Parent = Switch
			}, { Create("UICorner", {CornerRadius = UDim.new(1, 0)}) })

			local function updateView(val)
				TweenService:Create(Switch, TweenInfo.new(0.2), {
					BackgroundColor3 = val and Color3.fromRGB(80, 150, 255) or Color3.fromRGB(40, 40, 55)
				}):Play()
				TweenService:Create(Knob, TweenInfo.new(0.2), {
					Position = val and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2)
				}):Play()
			end

			-- Optional keybind badge shown left of the switch
			local keybind = config.Keybind
			if keybind then
				local KeyBadge = Create("Frame", {
					Size = UDim2.fromOffset(36, 22),
					Position = UDim2.new(1, -97, 0.5, -11),
					BackgroundColor3 = Color3.fromRGB(30, 30, 45),
					Parent = TglBg
				}, {
					Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
					Create("UIStroke", {Color = Color3.fromRGB(80, 150, 255), Thickness = 1, Transparency = 0.5}),
					Create("TextLabel", {
						Text = keybind.Name or "?",
						Font = Enum.Font.GothamBold,
						TextSize = 10,
						TextColor3 = Color3.fromRGB(80, 150, 255),
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
						Parent = nil
					})
				})
				KeyBadge:FindFirstChild("TextLabel").Parent = KeyBadge

				UIS.InputBegan:Connect(function(input, gpe)
					if not gpe and input.KeyCode == keybind then
						state = not state
						updateView(state)
						callback(state)
					end
				end)
			end

			local Hit = Create("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = TglBg})

			Hit.MouseButton1Click:Connect(function()
				state = not state
				updateView(state)
				callback(state)
			end)
			local ToggleFunctions = {}
			function ToggleFunctions:SetValue(val)
				state = val
				updateView(state)
				callback(state)
			end

			return ToggleFunctions
		end

		function Tab:Slider(config)
			local text = config.Name or "Slider"
			local min = config.Min or 0
			local max = config.Max or 100
			local default = config.Default or min
			local rounding = config.Rounding or 0
			local callback = config.Callback or function() end

			local SliderBg = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundColor3 = Color3.fromRGB(22, 22, 30),
				Parent = Page
			}, {
				Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
				Create("UIStroke", {Color = Color3.fromRGB(45, 45, 60), Thickness = 1})
			})

			local Label = Create("TextLabel", {
				Text = text,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				TextColor3 = Color3.fromRGB(200, 200, 220),
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(15, 8),
				Size = UDim2.new(1, -100, 0, 20),
				TextXAlignment = "Left",
				Parent = SliderBg
			})

			local ValueLabel = Create("TextLabel", {
				Text = tostring(default),
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextColor3 = Color3.fromRGB(80, 150, 255),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -65, 0, 8),
				Size = UDim2.new(0, 50, 0, 20),
				TextXAlignment = "Right",
				Parent = SliderBg
			})

			local Tray = Create("Frame", {
				Size = UDim2.new(1, -30, 0, 4),
				Position = UDim2.new(0, 15, 1, -12),
				BackgroundColor3 = Color3.fromRGB(40, 40, 55),
				Parent = SliderBg
			}, { Create("UICorner", {CornerRadius = UDim.new(1, 0)}) })

			local Fill = Create("Frame", {
				Size = UDim2.fromScale((default - min) / (max - min), 1),
				BackgroundColor3 = Color3.fromRGB(80, 150, 255),
				Parent = Tray
			}, { Create("UICorner", {CornerRadius = UDim.new(1, 0)}) })

			local Knob = Create("Frame", {
				Size = UDim2.fromOffset(8, 8),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale((default - min) / (max - min), 0.5),
				BackgroundColor3 = Color3.fromRGB(22, 22, 30),
				Parent = Tray
			}, { 
				Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
				Create("UIStroke", {Color = Color3.fromRGB(80, 150, 255), Thickness = 1.5})
			})

			local function Update(input)
				local pos = math.clamp((input.Position.X - Tray.AbsolutePosition.X) / Tray.AbsoluteSize.X, 0, 1)
				local rawVal = min + (max - min) * pos
				local val = rounding == 1 and (math.floor(rawVal * 10) / 10) or math.floor(rawVal)

				ValueLabel.Text = tostring(val)
				TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.fromScale(pos, 1)}):Play()
				TweenService:Create(Knob, TweenInfo.new(0.1), {Position = UDim2.fromScale(pos, 0.5)}):Play()
				callback(val)
			end

			local dragging = false
			SliderBg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; Update(i) end end)
			UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
			UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
		end

		function Tab:Dropdown(config)
			local text = config.Name or "Dropdown"
			local list = config.List or {}
			local default = config.Default
			local callback = config.Callback or function() end
			local multi = config.Multi or false

			local expanded = false
			local selected = {}

			local DropdownBg = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 45),
				BackgroundColor3 = Color3.fromRGB(22, 22, 30),
				ClipsDescendants = true,
				Parent = Page
			}, {
				Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
				Create("UIStroke", {Color = Color3.fromRGB(45, 45, 60), Thickness = 1})
			})

			local Header = Create("TextButton", {
				Size = UDim2.new(1, 0, 0, 45),
				BackgroundTransparency = 1,
				Text = "",
				Parent = DropdownBg
			})

			local TitleLabel = Create("TextLabel", {
				Text = text,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				TextColor3 = Color3.fromRGB(200, 200, 220),
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(15, 0),
				Size = UDim2.new(1, -50, 1, 0),
				TextXAlignment = "Left",
				Parent = Header
			})

			-- MULTI badge
			if multi then
				local MB = Create("Frame", {
					Size = UDim2.fromOffset(34, 16),
					Position = UDim2.new(1, -65, 0.5, -8),
					BackgroundColor3 = Color3.fromRGB(80, 150, 255),
					BackgroundTransparency = 0.8,
					Parent = Header
				}, { Create("UICorner", {CornerRadius = UDim.new(0, 4)}) })
				Create("TextLabel", {
					Text = "MULTI",
					Font = Enum.Font.GothamBold,
					TextSize = 9,
					TextColor3 = Color3.fromRGB(80, 150, 255),
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Parent = MB
				})
			end

			local Arrow = Create("TextLabel", {
				Text = "▼",
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextColor3 = Color3.fromRGB(100, 100, 130),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -35, 0, 0),
				Size = UDim2.new(0, 25, 1, 0),
				Parent = Header
			})

			local Content = Create("Frame", {
				Size = UDim2.new(1, -20, 0, #list * 32),
				Position = UDim2.fromOffset(10, 45),
				BackgroundTransparency = 1,
				Parent = DropdownBg
			})

			local DropHighlight = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = Color3.fromRGB(80, 150, 255),
				BackgroundTransparency = 0.85,
				Visible = false,
				ZIndex = 1,
				Parent = Content
			}, {
				Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
				Create("UIStroke", {Color = Color3.fromRGB(80, 150, 255), Thickness = 1, Transparency = 0.5})
			})

			local OptionHolder = Create("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				ZIndex = 2,
				Parent = Content
			})

			Create("UIListLayout", {
				Padding = UDim.new(0, 2),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = OptionHolder
			})

			local function UpdateTitle()
				local count = 0
				for _ in pairs(selected) do count = count + 1 end
				TitleLabel.Text = count > 0 and (text .. " (" .. count .. " selected)") or text
			end

			local function Select(v, btn)
				if multi then
					if selected[v] then
						selected[v] = nil
						TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 170)}):Play()
						local chk = btn:FindFirstChild("CheckMark")
						if chk then TweenService:Create(chk, TweenInfo.new(0.15), {TextTransparency = 1}):Play() end
					else
						selected[v] = true
						TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(80, 150, 255)}):Play()
						local chk = btn:FindFirstChild("CheckMark")
						if chk then TweenService:Create(chk, TweenInfo.new(0.15), {TextTransparency = 0}):Play() end
					end
					UpdateTitle()
					local result = {}
					for k in pairs(selected) do table.insert(result, k) end
					callback(result)
				else
					DropHighlight.Visible = true
					local targetY = btn.AbsolutePosition.Y - Content.AbsolutePosition.Y
					TweenService:Create(DropHighlight, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Position = UDim2.fromOffset(0, targetY)
					}):Play()
					for _, o in pairs(OptionHolder:GetChildren()) do
						if o:IsA("TextButton") then
							TweenService:Create(o, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 170)}):Play()
						end
					end
					TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
					TitleLabel.Text = text .. " : " .. v
					callback(v)
				end
			end

			for i, v in pairs(list) do
				local Opt = Create("TextButton", {
					Text = multi and ("  " .. v) or v,
					Font = Enum.Font.GothamMedium,
					TextSize = 13,
					TextColor3 = Color3.fromRGB(150, 150, 170),
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = i,
					Parent = OptionHolder
				})
				if multi then
					Create("TextLabel", {
						Name = "CheckMark",
						Text = "✓",
						Font = Enum.Font.GothamBold,
						TextSize = 12,
						TextColor3 = Color3.fromRGB(80, 150, 255),
						TextTransparency = 1,
						BackgroundTransparency = 1,
						Position = UDim2.new(1, -20, 0, 0),
						Size = UDim2.new(0, 20, 1, 0),
						Parent = Opt
					})
				end
				Opt.MouseButton1Click:Connect(function() Select(v, Opt) end)
				if default then
					if multi and type(default) == "table" then
						for _, dv in pairs(default) do
							if dv == v then
								task.spawn(function()
									repeat task.wait() until Opt.AbsolutePosition.Y > 0
									Select(v, Opt)
								end)
							end
						end
					elseif not multi and v == default then
						task.spawn(function()
							repeat task.wait() until Opt.AbsolutePosition.Y > 0
							Select(v, Opt)
						end)
					end
				end
			end

			Header.MouseButton1Click:Connect(function()
				expanded = not expanded
				TweenService:Create(DropdownBg, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
					Size = UDim2.new(1, 0, 0, expanded and (45 + #list * 32 + 10) or 45)
				}):Play()
				TweenService:Create(Arrow, TweenInfo.new(0.4), {Rotation = expanded and 180 or 0}):Play()
			end)
		end
		function Tab:Label(config)
			local text = config.Text or "Label"

			local LabelBg = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = Color3.fromRGB(22, 22, 30),
				BackgroundTransparency = 0.5,
				Parent = Page
			}, {
				Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
				Create("UIStroke", {Color = Color3.fromRGB(45, 45, 60), Thickness = 1, Transparency = 0.5})
			})

			local Text = Create("TextLabel", {
				Text = text,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextColor3 = Color3.fromRGB(180, 180, 200),
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(15, 8),
				Size = UDim2.new(1, -30, 0, 0),
				TextXAlignment = "Left",
				TextYAlignment = "Center",
				TextWrapped = true,
				Parent = LabelBg
			})

			local function Resize()
				local ts = game:GetService("TextService"):GetTextSize(
					Text.Text, Text.TextSize, Text.Font, Vector2.new(Text.AbsoluteSize.X, 10000)
				)
				LabelBg.Size = UDim2.new(1, 0, 0, ts.Y + 16)
				Text.Size = UDim2.new(1, -30, 0, ts.Y)
			end

			Text:GetPropertyChangedSignal("AbsoluteSize"):Connect(Resize)
			task.spawn(Resize)
		end

		function Tab:Paragraph(config)
			local title = config.Title or "Paragraph Title"
			local content = config.Content or "Content description goes here."

			local SectionBg = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 65), 
				BackgroundColor3 = Color3.fromRGB(22, 22, 30),
				Parent = Page
			}, {
				Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
				Create("UIStroke", {Color = Color3.fromRGB(45, 45, 60), Thickness = 1})
			})

			local Title = Create("TextLabel", {
				Text = title:upper(),
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextColor3 = Color3.fromRGB(80, 150, 255),
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(15, 8),
				Size = UDim2.new(1, -30, 0, 20),
				TextXAlignment = "Left",
				Parent = SectionBg
			})

			local Divider = Create("Frame", {
				Size = UDim2.new(1, -30, 0, 1),
				Position = UDim2.fromOffset(15, 30),
				BackgroundColor3 = Color3.fromRGB(45, 45, 60),
				BorderSizePixel = 0,
				Parent = SectionBg
			})

			local Desc = Create("TextLabel", {
				Text = content,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextColor3 = Color3.fromRGB(150, 150, 170),
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(15, 38),
				Size = UDim2.new(1, -30, 0, 0),
				TextXAlignment = "Left",
				TextYAlignment = "Top",
				TextWrapped = true,
				Parent = SectionBg
			})

			local function Resize()
				local ts = game:GetService("TextService"):GetTextSize(
					Desc.Text, Desc.TextSize, Desc.Font, Vector2.new(Desc.AbsoluteSize.X, 10000)
				)
				SectionBg.Size = UDim2.new(1, 0, 0, ts.Y + 50)
				Desc.Size = UDim2.new(1, -30, 0, ts.Y)
			end

			Desc:GetPropertyChangedSignal("AbsoluteSize"):Connect(Resize)
			task.spawn(Resize)
		end

		function Tab:Keybind(config)
			local text = config.Name or "Keybind"
			local default = config.Default or Enum.KeyCode.E
			local callback = config.Callback or function() end
			local onChange = config.OnChange or function() end
			local listening = false

			local BindBg = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = Color3.fromRGB(22, 22, 30),
				Parent = Page
			}, {
				Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
				Create("UIStroke", {Color = Color3.fromRGB(45, 45, 60), Thickness = 1})
			})

			local Label = Create("TextLabel", {
				Text = text,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextColor3 = Color3.fromRGB(200, 200, 220),
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(15, 0),
				Size = UDim2.new(1, -85, 1, 0),
				TextXAlignment = "Left",
				Parent = BindBg
			})

			local BindDisplay = Create("Frame", {
				Size = UDim2.fromOffset(60, 24),
				Position = UDim2.new(1, -75, 0.5, -12),
				BackgroundColor3 = Color3.fromRGB(30, 30, 40),
				Parent = BindBg
			}, {
				Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
				Create("UIStroke", {Color = Color3.fromRGB(60, 60, 80), Thickness = 1})
			})

			local BindText = Create("TextLabel", {
				Text = default.Name,
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Parent = BindDisplay
			})

			local Hit = Create("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = BindBg})

			Hit.MouseButton1Click:Connect(function()
				listening = true
				BindText.Text = "..."
				TweenService:Create(BindDisplay:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.2), {Color = Color3.fromRGB(80, 150, 255)}):Play()
			end)

			UIS.InputBegan:Connect(function(input, gpe)
				if gpe then return end
				if listening and input.UserInputType == Enum.UserInputType.Keyboard then
					listening = false
					default = input.KeyCode
					BindText.Text = input.KeyCode.Name
					TweenService:Create(BindDisplay:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.2), {Color = Color3.fromRGB(60, 60, 80)}):Play()
					onChange(input.KeyCode) 
				elseif not listening and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == default then
					local t = TweenService:Create(BindDisplay, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(80, 150, 255)})
					t:Play()
					t.Completed:Connect(function()
						TweenService:Create(BindDisplay, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
					end)
					callback()
				end
			end)
		end

		function Tab:Textbox(config)
			local text = config.Name or "Textbox"
			local placeholder = config.Placeholder or "Enter..."
			local callback = config.Callback or function() end

			local BoxBg = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = Color3.fromRGB(22, 22, 30),
				Parent = Page
			}, {
				Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
				Create("UIStroke", {Color = Color3.fromRGB(45, 45, 60), Thickness = 1})
			})

			local Label = Create("TextLabel", {
				Text = text,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextColor3 = Color3.fromRGB(200, 200, 220),
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(15, 0),
				Size = UDim2.new(1, -80, 1, 0), 
				TextXAlignment = "Left",
				Parent = BoxBg
			})

			local InputHolder = Create("Frame", {
				Size = UDim2.new(0, 60, 0, 26), 
				Position = UDim2.new(1, -75, 0.5, -13),
				BackgroundColor3 = Color3.fromRGB(15, 15, 20),
				ClipsDescendants = true,
				Parent = BoxBg
			}, {
				Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
				Create("UIStroke", {Color = Color3.fromRGB(50, 50, 70), Thickness = 1})
			})

			local Input = Create("TextBox", {
				Text = "",
				PlaceholderText = placeholder,
				Font = Enum.Font.GothamMedium,
				TextSize = 11,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -10, 1, 0),
				Position = UDim2.fromOffset(5, 0),
				TextXAlignment = "Center",
				Parent = InputHolder
			})

			Input.Focused:Connect(function()
				TweenService:Create(InputHolder, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, 180, 0, 26), 
					Position = UDim2.new(1, -195, 0.5, -13)
				}):Play()
				TweenService:Create(InputHolder:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.4), {Color = Color3.fromRGB(80, 150, 255)}):Play()
				TweenService:Create(Label, TweenInfo.new(0.4), {TextTransparency = 0.5}):Play()
			end)

			Input.FocusLost:Connect(function(enterPressed)
				TweenService:Create(InputHolder, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, 60, 0, 26),
					Position = UDim2.new(1, -75, 0.5, -13)
				}):Play()
				TweenService:Create(InputHolder:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.4), {Color = Color3.fromRGB(50, 50, 70)}):Play()
				TweenService:Create(Label, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
				callback(Input.Text, enterPressed)
			end)
		end

		return Tab
	end

	return self
end

return Library
