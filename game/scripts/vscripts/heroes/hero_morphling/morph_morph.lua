morph_morph = class({})
LinkLuaModifier( "modifier_morph_morph", "heroes/hero_morphling/morph_morph.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_morph_morph_water", "heroes/hero_morphling/morph_morph.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_morph_morph_clone", "heroes/hero_morphling/morph_morph.lua" ,LUA_MODIFIER_MOTION_NONE )

function morph_morph:IsStealable()
    return true
end

function morph_morph:IsHiddenWhenStolen()
    return false
end

function morph_morph:GetBehavior()
    if self:GetCaster():HasModifier("modifier_morph_morph") then
    	return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function morph_morph:OnAbilityPhaseStart()
	local caster = self:GetCaster()
    if caster:HasModifier("modifier_morph_morph") then
    	self.nfx1 = ParticleManager:CreateParticle("particles/econ/items/kunkka/divine_anchor/hero_kunkka_dafx_skills/kunkka_spell_torrent_bubbles_fxset.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(self.nfx1, 0, caster:GetAbsOrigin())
    	
    	if self.clone and self.clone:IsAlive() then
			local pos = self.clone:GetAbsOrigin()
			self.nfx2 = ParticleManager:CreateParticle("particles/econ/items/kunkka/divine_anchor/hero_kunkka_dafx_skills/kunkka_spell_torrent_bubbles_fxset.vpcf", PATTACH_POINT, caster)
						ParticleManager:SetParticleControl(self.nfx2, 0, pos)
		end
	end
    return true
end

function morph_morph:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_Morphling.Replicate", caster)

	if caster:HasModifier("modifier_morph_morph") then

		EmitSoundOn("Hero_Morphling.ReplicateEnd", caster)

		ParticleManager:ClearParticle(self.nfx1)
		ParticleManager:ClearParticle(self.nfx2)

		self:Torrent(caster:GetAbsOrigin())		

		if self.clone and self.clone:IsAlive() then
			local pos = self.clone:GetAbsOrigin()
			self.clone:ForceKill(false)

			ProjectileManager:ProjectileDodge(caster)

			if caster:HasTalent("special_bonus_unique_morph_morph_1") then
				caster:HealEvent(caster:GetMaxHealth(), self, caster, false)
			end

			FindClearSpaceForUnit(caster, pos, false)
			self:Torrent(pos)
		end
		caster:RemoveModifierByName("modifier_morph_morph")
	else
		local duration = self:GetTalentSpecialValueFor("duration")
		local outgoing = self:GetTalentSpecialValueFor("outgoing")
		local incoming = self:GetTalentSpecialValueFor("incoming")

		EmitSoundOn("Hero_Morphling.Replicate", caster)

		self.clone = target:ConjureImage( target:GetAbsOrigin(), duration, outgoing, incoming, "", self, true, caster )
		FindClearSpaceForUnit(self.clone, self.clone:GetAbsOrigin(), true)
		caster:AddNewModifier(caster, self, "modifier_morph_morph", {Duration = duration})
		self.clone:AddNewModifier(caster, self, "modifier_morph_morph", {Duration = duration})

		if caster:HasTalent("special_bonus_unique_morph_morph_2") then
			self.clone:AddNewModifier(caster, self, "modifier_morph_morph_water", {})
		end

		self:EndCooldown()
	end
end

function morph_morph:Torrent(vLocation)
	local caster = self:GetCaster()
	local radius = self:GetTalentSpecialValueFor("radius")

	local damage = caster:GetStrength() + caster:GetAgility()

	local nfx = ParticleManager:CreateParticle("particles/econ/items/kunkka/divine_anchor/hero_kunkka_dafx_skills/kunkka_spell_torrent_splash_fxset.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(nfx, 0, vLocation)
				ParticleManager:ReleaseParticleIndex(nfx)

	local enemies = caster:FindEnemyUnitsInRadius(vLocation, radius)
	for _,enemy in pairs(enemies) do
		enemy:ApplyKnockBack(enemy:GetAbsOrigin(), 1, 1, 0, 300, caster, self, true)
		self:DealDamage(caster, enemy, damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	end
end

modifier_morph_morph = class({})

function modifier_morph_morph:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local clones = caster:FindAllUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
		for _,clone in pairs(clones) do
			if clone and clone:HasModifier("modifier_morph_morph") then
				clone:RemoveModifierByName("modifier_morph_morph")
				if clone:IsIllusion() then
					clone:ForceKill(false)
				end
				self:GetAbility():SetCooldown()
			end
		end
	end
end

function modifier_morph_morph:CheckState()
	local state = {	[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	if self:GetParent():IsIllusion() then
		return state
	end
end

function modifier_morph_morph:IsHidden()
	return true
end

modifier_morph_morph_water = class({})
function modifier_morph_morph_water:IsAura()
    return true
end

function modifier_morph_morph_water:GetAuraDuration()
    return 0.5
end

function modifier_morph_morph_water:GetAuraRadius()
    return 500
end

function modifier_morph_morph_water:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_morph_morph_water:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_morph_morph_water:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_morph_morph_water:GetModifierAura()
    return "modifier_in_water"
end

function modifier_morph_morph_water:IsAuraActiveOnDeath()
    return false
end

function modifier_morph_morph_water:IsHidden()
    return true
end

modifier_morph_morph_clone = class({})
function modifier_morph_morph_clone:DeclareFunctions()
	return {MODIFIER_PROPERTY_SUPER_ILLUSION,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_ILLUSION  }
end

function modifier_morph_morph_clone:GetModifierSuperIllusion()
	return 1
end

function modifier_morph_morph_clone:GetModifierSuperIllusion()
	return 1
end

function modifier_morph_morph_clone:IsHidden()
	return true
end