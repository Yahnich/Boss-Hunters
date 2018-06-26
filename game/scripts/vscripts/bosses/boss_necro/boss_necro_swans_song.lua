boss_necro_swans_song = class({})

function boss_necro_swans_song:OnAbilityPhaseStart()
	ParticleManager:FireTargetWarningParticle( self:GetCursorTarget() )
	return true
end

function boss_necro_swans_song:OnSpellStart()
	self:GetCursorTarget():AddNewModifier( self:GetCaster(), self, "modifier_boss_necro_swans_song", {duration = self:GetSpecialValueFor("duration")} )
end

modifier_boss_necro_swans_song = class({})
LinkLuaModifier("modifier_boss_necro_swans_song", "bosses/boss_necro/boss_necro_swans_song", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_necro_swans_song:OnCreated()
	self.damage = self:GetSpecialValueFor("max_hp_damage") / 100
	if IsServer() then 
		EmitSoundOn( "Hero_Necrolyte.SpiritForm.Cast", self:GetParent() )
		self:StartIntervalThink(1) 
	end
end

function modifier_boss_necro_swans_song:OnIntervalThink()
	local caster = self:GetCaster()
	local heroes = caster:FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("radius") , {type = DOTA_UNIT_TARGET_HERO} )
	local damage = self:GetParent():GetMaxHealth() * self.damage * HeroList:GetActiveHeroCount() / #heroes
	for _, hero in ipairs( heroes ) do
		self:GetAbility():DealDamage( self:GetCaster(), hero, damage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
	end
end

function modifier_boss_necro_swans_song:GetEffectName()
	return "particles/units/heroes/hero_necrolyte/necrolyte_spirit.vpcf"
end