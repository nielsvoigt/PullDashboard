-- Title: Pull Dashboard
-- Author: Niels Voigt
-- Date: 31.01.2020
-- Description: 
-- Copyright:  Niels Voigt
-- Licensing: ?

PullDashboard = PullDashboard or {};

PullDashboardPerCharDB = PullDashboardPerCharDB or {
    Frame_myPoint = "CENTER",
    Frame_myRelativePoint = "CENTER",
    Frame_myXOfs = -50,
    Frame_myYOfs = -50
};

PullDashboard.frame = CreateFrame("Frame", nil, UIParent);
PullDashboard.frame:SetFrameStrata("BACKGROUND");

PullDashboard.frame:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, ...) end end);

PullDashboard.frame:RegisterEvent("ADDON_LOADED");
PullDashboard.frame:RegisterEvent("PLAYER_ENTERING_WORLD");

local Debug = function  (str, ...)
	if ... then str = str:format(...) end
	DEFAULT_CHAT_FRAME:AddMessage(("PullDashboard Debut Output: %s"):format(str));
end

-- ----------------------------------------------------------------------------------

function PullDashboard.frame:OnDragStart (button)
	self:StartMoving();
end

function PullDashboard.frame:OnDragStop ()
	self:StopMovingOrSizing();

	-- Save this location in our saved variables for the next time this character is played.
	local myPoint, myRelativeTo, myRelativePoint, myXOfs, myYOfs = self:GetPoint();
	PullDashboardPerCharDB.Frame_myPoint = myPoint;
	PullDashboardPerCharDB.Frame_myRelativeTo = myRelativeTo;
	PullDashboardPerCharDB.Frame_myRelativePoint = myRelativePoint;
	PullDashboardPerCharDB.Frame_myXOfs = myXOfs;
	PullDashboardPerCharDB.Frame_myYOfs = myYOfs ;
end

-- Following functions are used to register for particular events.
-- The name of the function is the event which it is to handle.
function PullDashboard.frame:ADDON_LOADED(addon)
	Debug ("ADDON_LOADED");

	self:UnregisterEvent("ADDON_LOADED");
	self.ADDON_LOADED = nil;

	if IsLoggedIn() then
		self:PLAYER_LOGIN(true);
	else
		self:RegisterEvent("PLAYER_LOGIN");
	end
end

function PullDashboard.frame:PLAYER_LOGIN(delayed)
	Debug ("PLAYER_LOGIN");
	self:UnregisterEvent("PLAYER_LOGIN");
	self.PLAYER_LOGIN = nil;
end

function PullDashboard.frame:PLAYER_ENTERING_WORLD(delayed)

	-- player has entered the world so we are no longer interested in this event
	Debug ("PLAYER_ENTERING_WORLD");
	self:UnregisterEvent("PLAYER_ENTERING_WORLD");
	self.PLAYER_ENTERING_WORLD = nil;

	-- adjust our main frame so we position it to the last place the player moved it to
	-- and so that we can move it along with the status bars when requested.
	self:SetHeight(10);
	self:SetWidth(100);
	self.texture = self:CreateTexture(nil,"BACKGROUND");
	self.texture:SetAllPoints(self);
	self.texture:SetTexture(.15, .15, .15, .5);
	self.labelText = self:CreateFontString(nil,"ARTWORK","GameFontNormal");
	self.labelText:SetPoint("TOP",self,"TOP");
	self.labelText:SetText("Heiler Mana");

	self:SetPoint(PullDashboardPerCharDB.Frame_myPoint, UIParent, PullDashboardPerCharDB.Frame_myRelativePoint, PullDashboardPerCharDB.Frame_myXOfs, PullDashboardPerCharDB.Frame_myYOfs);

	-- enable the frame to be moveable using the left mouse button.
	-- then set the scripts or functions to be triggered when movement starts and ends.
	self:SetMovable(true);
	self:EnableMouse(true)
	self:RegisterForDrag("LeftButton");
	self:SetScript("OnDragStart", self.OnDragStart);
	self:SetScript("OnDragStop", self.OnDragStop);
	self:Show();
	
	 	 self.manabar = CreateFrame("StatusBar", nil, self);

	-- check to see if the optional offsets have been specified
	if (xOffset == nil) then xOffset = 0; end
	if (yOffset == nil) then yOffset = -5; end

	self.manabar:SetPoint("TOP", self, "BOTTOM", xOffset, yOffset);
	self.manabar:SetHeight(20);
	self.manabar:SetWidth(100);
	self.manabar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
	self.manabar:GetStatusBarTexture():SetHorizTile(true)
	self.manabar:GetStatusBarTexture():SetVertTile(true)

	self.manabar.border = CreateFrame("Frame", nil, self.manabar)
	self.manabar.border:SetPoint("TOPLEFT", self.manabar, "TOPLEFT", -2, 2)
	self.manabar.border:SetPoint("BOTTOMRIGHT", self.manabar, "BOTTOMRIGHT", 2, -2)
	self.manabar.border:SetBackdrop({
		                   bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
                           edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
                           tile = true, tileSize = 32, edgeSize = 8, 
                           insets = { left = -2, right = -2, top = -2, bottom = -2 }
                           });
	self.manabar.border:SetBackdropColor(0,0,0,0);
	self.manabar.border:SetFrameLevel(self.manabar:GetFrameLevel());

	self.manabar.bg = self.manabar:CreateTexture(nil,"BACKGROUND");
	self.manabar.bg:SetTexture(.65, .5, .5, .75);
	self.manabar.bg:SetAllPoints(true);

	self.manabar.text = self.manabar:CreateFontString(nil,"OVERLAY");
	self.manabar.text:SetFontObject("TextStatusBarText", 16, "OUTLINE");
	self.manabar.text:SetPoint("CENTER", self.manabar, "CENTER", 4, 0);
	self.manabar.text:SetJustifyH("CENTER");
	self.manabar.text:SetShadowOffset(1, -1);
	self.manabar.text:SetTextColor(1, 1, 1);
	self.manabar.text:SetText("100%");

	self.manabar:SetMinMaxValues(0,1);
	self.manabar:SetStatusBarColor(0.2, 0.2, 1);
	self.manabar:Show();
	
	self.pullText = self:CreateFontString(nil,"ARTWORK","GameFontNormal");
	self.pullText:SetPoint("TOP",self.manabar,"BOTTOM");
	self.pullText:SetFontObject("GameFontHighlightLarge", 128, "OUTLINE");
	self.pullText:SetJustifyH("CENTER");
	self.pullText:SetShadowOffset(1, -1);
	self.pullText:SetTextColor(0, 1, 0);
	-- self.pullText:SetSize(80,120);
	self.pullText:SetText("");
	self.pullText:SetTextHeight(40);
	self.pullText:Show();
    
    PullDashboard.raiders = {};

	self:RegisterEvent("UNIT_POWER_UPDATE");
	self:RegisterEvent("UNIT_FLAGS");
    self:RegisterEvent("UNIT_CONNECTION");
    self:RegisterEvent("ZONE_CHANGED");
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("ZONE_CHANGED_INDOORS");
end

