BSCCompanionInfoExtension = BSCCompanionInfoExtension or {}
local BSCCOIN_EX = BSCCompanionInfoExtension
local BSCCOIN = BSCCompainionInfo

BSCCOIN_EX.Name = "BSCs-CompanionInfoExtension"
BSCCOIN_EX.NameSpaced = "BloodStainChild666's Companion Info - Extension"
BSCCOIN_EX.Author = "@DoonerSeraph"
BSCCOIN_EX.Version = 1
BSCCOIN_EX.SavedVar = "BSCCompanionInfoExtensionsSavedVariables"
BSCCOIN_EX.VersionDisplay = "1.0.0"

BSCCOIN_EX.XpBarProperties = { "ArmorXPControls", "WeaponXPControls" }

BSCCOIN_EX.ArmorXPControls = {
	SkillLineId = nil,
	hidden = false
}
BSCCOIN_EX.WeaponXPControls = {
	SkillLineId = nil,
	hidden = false
}

local function PackRGBA(r, g, b, a)
	return {
		r = r,
		g = g,
		b = b,
		a = a
	}
end

local function UnpackRGBA(color)
	return color.r, color.g, color.b, color.a
end

local function FontCheck(size)
	local new_size = size
	
	if size > 54 then new_size = 54 end
	if size > 48 and size < 54 then new_size = 48 end
	if size > 40 and size < 48 then new_size = 40 end
	if size > 36 and size < 40 then new_size = 36 end
	if size > 34 and size < 36 then new_size = 34 end
	if size > 32 and size < 34 then new_size = 32 end
	if size > 30 and size < 32 then new_size = 30 end
	if size > 28 and size < 30 then new_size = 28 end
	if size > 26 and size < 28 then new_size = 26 end
		
	return new_size
end

local function GetFont(Font, Size, Style)
	return zo_strformat("$(<<1>>)|$(KB_<<2>>)|<<3>>", Font, FontCheck(Size), Style)
end

local function GetSkillLineIdFromWeaponType()
	local equippedWeaponTypeMainHand = GetItemWeaponType(BAG_COMPANION_WORN, EQUIP_SLOT_MAIN_HAND)
	local equippedWeaponTypeOffHand = GetItemWeaponType(BAG_COMPANION_WORN, EQUIP_SLOT_OFF_HAND)
	if (equippedWeaponTypeMainHand == WEAPONTYPE_AXE or equippedWeaponTypeMainHand == WEAPONTYPE_DAGGER or equippedWeaponTypeMainHand == WEAPONTYPE_HAMMER or equippedWeaponTypeMainHand == WEAPONTYPE_SWORD) then
		if (equippedWeaponTypeOffHand == WEAPONTYPE_SHIELD) then
			return 181 -- One Hand and Shield
		end
		if (equippedWeaponTypeOffHand == WEAPONTYPE_AXE or equippedWeaponTypeOffHand == WEAPONTYPE_DAGGER or equippedWeaponTypeOffHand == WEAPONTYPE_HAMMER or equippedWeaponTypeOffHand == WEAPONTYPE_SWORD) then
			return 182 -- Dual Wield
		end

		return 0
	end

	if (equippedWeaponTypeMainHand == WEAPONTYPE_FIRE_STAFF or equippedWeaponTypeMainHand == WEAPONTYPE_FROST_STAFF or equippedWeaponTypeMainHand == WEAPONTYPE_LIGHTNING_STAFF) then
		return 184 -- Destruction Staff
	end

	if (equippedWeaponTypeMainHand == WEAPONTYPE_HEALING_STAFF) then
		return 185 -- Restoration Staff
	end

	if (equippedWeaponTypeMainHand == WEAPONTYPE_BOW) then
		return 183 -- Bow
	end

	if (equippedWeaponTypeMainHand == WEAPONTYPE_TWO_HANDED_AXE or equippedWeaponTypeMainHand == WEAPONTYPE_TWO_HANDED_SWORD or equippedWeaponTypeMainHand == WEAPONTYPE_TWO_HANDED_HAMMER) then
		return 180 -- Two-Handed
	end
end

local function GetCountOfArmorPiecesWornByWeight()
	local slots = { EQUIP_SLOT_HEAD, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_CHEST, EQUIP_SLOT_HAND, EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET }
	local heavyArmor = 0
	local mediumArmor = 0
	local lightArmor = 0
	for i, v in ipairs(slots) do
		local armorType = GetItemArmorType(BAG_COMPANION_WORN, v)
		if (armorType == ARMORTYPE_HEAVY) then
			heavyArmor = heavyArmor + 1
		end
		if (armorType == ARMORTYPE_MEDIUM) then
			mediumArmor = mediumArmor + 1
		end
		if (armorType == ARMORTYPE_LIGHT) then
			lightArmor = lightArmor + 1
		end
	end

	return heavyArmor, mediumArmor, lightArmor
