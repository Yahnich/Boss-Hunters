boss_doom_ill_fated = class({})

function boss_doom_ill_fated:OnSpellStart()
	local caster = self:GetCaster()
	self:GetCursorTarget():AddNewModifier(caster, self, "modifier_boss_doom_ill_fated", {duration = self:GetSpecialValueFor("duration")})
end

modifier_boss_doom_ill_fated = class({})
LinkLuaModifier("modifier_boss_doom_ill_fated", "bosses/boss_doom/boss_doom_ill_fated", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_doom_ill_fated:OnCreated()
	self.damage = self:GetSpecialValueFor("curr_hp_damage") / 100
	if IsServer() then 
		self:StartIntervalThink(0.1)
		EmitSoundOn( "Hero_DoomBringer.Doom", self:GetParent() )
	end
end

function modifier_boss_doom_ill_fated:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self:GetParent():GetHealth() * self.damage * 0.1, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
end

function modifier_boss_doom_ill_fated:OnDestroy()
	if IsServer() then StopSoundOn( "Hero_DoomBringer.Doom", self:GetParent() ) end
end

function modifier_boss_doom_ill_fated:CheckState()
	return {[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_PASSIVES_DISABLED] = true,
			[MODIFIER_STATE_MUTED] = true,
			}
end

function modifier_boss_doom_ill_fated:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf"
end

function modifier_boss_doom_ill_fated:GetStatusEffectName()
	return "particles/status_fx/status_effect_doom.vpcf"
end

function modifier_boss_doom_ill_fated:StatusEffectPriority()
	return 20
end