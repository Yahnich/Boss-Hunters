morph_morph = class({})
LinkLuaModifier( "modifier_morph_morph", "heroes/hero_morphling/morph_morph.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_morph_morph_water", "heroes/hero_morphling/morph_morph.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_morph_morph_clone", "heroes/hero_morphling/morph_morph.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_morph_morph_scepter", "heroes/hero_morphling/morph_morph.lua" ,LUA_MODIFIER_MOTION_NONE )

function morph_morph:OnInventoryContentsChanged()
	local caster = self:GetCaster()
	if caster:HasScepter() then
		caster:AddNewModifier( caster, self, "modifier_morph_morph_scepter", {} )
	else
		caster:RemoveModifierByName( "modifier_morph_morph_scepter" )
	end
end

function morph_morph:GetIntrinsicModifierName()
    if self:GetCaster():HasScepter() then
		return "modifier_morph_morph_scepter"
	end
end

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
		local duration = self:GetSpecialValueFor("duration")
		local outgoing = self:GetSpecialValueFor("outgoing") - 100
		local incoming = self:GetSpecialValueFor("incoming") - 100

		EmitSoundOn("Hero_Morphling.Replicate", caster)
		local illusions = target:ConjureImage( {outgoing_damage = outgoing, incoming_damage = incoming}, duration, caster, 1 )
		FindClearSpaceForUnit(illusions[1], illusions[1]:GetAbsOrigin(), true)
		local duration = self:GetSpecialValueFor("duration")
		caster:AddNewModifier(caster, self, "modifier_morph_morph", {Duration = duration})
		illusions[1]:AddNewModifier(caster, self, "modifier_morph_morph", {Duration = duration})

		if caster:HasTalent("special_bonus_unique_morph_morph_2") then
			illusions[1]:AddNewModifier(caster, self, "modifier_morph_morph_water", {})
		end
		self.clone = illusions[1]
		
		if caster:HasScepter() then
			illusions[1]:AddNewModifier(caster, self, "modifier_morph_morph_scepter", {})
		end
		self:EndCooldown()
	end
end

function morph_morph:Torrent(vLocation)
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")

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
		self:GetAbility():SetCooldown()
		local clones = caster:FindAllUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
		for _,clone in pairs(clones) do
			if clone and clone:HasModifier("modifier_morph_morph") then
				clone:RemoveModifierByName("modifier_morph_morph")
				if clone:IsIllusion() then
					clone:ForceKill(false)
				end
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

modifier_morph_morph_scepter = class({})
function modifier_morph_morph_scepter:OnCreated()
	self.evasion = self:GetSpecialValueFor("scepter_evasion")
	self.radius = self:GetSpecialValueFor("scepter_radius")
	self.duration = self:GetSpecialValueFor("scepter_duration")
	self.damage = (self:GetSpecialValueFor("scepter_damage") / 100) * 0.25
	if IsServer() then
		self:StartIntervalThink(0.25)
	end
end

function modifier_morph_morph_scepter:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
		ability:DealDamage( caster, enemy, caster:GetPrimaryStatValue() * self.damage, {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
	end
end

function modifier_morph_morph_scepter:IsAura()
    return true
end

function modifier_morph_morph_scepter:GetAuraDuration()
    return 5
end

function modifier_morph_morph_scepter:GetAuraRadius()
    return 150
end

function modifier_morph_morph_scepter:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_morph_morph_scepter:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_morph_morph_scepter:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_morph_morph_scepter:CheckState()
	local state = {	[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	return state
end

function modifier_morph_morph_scepter:DeclareFunctions()
	local state = {MODIFIER_PROPERTY_EVASION_CONSTANT}
	return state
end

function modifier_morph_morph_scepter:GetModifierEvasion_Constant()
    return self.evasion
end

function modifier_morph_morph_scepter:GetModifierAura()
    return "modifier_in_water"
end

function modifier_morph_morph_scepter:IsAuraActiveOnDeath()
    return false
end

function modifier_morph_morph_scepter:IsHidden()
    return true
end