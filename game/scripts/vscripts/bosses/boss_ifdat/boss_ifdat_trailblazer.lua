boss_ifdat_trailblazer = class({})

function boss_ifdat_trailblazer:GetIntrinsicModifierName()
	return "modifier_boss_ifdat_trailblazer"
end

modifier_boss_ifdat_trailblazer = class({})
LinkLuaModifier( "modifier_boss_ifdat_trailblazer", "bosses/boss_ifdat/boss_ifdat_trailblazer", LUA_MODIFIER_MOTION_NONE )

modifier_boss_ifdat_trailblazer = class({})
function modifier_boss_ifdat_trailblazer:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		EmitSoundOn("Hero_Batrider.Firefly.loop", parent)

		self.pits = {}
		

		self.point = parent:GetAbsOrigin()
		self.radius = self:GetSpecialValueFor("radius")

		local nfx = ParticleManager:CreateParticle("particles/units/bosses/boss_ifdat/boss_ifdat_trailblazer.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 3, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(nfx, 11, Vector(1, 0, 0))

		self:AttachEffect(nfx)

		self.tick = 0

		self:StartIntervalThink(0.5)
	end
end

function modifier_boss_ifdat_trailblazer:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	
	GridNav:DestroyTreesAroundPoint(parent:GetAbsOrigin(), self.radius, false)

	local pit = CreateModifierThinker(caster, self:GetAbility(), "modifier_boss_ifdat_trailblazer_fire", {Duration = self:GetSpecialValueFor("duration")}, parent:GetAbsOrigin(), parent:GetTeam(), false)
	pit.pitList = self.pits
	table.insert(self.pits, pit)

	self:StartIntervalThink( ( self.radius / parent:GetIdealSpeed() ) * 0.75 )
end

function modifier_boss_ifdat_trailblazer:OnRemoved()
	if IsServer() then
		for _,pit in pairs(self.pits) do
			UTIL_Remove(pit)
		end

		StopSoundOn("Hero_Batrider.Firefly.loop", self:GetParent())
	end
end

function modifier_boss_ifdat_trailblazer:CheckState()
	return {[MODIFIER_STATE_FLYING] = true}
end

function modifier_boss_ifdat_trailblazer:IsDebuff()
	return false
end

function modifier_boss_ifdat_trailblazer:IsHidden()
	return true
end

function modifier_boss_ifdat_trailblazer:RemoveOnDeath()
    return true
end

modifier_boss_ifdat_trailblazer_fire = class({})
LinkLuaModifier( "modifier_boss_ifdat_trailblazer_fire", "bosses/boss_ifdat/boss_ifdat_trailblazer", LUA_MODIFIER_MOTION_NONE )
function modifier_boss_ifdat_trailblazer_fire:OnCreated(table)
    self.maxRadius = self:GetSpecialValueFor("radius")
    self.radiusGrowth = ( self.maxRadius / self:GetDuration() )
    self.radius = self.radiusGrowth
	if IsServer() then
		self:StartIntervalThink(0.25)
	end
end

function modifier_boss_ifdat_trailblazer_fire:OnIntervalThink()
	if self.radius < self.maxRadius then
		self.radius = math.min( self.maxRadius, self.radius + self.radiusGrowth )
	end
end

function modifier_boss_ifdat_trailblazer_fire:OnRemoved()
	if IsServer() then
		table.removeval(self:GetParent().pitList, self:GetParent())
	end
end

function modifier_boss_ifdat_trailblazer_fire:IsAura()
    return true
end

function modifier_boss_ifdat_trailblazer_fire:GetAuraDuration()
    return 0.5
end

function modifier_boss_ifdat_trailblazer_fire:GetAuraRadius()
    return self.radius
end

function modifier_boss_ifdat_trailblazer_fire:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_boss_ifdat_trailblazer_fire:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_boss_ifdat_trailblazer_fire:GetModifierAura()
    return "modifier_boss_ifdat_trailblazer_fire_damage"
end

function modifier_boss_ifdat_trailblazer_fire:IsAuraActiveOnDeath()
    return false
end

function modifier_boss_ifdat_trailblazer_fire:IsHidden()
    return true
end

modifier_boss_ifdat_trailblazer_fire_damage = class({})
LinkLuaModifier( "modifier_boss_ifdat_trailblazer_fire_damage", "bosses/boss_ifdat/boss_ifdat_trailblazer", LUA_MODIFIER_MOTION_NONE )
function modifier_boss_ifdat_trailblazer_fire_damage:OnCreated(table)
	if IsServer() then
    	self.damage = self:GetSpecialValueFor("dmg_per_sec")
    	self:StartIntervalThink(1)
    end
end

function modifier_boss_ifdat_trailblazer_fire_damage:OnIntervalThink()
	ParticleManager:FireParticle("particles/units/heroes/hero_batrider/batrider_firefly_debuff.vpcf", PATTACH_POINT, self:GetParent(), {})
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {}, OVERHEAD_ALERT_DAMAGE)
end

function modifier_boss_ifdat_trailblazer_fire_damage:IsHidden()
    return true
end