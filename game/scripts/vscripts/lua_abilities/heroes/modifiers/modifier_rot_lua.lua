modifier_rot_lua = class({})
--------------------------------------------------------------------------------

function modifier_rot_lua:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_rot_lua:IsAura()
	if self:GetCaster() == self:GetParent() then
		return true
	end
	
	return false
end

--------------------------------------------------------------------------------

function modifier_rot_lua:GetModifierAura()
	return "modifier_rot_lua"
end

--------------------------------------------------------------------------------

function modifier_rot_lua:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

--------------------------------------------------------------------------------

function modifier_rot_lua:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_rot_lua:GetAuraRadius()
	return self.rot_radius
end

--------------------------------------------------------------------------------

function modifier_rot_lua:OnCreated( kv )
	self.rot_radius = self:GetAbility():GetSpecialValueFor( "rot_radius" )
	self.rot_slow = self:GetAbility():GetSpecialValueFor( "rot_slow" )
	self.rot_damage = self:GetAbility():GetSpecialValueFor( "rot_damage" )
	self.rot_bonus_damage = self:GetAbility():GetSpecialValueFor( "rot_damage_per_creep" )
	self.rot_tick = self:GetAbility():GetSpecialValueFor( "rot_tick" )

	if IsServer() then
		if self:GetParent() == self:GetCaster() then
			EmitSoundOn( "Hero_Pudge.Rot", self:GetCaster() )
			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_rot.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.rot_radius, 1, self.rot_radius ) )
			self:AddParticle( nFXIndex, false, false, -1, false, false )
		else
			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_rot_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			self:AddParticle( nFXIndex, false, false, -1, false, false )
		end

		self:StartIntervalThink( self.rot_tick )
	end
end

--------------------------------------------------------------------------------

function modifier_rot_lua:OnDestroy()
	if IsServer() then
		StopSoundOn( "Hero_Pudge.Rot", self:GetCaster() )
	end
end

--------------------------------------------------------------------------------

function modifier_rot_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_rot_lua:GetModifierMoveSpeedBonus_Percentage( params )
	if self:GetParent() == self:GetCaster() then
		return 0
	end

	return self.rot_slow
end

--------------------------------------------------------------------------------

function modifier_rot_lua:OnIntervalThink()
	if IsServer() then
		local flDamagePerTick = self.rot_damage
		if self:GetParent() ~= self:GetCaster() then
			local kills = self:GetCaster():FindModifierByName("modifier_rot_death_lua"):GetStackCount()
			if not kills then kills = 0 end
			flDamagePerTick = flDamagePerTick + self.rot_bonus_damage * kills
		end
		local flDamage =  self.rot_tick * flDamagePerTick
		if self:GetCaster():IsAlive() then
			local damage = {
				victim = self:GetParent(),
				attacker = self:GetCaster(),
				damage = flDamage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self:GetAbility()
			}

			ApplyDamage( damage )
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------