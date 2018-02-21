alchemist_midas_knuckle = class({})

function alchemist_midas_knuckle:IsStealable()
	return true
end

function alchemist_midas_knuckle:IsHiddenWhenStolen()
	return false
end

function alchemist_midas_knuckle:OnAbilityPhaseStart()
	self.warmupFX = ParticleManager:CreateParticle("particles/econ/items/pugna/pugna_ward_golden_nether_lord/pugna_gold_ambient.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	return true
end

function alchemist_midas_knuckle:OnAbilityPhaseInterrupted()
	ParticleManager:ClearParticle(self.warmupFX)
end

function alchemist_midas_knuckle:OnSpellStart()
	local target = self:GetCursorTarget()
	
	self:MidasKnuckle(target)
	
	ParticleManager:ClearParticle(self.warmupFX)
end

function alchemist_midas_knuckle:MidasKnuckle(target)
	local caster = self:GetCaster()
	local damage = self:GetTalentSpecialValueFor("base_dmg")
	local bonusdamage = self:GetTalentSpecialValueFor("net_worth_bonus_dmg") / 100
	local goldDamage = PlayerResource:GetTotalGoldSpent(caster:GetPlayerID()) * bonusdamage
	local totDmg = damage + goldDamage
	
	self:DealDamage(caster, target, totDmg)
	
	print(target)
	
	local goldFountain = ParticleManager:CreateParticle("particles/econ/items/necrolyte/necrophos_sullen_gold/necro_sullen_pulse_enemy_explosion_gold.vpcf", PATTACH_POINT_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(goldFountain, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(goldFountain, 3, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	
	self:Stun(target, self:GetTalentSpecialValueFor("ministun"), false)
	EmitSoundOn("Hero_Alchemist.UnstableConcoction.Stun", target)
	
	ParticleManager:ClearParticle(goldFountain)
end

function alchemist_midas_knuckle:GetIntrinsicModifierName()
	return "modifier_alchemist_midas_knuckle_autocast"
end

modifier_alchemist_midas_knuckle_autocast = class({})
LinkLuaModifier("modifier_alchemist_midas_knuckle_autocast", "heroes/hero_alchemist/alchemist_midas_knuckle", LUA_MODIFIER_MOTION_NONE)

function modifier_alchemist_midas_knuckle_autocast:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_alchemist_midas_knuckle_autocast:OnAttackLanded(params)
	if self:GetAbility():GetAutoCastState() and self:GetAbility():IsCooldownReady() and params.attacker == self:GetParent() then
		self:GetAbility():MidasKnuckle(params.target)
		self:GetAbility():SetCooldown()
	end
end

function modifier_alchemist_midas_knuckle_autocast:IsHidden()
	return true 
end