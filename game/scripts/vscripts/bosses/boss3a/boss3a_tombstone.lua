boss3a_tombstone = class({})

function boss3a_tombstone:GetIntrinsicModifierName()
	return "modifier_boss3a_tombstone_passive"
end

function boss3a_tombstone:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_boss3a_tombstone_thinker", {duration = self:GetChannelTime()})
end

function boss3a_tombstone:OnChannelInterrupted(bInterrupted)
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_boss3a_tombstone_thinker")
end

modifier_boss3a_tombstone_passive = class({})
LinkLuaModifier("modifier_boss3a_tombstone_passive", "bosses/boss3a/boss3a_tombstone.lua", 0)

function modifier_boss3a_tombstone_passive:OnCreated()
	self.overkillThreshold = self:GetSpecialValueFor("overkill_threshold") / 100
end

function modifier_boss3a_tombstone_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_boss3a_tombstone_passive:OnDeath(params)
	if params.unit == self:GetParent() and not params.unit:HasModifier("modifier_boss3a_tombstone_thinker") then
		local torso = CreateUnitByName("npc_dota_boss3a_b", params.unit:GetAbsOrigin(), true, nil, nil, params.unit:GetTeam())
		torso.unitIsRoundNecessary = true
	end
end

modifier_boss3a_tombstone_thinker = class({})
LinkLuaModifier("modifier_boss3a_tombstone_thinker", "bosses/boss3a/boss3a_tombstone.lua", 0)

function modifier_boss3a_tombstone_thinker:OnCreated()
	if IsServer() then 
		local caster = self:GetCaster()
		self.heal = caster:GetMaxHealth() * self:GetSpecialValueFor("regen_amount") * 0.01 / self:GetDuration()
		EmitSoundOn("Hero_Undying.Tombstone", caster)
		ParticleManager:FireParticle("particles/units/heroes/hero_undying/undying_tombstone.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		self:StartIntervalThink(0.3) 
	end
end

function modifier_boss3a_tombstone_thinker:OnIntervalThink()
	local parent = self:GetParent()
	parent:HealEvent(self.heal * 0.3, self:GetAbility(), parent)
end

function modifier_boss3a_tombstone_thinker:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end

function modifier_boss3a_tombstone_thinker:DeclareFunctions()
	return {MODIFIER_PROPERTY_MODEL_CHANGE, MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_boss3a_tombstone_thinker:GetModifierModelChange()
	return "models/heroes/phantom_assassin/arcana_tombstone.vmdl"
end

function modifier_boss3a_tombstone_thinker:OnTakeDamage(params)
	if params.unit == self:GetParent() then self:GetParent():Kill(params.inflictor, params.attacker) end
end

function modifier_boss3a_tombstone_thinker:GetEffectName()
	return "particles/frostivus_gameplay/frostivus_wraithking_tombstone_warmup_b.vpcf"
end