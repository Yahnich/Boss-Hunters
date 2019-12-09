boss_ifdat_magma_pool = class({})

function boss_ifdat_magma_pool:OnAbilityPhaseStart()
	ParticleManager:FireParticle( "particles/units/heroes/hero_lina/lina_spell_light_strike_array_ray_team.vpcf", PATTACH_WORLDORIGIN, caster, {[0] = position, [1] = Vector(self:GetSpecialValueFor("radius"), 1, 1) } )
	self:GetCaster():EmitSound( "Ability.PreLightStrikeArray" )
	return true
end

function boss_ifdat_magma_pool:OnOwnerDied()
	if self.magmaPools then
		for _, pit in ipairs( self.magmaPools ) do
			UTIL_Remove( pit )
		end
	end
end

function boss_ifdat_magma_pool:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")
	
	local pit = CreateModifierThinker(caster, self, "modifier_ifdat_magma_pool", {}, position, caster:GetTeam(), false)
	self.magmaPools = self.magmaPools or {}
	table.insert(self.magmaPools, pit)
	
	ParticleManager:FireParticle( "particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_WORLDORIGIN, caster, {[0] = position, [1] = Vector(radius, 1, 1) } )
	self:GetCaster():EmitSound( "Ability.LightStrikeArray" )
end

modifier_ifdat_magma_pool = class({})
LinkLuaModifier( "modifier_ifdat_magma_pool", "bosses/boss_ifdat/boss_ifdat_magma_pool", LUA_MODIFIER_MOTION_NONE )
function modifier_ifdat_magma_pool:OnCreated(table)
    self.radius = self:GetSpecialValueFor("radius")
	if IsServer() then
		local fx = ParticleManager:CreateParticle( "particles/units/bosses/boss_ifdat/boss_ifdat_magma_pool.vpcf", PATTACH_POINT, self:GetParent() )
		ParticleManager:SetParticleControl( fx, 0, self:GetParent():GetAbsOrigin() )
		self:AddEffect(fx)
		self:StartIntervalThink(0.25)
	end
end

function modifier_ifdat_magma_pool:IsAura()
    return true
end

function modifier_ifdat_magma_pool:GetAuraDuration()
    return 0.5
end

function modifier_ifdat_magma_pool:GetAuraRadius()
    return self.radius
end

function modifier_ifdat_magma_pool:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_ifdat_magma_pool:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_ifdat_magma_pool:GetModifierAura()
    return "modifier_ifdat_magma_pool_damage"
end

function modifier_ifdat_magma_pool:IsAuraActiveOnDeath()
    return false
end

function modifier_ifdat_magma_pool:IsHidden()
    return true
end

modifier_ifdat_magma_pool_damage = class({})
LinkLuaModifier( "modifier_ifdat_magma_pool_damage", "bosses/boss_ifdat/boss_ifdat_magma_pool", LUA_MODIFIER_MOTION_NONE )
function modifier_ifdat_magma_pool_damage:OnCreated(table)
	if IsServer() then
    	self.damage = self:GetSpecialValueFor("damage_per_sec")
    	self:StartIntervalThink(1)
    end
end

function modifier_ifdat_magma_pool_damage:OnIntervalThink()
	ParticleManager:FireParticle("particles/units/heroes/hero_batrider/batrider_firefly_debuff.vpcf", PATTACH_POINT, self:GetParent(), {})
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {}, OVERHEAD_ALERT_DAMAGE)
end

function modifier_ifdat_magma_pool_damage:IsHidden()
    return true
end