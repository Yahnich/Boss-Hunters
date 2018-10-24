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
	local bonusdamage = self:GetTalentSpecialValueFor("net_worth_bonus_dmg")
	self.goldDamage = ( self.goldDamage or 0 ) + self:GetGoldCost(-1)
	print(self.goldDamage)
	local totDmg = damage + self.goldDamage * bonusdamage
	
	self:DealDamage(caster, target, totDmg)
	
	local goldFountain = ParticleManager:FireParticle("particles/econ/items/necrolyte/necrophos_sullen_gold/necro_sullen_pulse_enemy_explosion_gold.vpcf", PATTACH_POINT_FOLLOW, target, {[0] = "attach_hitloc", [3] = "attach_hitloc"})
	
	self:Stun(target, self:GetTalentSpecialValueFor("ministun"), false)
	EmitSoundOn("Hero_Alchemist.UnstableConcoction.Stun", target)
	
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
		self:GetAbility():UseResources(true, true, true)
	end
end

function modifier_alchemist_midas_knuckle_autocast:IsHidden()
	return true 
end