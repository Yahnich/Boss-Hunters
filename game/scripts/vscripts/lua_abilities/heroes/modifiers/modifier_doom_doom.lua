modifier_doom_doom_ebf = class({})

--------------------------------------------------------------------------------

function modifier_doom_doom_ebf:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_doom_doom_ebf:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_doom_doom_ebf:OnCreated( kv )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	EmitSoundOn( "Hero_DoomBringer.Doom", self:GetParent())
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink( 1 )
	end
end

function modifier_doom_doom_ebf:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf"
end

function modifier_doom_doom_ebf:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


function modifier_doom_doom_ebf:GetStatusEffectName()
	return "particles/status_fx/status_effect_doom.vpcf" 	   
end

--------------------------------------------------------------------------------

function modifier_doom_doom_ebf:OnDestroy()
	StopSoundOn("Hero_DoomBringer.Doom", self:GetParent())
end

function modifier_doom_doom_ebf:RemoveOnDeath()
	return true
end


--------------------------------------------------------------------------------

function modifier_doom_doom_ebf:OnIntervalThink()
	if IsServer() then
		ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility() })
		if not self:GetParent():IsAlive() then
			StopSoundOn("Hero_DoomBringer.Doom", self:GetParent())
		end
	end
end

function modifier_doom_doom_ebf:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
	}

	return state
end