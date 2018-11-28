ds_replica = class({})
LinkLuaModifier( "modifier_ds_replica", "heroes/hero_dark_seer/ds_replica.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ds_shell", "heroes/hero_dark_seer/ds_shell.lua" ,LUA_MODIFIER_MOTION_NONE )

function ds_replica:IsStealable()
    return true
end

function ds_replica:IsHiddenWhenStolen()
    return false
end

function ds_replica:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetTalentSpecialValueFor("duration")
	local outgoing = self:GetTalentSpecialValueFor("outgoing")
	local incoming = self:GetTalentSpecialValueFor("incoming")

	EmitSoundOn("Hero_Dark_Seer.Wall_of_Replica_Start", caster)

	local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
	for _,ally in pairs(allies) do
		if ally:IsHero() and not ally:IsIllusion() then
			local image = ally:ConjureImage( ally:GetAbsOrigin(), duration, outgoing, incoming, "", self, true, caster )
			image:AddNewModifier(caster, self, "modifier_ds_replica", {})

			if caster:HasScepter() then
				image:AddNewModifier(caster, caster:FindAbilityByName("ds_shell"), "modifier_ds_shell", {})
			end

			if caster:HasTalent("special_bonus_unique_ds_replica_1") then
				FindClearSpaceForUnit(image, caster:GetAbsOrigin(), true)
			end
		end
	end
end

modifier_ds_replica = class({})
function modifier_ds_replica:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_ds_replica:OnDeath(params)
	if IsServer() then
		local caster = self:GetCaster()

		if caster:HasTalent("special_bonus_unique_ds_replica_2") then
			local parent = self:GetParent()
			local unit = params.unit

			if unit == parent then
				caster:FindAbilityByName("ds_vacuum"):Vacuum(parent:GetAbsOrigin(), 250)
			end
		end
	end
end

function modifier_ds_replica:IsHidden()
	return true
end