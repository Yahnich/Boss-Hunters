skywrath_flare = class({})
LinkLuaModifier( "modifier_skywrath_flare","heroes/hero_skywrath/skywrath_flare.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_skywrath_flare_aghs","heroes/hero_skywrath/skywrath_flare.lua",LUA_MODIFIER_MOTION_NONE )

function skywrath_flare:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local radius = self:GetTalentSpecialValueFor("radius")

	local tick_rate = self:GetTalentSpecialValueFor("tick_rate")
	local duration = self:GetTalentSpecialValueFor("duration")

	EmitSoundOn("Hero_SkywrathMage.MysticFlare.Cast", caster)

	ParticleManager:FireParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_mystic_flare_ambient.vpcf", PATTACH_POINT, caster, {[0]=point, [1]=Vector(radius,duration,tick_rate)})

	CreateModifierThinker(caster, self, "modifier_skywrath_flare", {Duration = duration}, point, caster:GetTeam(), false)

	if caster:HasScepter() then
        local pointRando = point + ActualRandomVector(self:GetTrueCastRange()/2, 0)
        ParticleManager:FireParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_mystic_flare_ambient.vpcf", PATTACH_POINT, caster, {[0]=pointRando, [1]=Vector(radius,duration,tick_rate)})
        CreateModifierThinker(caster, self, "modifier_skywrath_flare_aghs", {Duration = duration}, pointRando, caster:GetTeam(), false)
    end
end

modifier_skywrath_flare = class({})
function modifier_skywrath_flare:OnCreated(table)
	if IsServer() then
		EmitSoundOn("Hero_SkywrathMage.MysticFlare", self:GetParent())
		self:StartIntervalThink(self:GetTalentSpecialValueFor("tick_rate"))
	end
end

function modifier_skywrath_flare:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_SkywrathMage.MysticFlare", self:GetParent())
	end
end

function modifier_skywrath_flare:OnIntervalThink()
    local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
    for _,enemy in pairs(enemies) do
    	EmitSoundOn("Hero_SkywrathMage.MysticFlare.Target", enemy)
    	self:GetAbility():DealDamage(self:GetCaster(), enemy, self:GetTalentSpecialValueFor("damage")*self:GetTalentSpecialValueFor("tick_rate"))
    end
end

modifier_skywrath_flare_aghs = class({})
function modifier_skywrath_flare_aghs:OnCreated(table)
	if IsServer() then
		EmitSoundOn("Hero_SkywrathMage.MysticFlare.Scepter", self:GetParent())
		self:StartIntervalThink(self:GetTalentSpecialValueFor("tick_rate"))
	end
end

function modifier_skywrath_flare_aghs:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_SkywrathMage.MysticFlare.Scepter", self:GetParent())
	end
end

function modifier_skywrath_flare_aghs:OnIntervalThink()
    local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
    for _,enemy in pairs(enemies) do
    	EmitSoundOn("Hero_SkywrathMage.MysticFlare.Target", enemy)
    	self:GetAbility():DealDamage(self:GetCaster(), enemy, self:GetTalentSpecialValueFor("damage")*self:GetTalentSpecialValueFor("tick_rate"))
    end
end