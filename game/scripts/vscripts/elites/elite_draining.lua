elite_draining = class({})

function elite_draining:GetIntrinsicModifierName()
	return "modifier_elite_draining_buff"
end

modifier_elite_draining_buff = class({})
LinkLuaModifier("modifier_elite_draining_buff", "elites/elite_draining", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_draining_buff:OnCreated() 
	self.attackBurn = 50
	self.hitBurn = 15
	self.spellBurn = 100 / 100
	if IsServer() then
		self:AddOverheadEffect( ParticleManager:CreateParticle( "particles/units/elite_warning_offense_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() ) )
	end
end

function modifier_elite_draining_buff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_ABSORB_SPELL }
end

function modifier_elite_draining_buff:OnAttackLanded(params)
	local hero = self:GetParent()
	if hero:PassivesDisabled() then return end
	if params.target == hero then
		local burn = params.attacker:GetMana()
		params.attacker:SpendMana( self.hitBurn, nil )
		burn = burn - params.attacker:GetMana()
		self:GetAbility():DealDamage( hero, params.attacker, burn, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
		ParticleManager:FireParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_POINT_FOLLOW, params.attacker)
	elseif params.attacker == hero then
		local burn = params.target:GetMana()
		params.target:SpendMana( self.attackBurn, nil )
		burn = burn - params.target:GetMana()
		self:GetAbility():DealDamage( hero, params.target, burn, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
		ParticleManager:FireParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_POINT_FOLLOW, params.target)
	end
end

function modifier_elite_draining_buff:GetAbsorbSpell(params)
	if params.ability:GetCaster():GetTeam() ~= self:GetParent():GetTeam() then
		local burn = params.ability:GetCaster():GetMana()
		params.ability:GetCaster():SpendMana( params.ability:GetManaCost(-1) * self.spellBurn, nil )
		burn = burn - params.ability:GetCaster():GetMana()
		self:GetAbility():DealDamage( self:GetParent(), params.ability:GetCaster(), burn, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
		ParticleManager:FireParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_POINT_FOLLOW, params.ability:GetCaster())
	end
end

function modifier_elite_draining_buff:GetEffectName()
	return "particles/units/heroes/hero_antimage/antimage_spellshield_sphere.vpcf"
end

function modifier_elite_draining_buff:IsHidden()
	return true
end