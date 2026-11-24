-- RaidTankMarker: show the raid target icon of the assigned tank alongside
-- the local player's group label on Blizzard's default PlayerFrame.

local addon = CreateFrame("Frame")
local marker
local groupIndicator
local testOverlay

local function FindGroupIndicator()
    if not PlayerFrame then
        return nil
    end

    local content = PlayerFrame.PlayerFrameContent
    local contextual = content and content.PlayerFrameContentContextual
    return (contextual and contextual.GroupIndicator)
        or _G.PlayerFrameGroupIndicator
end

local function EnsureMarker()
    local indicator = FindGroupIndicator()
    if not indicator then
        return false
    end

    if marker and indicator == groupIndicator then
        return true
    end

    groupIndicator = indicator

    if not marker then
        -- This is deliberately non-secure, visual-only UI. No raid markers
        -- are assigned or modified by the addon.
        marker = CreateFrame("Frame", nil, indicator)
        marker:SetSize(18, 18)
        marker.texture = marker:CreateTexture(nil, "OVERLAY")
        marker.texture:SetAllPoints()
        marker.texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    else
        marker:SetParent(indicator)
    end

    marker:ClearAllPoints()
    local label = indicator.Text or _G.PlayerFrameGroupIndicatorText
    if label then
        marker:SetPoint("LEFT", label, "RIGHT", 3, 0)
    else
        marker:SetPoint("LEFT", indicator, "RIGHT", 3, 0)
    end
    marker:Hide()
    return true
end

-- Independent visual-only group label for testing outside a raid.
-- Parent to UIParent, not the hidden Blizzard GroupIndicator.
local function EnsureTestOverlay()
    if not PlayerFrame then
        return false
    end

    if not testOverlay then
        testOverlay = CreateFrame("Frame", nil, UIParent)
        testOverlay:SetSize(110, 20)
        testOverlay:SetFrameStrata("HIGH")
        testOverlay.label = testOverlay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        testOverlay.label:SetPoint("LEFT", testOverlay, "LEFT", 0, 0)
        testOverlay.label:SetText("Gruppe 1")
        testOverlay.icon = testOverlay:CreateTexture(nil, "OVERLAY")
        testOverlay.icon:SetSize(18, 18)
        testOverlay.icon:SetPoint("LEFT", testOverlay.label, "RIGHT", 3, 0)
        testOverlay.icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    end

    testOverlay:ClearAllPoints()
    local indicator = FindGroupIndicator()
    local label = indicator and (indicator.Text or _G.PlayerFrameGroupIndicatorText)
    if label then
        -- Anchoring to a hidden region works; only parenting would hide us.
        testOverlay:SetPoint("LEFT", label, "LEFT", 0, 0)
    elseif indicator then
        testOverlay:SetPoint("CENTER", indicator, "CENTER", 0, 0)
    else
        -- Fallback when Blizzard has not built the group indicator yet.
        testOverlay:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 85, -8)
    end
    return true
end

local function HideTestOverlay()
    if testOverlay then
        testOverlay:Hide()
    end
end

local function GetTankMarker(subgroup)
    local foundTank
    local count = GetNumGroupMembers()

    for raidIndex = 1, count do
        local _, _, memberSubgroup, _, _, _, _, _, _, _, _, rosterRole = GetRaidRosterInfo(raidIndex)
        if memberSubgroup == subgroup then
            local unit = "raid" .. raidIndex
            local assignedRole = UnitGroupRolesAssigned(unit)
            if assignedRole == "TANK" or rosterRole == "TANK" then
                -- An ambiguous group (more than one tank) is ignored.
                if foundTank then
                    return nil, false
                end
                foundTank = unit
            end
        end
    end

    if not foundTank then
        return nil, false
    end

    return GetRaidTargetIndex(foundTank), true
end

local function Update()
    HideTestOverlay()
    if not EnsureMarker() then
        return
    end

    marker:Hide()

    if not IsInRaid() then
        return
    end

    local playerRaidIndex = UnitInRaid("player")
    if not playerRaidIndex then
        return
    end

    local _, _, playerSubgroup = GetRaidRosterInfo(playerRaidIndex)
    if type(playerSubgroup) ~= "number" or playerSubgroup < 1 or playerSubgroup > 8 then
        return
    end

    -- Both group 1 and group 2 must contain exactly one assigned tank.
    local firstMarker, firstPresent = GetTankMarker(1)
    local secondMarker, secondPresent = GetTankMarker(2)
    if not firstPresent or not secondPresent then
        return
    end

    local index = playerSubgroup % 2 == 1 and firstMarker or secondMarker
    -- Let Blizzard select the icon; the index may be a secret number.
    if index then
        SetRaidTargetIconTexture(marker.texture, index)
        marker:Show()
    end
end

local function QueueUpdate()
    -- Roster/role information may settle after the event itself.
    if addon.pending then
        return
    end
    addon.pending = true
    C_Timer.After(0.1, function()
        addon.pending = false
        Update()
    end)
end

addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:RegisterEvent("GROUP_ROSTER_UPDATE")
addon:RegisterEvent("RAID_ROSTER_UPDATE")
addon:RegisterEvent("PLAYER_ROLES_ASSIGNED")
addon:RegisterEvent("ROLE_CHANGED_INFORM")
addon:RegisterEvent("RAID_TARGET_UPDATE")
addon:SetScript("OnEvent", QueueUpdate)

SLASH_RAIDTANKMARKER1 = "/rtm"
SlashCmdList.RAIDTANKMARKER = function(command)
    if command == "test" then
        local index = GetRaidTargetIndex("player")
        if not index then
            HideTestOverlay()
            if marker then marker:Hide() end
            print("RaidTankMarker: Du hast keine Schlachtzugsmarkierung.")
            return
        end

        if IsInRaid() then
            HideTestOverlay()
            if not EnsureMarker() then
                print("RaidTankMarker: Blizzard PlayerFrame nicht gefunden.")
                return
            end
            SetRaidTargetIconTexture(marker.texture, index)
            marker:Show()
            print("RaidTankMarker: Eigene Schlachtzugsmarkierung am echten Gruppenindikator angezeigt.")
        else
            if not EnsureTestOverlay() then
                print("RaidTankMarker: Blizzard PlayerFrame nicht gefunden.")
                return
            end
            if marker then marker:Hide() end
            SetRaidTargetIconTexture(testOverlay.icon, index)
            testOverlay:Show()
            print("RaidTankMarker: Simulierte Gruppe 1 mit eigener Schlachtzugsmarkierung angezeigt; /rtm refresh beendet den Test.")
        end
    else
        HideTestOverlay()
        QueueUpdate()
        print("RaidTankMarker: Anzeige aktualisiert.")
    end
end
