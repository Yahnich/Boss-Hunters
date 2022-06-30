elite_burning = class({})

function elite_burning:GetIntrinsicModifierName()
	return "modifier_elite_burning"
end

modifier_elite_burning = class(relicBaseClass)
LinkLuaModifier("modifier_elite_burning", "elites/elite_burning", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_elite_burning:OnCreated()
		self.duration = self:GetSpecialValueFor("duration")
		self:StartIntervalThink(1)
	end
	
	function modifier_elite_burning:OnIntervalThink()
		local caster = self:GetCaster()
		if caster:PassivesDisabled() or not caster:IsAlive() then return end
		local ability = self:GetAbility()
		if not ability:IsFullyCastable() or caster:IsStunned() or caster:IsSilenced() or caster:GetCurrentActiveAbility() or caster:IsHexed() or caster:IsRooted() then return end
		if #caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), 800 ) <= 0 then return end
		
		local duration = self:GetAbility():GetSpecialValueFor("duration")
		EmitSoundOn("n_black_dragon.Fireball.Target", caster)
		ability:StartCooldown( duration * 2 )
		
		local startPos = caster:GetAbsOrigin()
		local direction = caster:GetForwardVector()
		local distance = self:GetSpecialValueFor("radius") * 0.95
		
		for i = 1, 6 do
			CreateModifierThinker(caster, ability, "modifier_elite_burning_dummy", {Duration = duration}, startPos + direction * distance * i, caster:GetTeam(), false)
		end
	end
end

function modifier_elite_burning:GetEffectName()
	return "particles/units/elite_warning_special_overhead.vpcf"
end

function modifier_elite_burning:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

modifier_elite_burning_dummy = class({})
LinkLuaModifier("modifier_elite_burning_dummy", "elites/elite_burning", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_burning_dummy:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
	if IsServer() then
		local  macropyre = ParticleManager:CreateParticle("particles/neutral_fx/black_dragon_fireball.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(macropyre, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(macropyre, 2, Vector(self:GetRemainingTime(),0,0))
		self:AddEffect( macropyre )
	end
end

function modifier_elite_burning_dummy:OnDestroy()
	if IsServer() then
		self:GetParent():ForceKill(false)
	end
end

function modifier_elite_burning_dummy:IsAura()
	return true
end

function modifier_elite_burning_dummy:GetAuraDuration()
    return 0.5
end

function modifier_elite_burning_dummy:GetAuraRadius()
    return self.radius
end

function modifier_elite_burning_dummy:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_elite_burning_dummy:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_elite_burning_dummy:GetModifierAura()
    return "modifier_elite_burning_aura"
end

function modifier_elite_burning_dummy:IsHidden()
    return true
end

modifier_elite_burning_aura = class({})
LinkLuaModifier("modifier_elite_burning_aura", "elites/elite_burning", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_burning_aura:OnCreated()
	self.damage = self:GetSpecialValueFor("aoe_damage")
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_elite_burning_aura:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.damage, {damage_type = DAMAGE_TYPE_MAGICAL} )
end