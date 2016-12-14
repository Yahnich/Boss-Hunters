function FrostBlastProc(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	local frostnova = caster:FindAbilityByName("lich_frost_nova")
	if frostnova:GetLevel() < 1 or ability:GetToggleState() then return end
	caster:SetCursorCastTarget(target)
	frostnova:OnSpellStart()
end

function IceArmorCheck(keys)
	local caster = keys.caster
	local ability = keys.ability
	local usedability = keys.event_ability
	local target = keys.target
	
	local icearmor = caster:FindAbilityByName("lich_frost_armor")
	local amountAllies = ability:GetTalentSpecialValueFor("ice_armor_targets")

	if icearmor ~= usedability or amountAllies == 0 then return end
	
	local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), nil, ability:GetCastRange(), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false)
	
	if icearmor:GetCursorTarget() ~= caster then
		caster:AddNewModifier(caster, icearmor, "modifier_lich_frost_armor", {duration = icearmor:GetDuration()})
		amountAllies = amountAllies - 1
	end
	
	for _, ally in pairs(allies) do
		if amountAllies < 1 then break end
		ally:AddNewModifier(caster, icearmor, "modifier_lich_frost_armor", {duration = icearmor:GetDuration()})
		amountAllies = amountAllies - 1
	end
end