peacekeeper_mistrial = class({})
LinkLuaModifier( "modifier_mistrial", "heroes/peacekeeper/peacekeeper_mistrial.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function peacekeeper_mistrial:GetIntrinsicModifierName()
	return "modifier_mistrial"
end

function peacekeeper_mistrial:OnSpellStart()
	self.caster = self:GetCaster()
	self.modifier = self.caster:FindModifierByName("modifier_mistrial")
	if self.caster:GetHealth() < self.modifier.health then
		SendOverheadEventMessage(self.caster:GetPlayerOwner(),OVERHEAD_ALERT_HEAL,self.caster,self.modifier.health-self.caster:GetHealth(),self.caster:GetPlayerOwner())
		self.nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_templar_assassin/templar_assassin_refraction_form.vpcf", PATTACH_POINT, self.caster )
		ParticleManager:SetParticleControl(self.nFXIndex,1,self.caster:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(self.nFXIndex)
		self.caster:Heal(self.modifier.health,self.caster)
	else
		self:EndCooldown()
		self:RefundManaCost()
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_mistrial = class({})

function modifier_mistrial:OnCreated(table)
	self.caster = self:GetCaster()

	self.backtrack_time = self:GetSpecialValueFor("backtrack_time")

	self.health = 0

	if IsServer() then
		self:StartIntervalThink(self.backtrack_time)
	end
end

function modifier_mistrial:OnIntervalThink()
	if IsServer() then
		self.health = self.caster:GetHealth()
		--print(self.health)
	end
end

function modifier_mistrial:IsHidden()
	return true
end