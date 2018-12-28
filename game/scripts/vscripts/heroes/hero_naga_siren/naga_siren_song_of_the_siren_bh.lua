naga_siren_song_of_the_siren_bh = class({})


function naga_siren_song_of_the_siren_bh:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_naga_siren_song_of_the_siren_song") then
		return "naga_siren_song_of_the_siren_cancel"
	else
		return "naga_siren_song_of_the_siren"
	end
end

function naga_siren_song_of_the_siren_bh:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("radius")
end

function naga_siren_song_of_the_siren_bh:GetManaCost( iLvl )
	if self:GetCaster():HasModifier("modifier_naga_siren_song_of_the_siren_song") then
		return 0
	else
		return self.BaseClass.GetManaCost( self, iLvl )
	end
end

function naga_siren_song_of_the_siren_bh:GetCastPoint()
	if self:GetCaster():HasModifier("modifier_naga_siren_song_of_the_siren_song") then
		return 0
	else
		return self.BaseClass.GetCastPoint( self )
	end
end

function naga_siren_song_of_the_siren_bh:OnSpellStart()
	local caster = self:GetCaster()
	if not caster:HasModifier("modifier_naga_siren_song_of_the_siren_song") then
		caster:AddNewModifier(caster, self, "modifier_naga_siren_song_of_the_siren_song", {duration = self:GetTalentSpecialValueFor("duration")})
		self:EndCooldown()
		ParticleManager:FireParticle("particles/units/heroes/hero_siren/naga_siren_siren_song_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
	else
		caster:RemoveModifierByName("modifier_naga_siren_song_of_the_siren_song")
	end
end

modifier_naga_siren_song_of_the_siren_song = class({})
LinkLuaModifier("modifier_naga_siren_song_of_the_siren_song", "heroes/hero_naga_siren/naga_siren_song_of_the_siren_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_naga_siren_song_of_the_siren_song:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("radius")
	if IsServer() then
		self:GetParent():EmitSound("Hero_NagaSiren.SongOfTheSiren")
		if self:GetCaster():HasTalent("special_bonus_unique_naga_siren_song_of_the_siren_2") then
			self.healPct = (self:GetCaster():FindTalentValue("special_bonus_unique_naga_siren_song_of_the_siren_2") / self:GetRemainingTime()) / 100
			self:StartIntervalThink(0.33)
		end
	end
end

function modifier_naga_siren_song_of_the_siren_song:OnRefresh()
	self.radius = self:GetTalentSpecialValueFor("radius")
end

function modifier_naga_siren_song_of_the_siren_song:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self.radius ) ) do
		ally:HealEvent( ally:GetMaxHealth() * self.healPct, ability, caster)
	end
end

function modifier_naga_siren_song_of_the_siren_song:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_NagaSiren.SongOfTheSiren")
		self:GetParent():EmitSound("Hero_NagaSiren.SongOfTheSiren.Cancel")
		self:GetAbility():SetCooldown()
	end
end

function modifier_naga_siren_song_of_the_siren_song:IsAura()
	return true
end

function modifier_naga_siren_song_of_the_siren_song:GetModifierAura()
	return "modifier_naga_siren_song_of_the_siren_song_sleep"
end

function modifier_naga_siren_song_of_the_siren_song:GetAuraRadius()
	return self.radius
end

function modifier_naga_siren_song_of_the_siren_song:GetAuraDuration()
	return 0.5
end

function modifier_naga_siren_song_of_the_siren_song:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_naga_siren_song_of_the_siren_song:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_naga_siren_song_of_the_siren_song:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_naga_siren_song_of_the_siren_song:GetEffectName()
	return "particles/units/heroes/hero_siren/naga_siren_song_aura.vpcf"
end

modifier_naga_siren_song_of_the_siren_song_sleep = class({})
LinkLuaModifier("modifier_naga_siren_song_of_the_siren_song_sleep", "heroes/hero_naga_siren/naga_siren_song_of_the_siren_bh", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_naga_siren_song_of_the_siren_song_sleep:OnCreated()
		local nfx = ParticleManager:CreateParticle("particles/generic/charm_debuff/charm_generic_overhead.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
					ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)

		self:AttachEffect(nfx)

		self:StartIntervalThink(0.5)
	end
	
	function modifier_naga_siren_song_of_the_siren_song_sleep:OnIntervalThink()
		local direction = CalculateDirection(self:GetCaster(), self:GetParent())
		local oldPos = self:GetParent():GetAbsOrigin()
		local newPos = oldPos + direction * self:GetParent():GetIdealSpeed() * 0.5
		if not GridNav:CanFindPath(oldPos, newPos) then
			while not GridNav:CanFindPath(oldPos, newPos) do
				newPos = self:GetParent():GetAbsOrigin() + RandomVector(1):Normalized() * self:GetParent():GetIdealSpeed() * 0.5
			end
		end
		self:GetParent():MoveToPosition(newPos)
	end
end

function modifier_naga_siren_song_of_the_siren_song_sleep:CheckState()
	local state = {	[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
					[MODIFIER_STATE_DISARMED] = true,
					[MODIFIER_STATE_SILENCED] = true,
					[MODIFIER_STATE_PROVIDES_VISION] = true,}
	if not self:GetCaster():HasTalent("special_bonus_unique_naga_siren_song_of_the_siren_1") then
		state[MODIFIER_STATE_INVULNERABLE] = true
	end
	return statekil
end

function modifier_naga_siren_song_of_the_siren_song_sleep:GetEffectName()
	return "particles/units/heroes/hero_siren/naga_siren_song_debuff.vpcf"
end

function modifier_naga_siren_song_of_the_siren_song_sleep:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end