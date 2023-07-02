spectre_dispersion_bh = class({})
--------------------------------------------------------------------------------

function spectre_dispersion_bh:GetCooldown(iLvl)
	if self:GetCaster():HasTalent("special_bonus_unique_spectre_dispersion_2") then
		return self:GetCaster():FindTalentValue("special_bonus_unique_spectre_dispersion_2", "cd")
	else
		return 0
	end
end

function spectre_dispersion_bh:ShouldUseResources()
	return true
end

function spectre_dispersion_bh:GetIntrinsicModifierName()
    return "modifier_spectre_dispersion_aura"
end

modifier_spectre_dispersion_aura = class({})
LinkLuaModifier( "modifier_spectre_dispersion_aura", "heroes/hero_spectre/spectre_dispersion_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_spectre_dispersion_aura:OnCreated()
	-- self.radius = self:GetCaster():FindTalentValue("special_bonus_unique_spectre_dispersion_2")
end

function modifier_spectre_dispersion_aura:OnRefresh()
	-- self.radius = self:GetCaster():FindTalentValue("special_bonus_unique_spectre_dispersion_2")
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_aura:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_aura:GetModifierAura()
	return "modifier_spectre_dispersion_buff"
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_aura:GetAuraRadius()
	return self.radius
end

function modifier_spectre_dispersion_aura:GetAuraDuration()
	return 0.5
end

--------------------------------------------------------------------------------
function modifier_spectre_dispersion_aura:IsPurgable()
    return false
end

function modifier_spectre_dispersion_aura:IsHidden()
	return true
end



modifier_spectre_dispersion_buff = class({})
LinkLuaModifier( "modifier_spectre_dispersion_buff", "heroes/hero_spectre/spectre_dispersion_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function modifier_spectre_dispersion_buff:DeclareFunctions(params)
local funcs = {
    MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
    return funcs
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_buff:OnCreated( kv )
    self:OnRefresh()
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_buff:OnRefresh( kv )
    self.reflect = self:GetAbility():GetSpecialValueFor( "damage_reflection_pct" )
	self.max_range = self:GetAbility():GetSpecialValueFor( "max_radius" )
	self.min_range = self:GetAbility():GetSpecialValueFor( "min_radius" )
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_spectre_dispersion_1")
	self.talent1DmgThreshold = self:GetCaster():FindTalentValue("special_bonus_unique_spectre_dispersion_1")
	self.talent1CDR = self:GetCaster():FindTalentValue("special_bonus_unique_spectre_dispersion_1", "value2")
	
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_spectre_dispersion_2")
	self.talent2DmgThreshold = self:GetCaster():FindTalentValue("special_bonus_unique_spectre_dispersion_2")
	self.talent2DmgBlocked = self.talent2DmgBlocked or 0
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_buff:GetModifierIncomingDamage_Percentage(params)
	if HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) or self:GetParent():IsIllusion() then return end
    local hero = self:GetParent()
    local ability = self:GetAbility()
	local dmgtype = params.damage_type
	local attacker = params.attacker
    local reflect_damage = self.reflect / 100
	if attacker and attacker:GetTeamNumber()  ~= hero:GetTeamNumber() then
		if hero:GetHealth() >= 1 then
			local enemies = hero:FindEnemyUnitsInRadius( hero:GetAbsOrigin(), self.max_range )
			local talent = hero:HasTalent("special_bonus_unique_spectre_dispersion_1")
			for _,unit in pairs(enemies) do
				local distance = (unit:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
				local dmgmod = math.min(1, math.max( 1 - (distance-self.min_range)/(self.max_range-self.min_range), 0.05 ) )
				local dmg = params.original_damage * reflect_damage
				local dmgBlocked = params.original_damage * (1-reflect_damage)
				
				if self.talent1 then
					local cdr = self.talent1CDR * dmgBlocked / self.talent1DmgThreshold
					for i = 0, hero:GetAbilityCount() - 1 do
						local ability = hero:GetAbilityByIndex( i )
						
						if ability and not ability:IsToggle() and not ability:IsCooldownReady() then
							ability:ModifyCooldown(-cdr)
						end
					end
				end
				
				if self.talent2 then
					self.talent2DmgBlocked = self.talent2DmgBlocked + dmgBlocked
					if self.talent2DmgBlocked > self.talent2DmgThreshold and ability:IsCooldownReady() then
						ability:SetCooldown()
						self.talent2DmgBlocked = 0
						local dagger = hero:FindAbilityByName("spectre_spectral_dagger_bh")
						if dagger and dagger:GetLevel() > 0 then
							dagger:LaunchSpectralDagger( attacker:GetAbsOrigin() )
						end
					end
				end
			
				ability:DealDamage( hero, unit, dmg*dmgmod, {damage_type = dmgtype, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION} )
				
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_spectre/spectre_dispersion.vpcf",PATTACH_POINT_FOLLOW,unit)
				ParticleManager:SetParticleControl(particle, 0, unit:GetAbsOrigin())
				ParticleManager:SetParticleControl(particle, 1, hero:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(particle)
			end
		end
	end
	return self.reflect * (-1)
end

function modifier_spectre_dispersion_buff:IsHidden()
	return self:GetCaster() == self:GetParent()
end