end

local function GetSkillLineFromCompanionArmorPieces()
	local heavyArmor, mediumArmor, lightArmor = GetCountOfArmorPiecesWornByWeight()

	if (heavyArmor > 5) then return 188 end
	if (mediumArmor > 5) then return 187 end
	if (lightArmor > 5) then return 186 end

	return 0
end

local function UpdateXPUI(xpControls)
	if xpControls.StatusBarControl == nil then return end
	local skillLineId = xpControls.SkillLineId
	if HasActiveCompanion() then		
		local level, _, _ = GetCompanionSkillLineDynamicInfo(skillLineId)
		local lastRankXP, nextRankXP, currentXP = GetCompanionSkillLineXPInfo(skillLineId)
		local destroXpInLevel = currentXP - lastRankXP
		local destroTotalXpInLevel = nextRankXP - lastRankXP	
		local forceRefresh = true
        local shouldNotWrap = forceRefresh		
        
		--xpControls.StatusBarControl:SetValue(destroLevel, destroXpInLevel, destroTotalXpInLevel, shouldNotWrap, forceRefresh)
		local percentageXp = zo_floor(destroXpInLevel / destroTotalXpInLevel * 100)  		
		xpControls.ExpInfoControl:SetText(zo_strformat("LV <<1>> : ", level)..zo_strformat(SI_EXPERIENCE_CURRENT_MAX_PERCENT, ZO_CommaDelimitNumber(destroXpInLevel), ZO_CommaDelimitNumber(destroTotalXpInLevel), percentageXp))

		xpControls.StatusBarControl:SetDimensions(math.ceil((destroXpInLevel / destroTotalXpInLevel) * (BSCCOIN.SV.UI_WIDTH))+1,BSCCOIN.SV.UI_HIGHT_XPBAR-2)
	end
end

local function AddExtraXPBarToOriginalUI(xpControls, backdropName, anchorTo, centerColorRGBA, edgeColorRGBA, barColorRGBA1, barColorRGBA2)
	local backDropControl = BSCCompainionInfoUI:CreateControl(backdropName, CT_BACKDROP) -- See http://wiki.esoui.com/Globals#ControlType
	local expInfoControl = backDropControl:CreateControl(backdropName..'ExpInfo', CT_LABEL)
	local statusBarControl = backDropControl:CreateControl(backdropName..'ExpBar', CT_STATUSBAR)
	ApplyTemplateToControl(backDropControl, "BDXP_TEMPLATE")

	backDropControl:ClearAnchors()
	backDropControl:SetAnchor(TOPLEFT, anchorTo, BOTTOMLEFT, 0, 0)
	xpControls.hidden = false
	xpControls.anchor = anchorTo

	local r1, g1, b1, a1 = UnpackRGBA(barColorRGBA1)
	local r2, g2, b2, a2 = UnpackRGBA(barColorRGBA2)
	statusBarControl:SetGradientColors(r1, g1, b1, a1, r2, g2, b2, a2)

	return backDropControl, expInfoControl, statusBarControl
end

local function ToggleXpBar()

end

local function InitUI()
	BSCCOIN_EX.WeaponXPControls.SkillLineId = GetSkillLineIdFromWeaponType()
	BSCCOIN_EX.ArmorXPControls.SkillLineId = GetSkillLineFromCompanionArmorPieces()

	BSCCOIN_EX.ArmorXPControls.BackDropControl,BSCCOIN_EX.ArmorXPControls.ExpInfoControl, BSCCOIN_EX.ArmorXPControls.StatusBarControl = AddExtraXPBarToOriginalUI(BSCCOIN_EX.ArmorXPControls, 'BDXP_ARMOR_B2', BSCCompainionInfoUI:GetNamedChild('SKillInfo'), PackRGBA(0, 0, 0, 0.6), PackRGBA(255, 255, 255, 0.6), PackRGBA(0.0, 0.6, 0.6, 1), PackRGBA(0.0, 0.4, 0.4, 1))
	BSCCOIN_EX.WeaponXPControls.BackDropControl, BSCCOIN_EX.WeaponXPControls.ExpInfoControl, BSCCOIN_EX.WeaponXPControls.StatusBarControl = AddExtraXPBarToOriginalUI(BSCCOIN_EX.WeaponXPControls, 'BDXP_WEAPON_B2', BSCCOIN_EX.ArmorXPControls.BackDropControl, PackRGBA(0, 0, 0, 0.6), PackRGBA(255, 255, 255, 0.6), PackRGBA(0.5, 0.3, 0.1, 1), PackRGBA(0.5, 0.35, 0.15, 1))

	UpdateXPUI(BSCCOIN_EX.ArmorXPControls)
	UpdateXPUI(BSCCOIN_EX.WeaponXPControls)
