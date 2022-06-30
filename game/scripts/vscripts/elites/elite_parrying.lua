elite_parrying = class({})

function elite_parrying:GetIntrinsicModifierName()
	return "modifier_elite_parrying_buff"
end

modifier_elite_parrying_buff = class({})
LinkLuaModifier("modifier_elite_parrying_buff", "elites/elite_parrying", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_parrying_buff:OnCreated() 
	self.reflect = self:GetSpecialValueFor("reflect") / 100
	if IsServer() then
		self:AddEffect( ParticleManager:CreateParticle( "particles/units/elite_warning_defense_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() ) )
	end
end

function modifier_elite_parrying_buff:OnRefresh() 
	self.reflect = self:GetSpecialValueFor("reflect") / 100
end

function modifier_elite_parrying_buff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_elite_parrying_buff:OnTakeDamage(params)
	local hero = self:GetParent()
	if params.unit ~= hero then return end
    local dmg = params.original_damage * self.reflect
	local dmgtype = params.damage_type
	local attacker = params.attacker
	if not hero:PassivesDisabled() and attacker:GetTeamNumber()  ~= hero:GetTeamNumber() and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ) then
		self:GetAbility():DealDamage( hero, attacker, dmg, {damage_type = dmgtype, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
	end
end

function modifier_elite_parrying_buff:GetEffectName()
	return "particles/items_fx/blademail.vpcf"
end

function modifier_elite_parrying_buff:IsHidden()
	return true
end