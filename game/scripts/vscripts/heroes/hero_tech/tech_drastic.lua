tech_drastic = class({})

function tech_drastic:IsStealable()
	return true
end

function tech_drastic:IsHiddenWhenStolen()
	return false
end

function tech_drastic:GetChannelTime()
	return self:GetSpecialValueFor("delay_time")
end

function tech_drastic:GetChannelAnimation()
	return ACT_DOTA_VICTORY
end

function tech_drastic:OnSpellStart()
	EmitSoundOn("NukeBeep", self:GetCaster())
end

function tech_drastic:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()

	if not bInterrupted then
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(nfx, 1, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(nfx, 2, Vector(9999999999, 9999999999, 9999999999))
		ParticleManager:ReleaseParticleIndex(nfx)

		local nfx3 = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_suicide.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControl(nfx3, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(nfx3, 1, Vector(9999999999, 0, 0))
		ParticleManager:SetParticleControl(nfx3, 2, Vector(9999999999, 9999999999, 9999999999))
		ParticleManager:ReleaseParticleIndex(nfx3)

		local nfx4 = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_remote_mines_detonate.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControl(nfx4, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(nfx4, 1, Vector(9999999999, 9999999999, 9999999999))
		ParticleManager:ReleaseParticleIndex(nfx4)

		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {})
		for _,enemy in pairs(enemies) do
			StopSoundOn("NukeBeep", caster)
			EmitSoundOn("NukeExplosion", caster)

			if enemy:IsAlive() and not enemy:TriggerSpellAbsorb( self ) then
				self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
			end
		end
		CreateModifierThinker(caster, self, "modifier_drastic_fallout", {Duration = self:GetSpecialValueFor("fallout_duration")}, caster:GetAbsOrigin(), caster:GetTeam(), false)
	else
		StopSoundOn("NukeBeep", caster)
		self:RefundManaCost()
		self:EndCooldown()
	end
end

LinkLuaModifier( "modifier_drastic_fallout", "heroes/hero_tech/tech_drastic.lua", LUA_MODIFIER_MOTION_NONE )
modifier_drastic_fallout = ({})

function modifier_drastic_fallout:OnCreated(table)
	if IsServer() then
		self.nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_rot.vpcf", PATTACH_POINT, self:GetCaster())
		ParticleManager:SetParticleControl(self.nfx2, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.nfx2, 1, Vector(3500, 3500, 3500))
	end
end
function modifier_drastic_fallout:OnRemoved()
	if IsServer() then
		ParticleManager:DestroyParticle(self.nfx2, false)
	end
end

function modifier_drastic_fallout:IsAura()
	return true
end

function modifier_drastic_fallout:GetModifierAura()
	return "modifier_drastic_fallout_poison"
end

function modifier_drastic_fallout:GetAuraRadius()
	return -1
end

function modifier_drastic_fallout:GetAuraDuration()
	return 0.5
end

function modifier_drastic_fallout:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_drastic_fallout:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_drastic_fallout:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

LinkLuaModifier( "modifier_drastic_fallout_poison", "heroes/hero_tech/tech_drastic.lua", LUA_MODIFIER_MOTION_NONE )
modifier_drastic_fallout_poison = ({})
function modifier_drastic_fallout_poison:OnCreated(table)
	self.mSlow = self:GetCaster():FindTalentValue("special_bonus_unique_tech_drastic_2")
	self.aSlow = self:GetCaster():FindTalentValue("special_bonus_unique_tech_drastic_2", "as")
	if IsServer() then
		self.damage = self:GetTalentSpecialValueFor("max_health_damage")/100
		self:StartIntervalThink(1.0)
	end
end

function modifier_drastic_fallout_poison:OnIntervalThink()
	local damage = self:GetParent():GetMaxHealth() * self.damage
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, 0)
end

function modifier_drastic_fallout_poison:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_drastic_fallout_poison:GetModifierMoveSpeedBonus_Percentage()
	return self.mSlow
end

function modifier_drastic_fallout:GetModifierAttackSpeedBonus_Constant()
	return self.aSlow
end