end

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////// --- Event Handlers -- /////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local function OnSlotUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
	if not HasActiveCompanion() then return end
	--d(zo_strformat('bagId[<<1>>] slotIndex[<<2>>] isNewItem[<<3>>] itemSoundCategory[<<4>>] updateReason[<<5>>]', bagId, slotIndex, isNewItem, itemSoundCategory, updateReason))
    if bagId == BAG_COMPANION_WORN and updateReason == INVENTORY_UPDATE_REASON_DEFAULT then
    	--d(zo_strformat('bagId[<<1>>] slotIndex[<<2>>] isNewItem[<<3>>] itemSoundCategory[<<4>>] updateReason[<<5>>]', bagId, slotIndex, isNewItem, itemSoundCategory, updateReason))
        --d("Equipped weapon changed.")
        if (slotIndex == EQUIP_SLOT_MAIN_HAND or slotIndex == EQUIP_SLOT_OFF_HAND) then
        	BSCCOIN_EX.WeaponXPControls.SkillLineId = GetSkillLineIdFromWeaponType()
        	UpdateXPUI(BSCCOIN_EX.WeaponXPControls)
        else
        	BSCCOIN_EX.ArmorXPControls.SkillLineId = GetSkillLineFromCompanionArmorPieces()
        	UpdateXPUI(BSCCOIN_EX.ArmorXPControls)
    	end
    end
end

local function UpdateXP()
	UpdateXPUI(BSCCOIN_EX.WeaponXPControls)
	UpdateXPUI(BSCCOIN_EX.ArmorXPControls)
end

local function OnPlayerFirstActivated()
	EVENT_MANAGER:UnregisterForEvent(BSCCOIN_EX.Name,EVENT_PLAYER_ACTIVATED);
	InitUI()
	EVENT_MANAGER:RegisterForEvent(BSCCOIN_EX.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnSlotUpdate)
	EVENT_MANAGER:AddFilterForEvent(BSCCOIN_EX.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_COMPANION_WORN)
	EVENT_MANAGER:RegisterForEvent(BSCCOIN_EX.Name, EVENT_COMPANION_SKILL_XP_UPDATE, UpdateXP)
end

local function OnPlayerActivated()
	if not DoesUnitExist("companion") or not HasActiveCompanion() then return end
	UpdateXP()
	BSCCOIN:InitSkillBarIcons()
end

local function OnCompanionActivated()
	BSCCOIN_EX.WeaponXPControls.SkillLineId = GetSkillLineIdFromWeaponType()
	BSCCOIN_EX.ArmorXPControls.SkillLineId = GetSkillLineFromCompanionArmorPieces()

	UpdateXP()
	BSCCOIN:InitSkillBarIcons()
end

local function UpdateUI()
	BSCCOIN_EX.WeaponXPControls.SkillLineId = GetSkillLineIdFromWeaponType()
	BSCCOIN_EX.ArmorXPControls.SkillLineId = GetSkillLineFromCompanionArmorPieces()

	UpdateXP()
	BSCCOIN:InitSkillBarIcons()
end

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////// --- Init -- //////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function BSCCOIN_EX.init(event, addonName)	
	if addonName ~= BSCCOIN_EX.Name then
		return 
	end
	EVENT_MANAGER:UnregisterForEvent(BSCCOIN_EX.Name,EVENT_ADD_ON_LOADED);
	EVENT_MANAGER:RegisterForEvent(BSCCOIN_EX.Name, EVENT_PLAYER_ACTIVATED, OnPlayerFirstActivated)	
	EVENT_MANAGER:RegisterForEvent(BSCCOIN_EX.Name.."Secondary", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)	
	EVENT_MANAGER:RegisterForEvent(BSCCOIN_EX.Name, EVENT_COMPANION_ACTIVATED, OnCompanionActivated)	
end

EVENT_MANAGER:RegisterForEvent(BSCCOIN_EX.Name, EVENT_ADD_ON_LOADED, BSCCOIN_EX.init)