function PullDashboard.frame:UNIT_POWER_UPDATE (...)
	-- Debug("UNIT_MANA")
    local unitId = select (1, ...);

    if UnitShouldBeMonitoredForMana(unitId) then
        -- check if id is healer
        local max = UnitPowerMax (unitId);
        local current = UnitPower(unitId);
		
		if PullDashboard.raiders[unitId] == nil then
			PullDashboard.raiders[unitId] = {}
		end
		PullDashboard.raiders[unitId].currentMana = current;
		PullDashboard.raiders[unitId].maximumMana = max;
		self:Recalculate();
    end
end

function PullDashboard.frame:UNIT_CONNECTION (...)
	local unitId = select (1, ...);

	if UnitShouldBeMonitoredForMana(unitId) then

		-- PullDashboard.raiders[unitId].currentMana = 0;
	end
end

function PullDashboard.frame:ZONE_CHANGED()
	self:UNIT_POWER_UPDATE("player");
end

function PullDashboard.frame:ZONE_CHANGED_NEW_AREA()
	self:ZONE_CHANGED();
end

function PullDashboard.frame:ZONE_CHANGED_INDOORS ()
	self:ZONE_CHANGED();
end

function PullDashboard.frame:Recalculate ()
	local maximumMana = 0.0;
	local currentMana = 0.0;
	local monitored = 0;

	for key, value in pairs(PullDashboard.raiders) do
		maximumMana = maximumMana + (value.maximumMana or 0);
		currentMana = currentMana + (value.currentMana or 0);
		monitored = monitored + 1;
	end

	local percent = math.ceil(currentMana * 100 / maximumMana);

	-- Debug("Recalculating: " .. currentMana .. "/" .. maximumMana .. " = " .. percent .. "%   (" .. monitored .. ")")

	self.manabar:SetMinMaxValues(0, maximumMana);
	self.manabar:SetValue(currentMana);
	self.manabar.text:SetText(percent .. '%');

	if percent > 40 then
		self.pullText:SetTextColor(0, 1, 0);
		self.pullText:SetText("PULL");
		return;
	end
	
	if percent > 20 then
		self.pullText:SetTextColor(1, 1, 0);
		self.pullText:SetText("WAIT");
		return;
	end

	self.pullText:SetTextColor(1, 0, 0);
	self.pullText:SetText("STOP");
end

function UnitShouldBeMonitoredForMana(unitId)
	-- Debug("Checking whether they should be monitored for mana: " .. unitId)
	if UnitInRaid(unitId) or UnitInParty(unitId) then
		local localizedClass, englishClass, classIndex = UnitClass(unitId);
		if englishClass == "PRIEST" or englishClass == "DRUID" or englishClass == "PALADIN" then
			return true;
		end
	end
	
	return false;
end

-- player joins raid
-- player leaves raid

-- http://wowprogramming.com/docs/api/UnitInRaid.html
-- http://wowprogramming.com/docs/api/GetPartyAssignment.html

