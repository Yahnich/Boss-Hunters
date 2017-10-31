peacekeeper_conviction = class({})
LinkLuaModifier( "modifier_conviction", "heroes/peacekeeper/peacekeeper_conviction.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function peacekeeper_conviction:OnSpellStart()
	self.caster = self:GetCaster()

	self.duration = self:GetSpecialValueFor("duration")
	local units = FindUnitsInRadius(self.caster:GetTeam(),self.caster:GetAbsOrigin(),nil,FIND_UNITS_EVERYWHERE,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
	for _,unit in pairs(units) do
		unit:AddNewModifier(self.caster,self,"modifier_conviction",{Duration = self.duration})
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_conviction = class({})

function modifier_conviction:OnCreated(table)
	if IsServer() then
		self.caster = self:GetCaster()

		self.attack_speed = self:GetAbility():GetSpecialValueFor("attack_speed")
	end
end

function modifier_conviction:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_conviction:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed
end
