peacekeeper_mistrial = class({})
LinkLuaModifier( "modifier_mistrial", "heroes/peacekeeper/peacekeeper_mistrial.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function peacekeeper_mistrial:GetIntrinsicModifierName()
	return "modifier_mistrial"
end

function peacekeeper_mistrial:OnSpellStart()
	self:StartCooldown(self:GetCooldown(self:GetLevel()))
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_mistrial = class({})

function modifier_mistrial:OnCreated(table)
	self.caster = self:GetCaster()

	self.backtrack_time = self:GetAbility():GetSpecialValueFor("backtrack_time")

	self.health = 0

	self:StartIntervalThink(self.backtrack_time)
end

function modifier_mistrial:OnIntervalThink()
	if IsServer() then
		self.health = self.caster:GetHealth()
		--print(self.health)
	end
end

function modifier_mistrial:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
	return funcs
end

function modifier_mistrial:OnAbilityExecuted( params )
	if IsServer() then
		if params.ability == self:GetAbility() then
			if self.caster:GetHealth() < self.health then
				SendOverheadEventMessage(self.caster:GetPlayerOwner(),OVERHEAD_ALERT_HEAL,self.caster,self.health-self.caster:GetHealth(),self.caster:GetPlayerOwner())
				self.caster:SetHealth(self.health)
			end
		end
	end
end