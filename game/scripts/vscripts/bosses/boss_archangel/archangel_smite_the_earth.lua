archangel_smite_the_earth = class({})

function archangel_smite_the_earth:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCursorPosition(), self:GetSpecialValueFor("radius") )
	return true
end

function archangel_smite_the_earth:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local radius = self:GetSpecialValueFor("radius")
	local tick_rate = self:GetSpecialValueFor("tick_interval")
	local duration = self:GetSpecialValueFor("duration")

	EmitSoundOn("Hero_SkywrathMage.MysticFlare.Cast", caster)

	ParticleManager:FireParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_mystic_flare_ambient.vpcf", PATTACH_POINT, caster, {	[0]=point, 
																																				[1]=Vector(radius,duration,tick_rate)})
	CreateModifierThinker(caster, self, "modifier_archangel_smite_the_earth", {Duration = duration}, point, caster:GetTeam(), false)
end

modifier_archangel_smite_the_earth = class({})
LinkLuaModifier( "modifier_archangel_smite_the_earth", "bosses/boss_archangel/archangel_smite_the_earth.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_archangel_smite_the_earth:OnCreated(table)
	self.tick = self:GetSpecialValueFor("tick_interval")
	self.damage = self:GetSpecialValueFor("damage")
	self.radius = self:GetSpecialValueFor("radius")
	if IsServer() then
		EmitSoundOn("Hero_SkywrathMage.MysticFlare", self:GetParent())
		self:StartIntervalThink( self.tick )
	end
end

function modifier_archangel_smite_the_earth:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_SkywrathMage.MysticFlare", self:GetParent())
	end
end

function modifier_archangel_smite_the_earth:OnIntervalThink()
	if not self:GetCaster() or self:GetCaster():IsNull() then self:GetParent():Destroy() end
    local enemies = self:GetParent():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self.radius)
    for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb( self:GetAbility() ) then
			EmitSoundOn("Hero_SkywrathMage.MysticFlare.Target", enemy)
			self:GetAbility():DealDamage(self:GetCaster(), enemy, self.damage / #enemies)
		end
    end
end

function modifier_archangel_smite_the_earth:IsHidden()
	return true
end