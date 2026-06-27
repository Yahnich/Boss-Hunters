spectre_mercurial_form = class({})
--------------------------------------------------------------------------------

function spectre_mercurial_form:ShouldUseResources()
	return true
end

function spectre_mercurial_form:GetIntrinsicModifierName()
    return "modifier_spectre_mercurial_form_aura"
end

modifier_spectre_mercurial_form_buff = class({})
LinkLuaModifier( "modifier_spectre_mercurial_form_buff", "heroes/hero_spectre/spectre_mercurial_form.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function modifier_spectre_mercurial_form_buff:DeclareFunctions(params)
local funcs = {
    MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
    return funcs
end

--------------------------------------------------------------------------------

function modifier_spectre_mercurial_form_buff:OnCreated( kv )
    self:OnRefresh()
end

--------------------------------------------------------------------------------

function modifier_spectre_mercurial_form_buff:OnRefresh( kv )
	self.radius = self:GetSpecialValueFor("aura_radius")
    self.reflect = self:GetSpecialValueFor( "damage_reflection_pct" )
	self.max_range = self:GetSpecialValueFor( "max_radius" )
	self.min_range = self:GetSpecialValueFor( "min_radius" )
	
	self.cdr_health_cost = self:GetSpecialValueFor("cdr_health_cost")
	self.cooldown_reduction = self:GetSpecialValueFor("cooldown_reduction")
	
	self.active_reflection_pct = self:GetSpecialValueFor("active_reflection_pct")
	if self:GetParent() ~= self:GetCaster() then
		self.aura_benefit = self:GetSpecialValueFor("aura_benefit") / 100
		
		self.cooldown_reduction = self.cooldown_reduction * self.aura_benefit
		self.reflect = self.reflect * self.aura_benefit
	end
end

--------------------------------------------------------------------------------

function modifier_spectre_mercurial_form_buff:GetModifierIncomingDamage_Percentage(params)
	if HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) or self:GetParent():IsIllusion() then return end
    local hero = self:GetParent()
    local caster = self:GetCaster()
    local ability = self:GetAbility()
	local dmgtype = params.damage_type
	local attacker = params.attacker
	local reflect = self.reflect
	if hero:HasModifier("") then
	end
    local reflect_damage = reflect / 100
	if attacker and attacker:GetTeamNumber()  ~= hero:GetTeamNumber() then
		if hero:GetHealth() >= 1 then
			local enemies = hero:FindEnemyUnitsInRadius( hero:GetAbsOrigin(), self.max_range )
			local talent = hero:HasTalent("special_bonus_unique_spectre_mercurial_form_1")
			for _,unit in pairs(enemies) do
				local distance = (unit:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
				local dmgmod = math.min(1, math.max( 1 - (distance-self.min_range)/(self.max_range-self.min_range), 0.05 ) )
				local dmg = params.original_damage * reflect_damage
				local dmgBlocked = params.original_damage * (1-reflect_damage)
				
				if self.cdr_health_cost > 0 then
					local cdr = self.cooldown_reduction * dmgBlocked / self.cdr_health_cost
					for i = 0, hero:GetAbilityCount() - 1 do
						local ability = hero:GetAbilityByIndex( i )
						
						if ability and not ability:IsToggle() and not ability:IsCooldownReady() then
							ability:ModifyCooldown(-cdr)
						end
					end
				end
				ability:DealDamage( caster, unit, dmg*dmgmod, {damage_type = dmgtype, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION} )
				
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_spectre/spectre_dispersion.vpcf",PATTACH_POINT_FOLLOW,unit)
				ParticleManager:SetParticleControl(particle, 0, unit:GetAbsOrigin())
				ParticleManager:SetParticleControl(particle, 1, hero:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(particle)
			end
		end
	end
	return reflect * (-1)
end

function modifier_spectre_mercurial_form_buff:IsHidden()
	return self:GetCaster() == self:GetParent()
end

modifier_spectre_mercurial_form_aura = class(modifier_spectre_mercurial_form_buff)
LinkLuaModifier( "modifier_spectre_mercurial_form_aura", "heroes/hero_spectre/spectre_mercurial_form.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function modifier_spectre_mercurial_form_aura:IsAura()
	return self.radius > 0
end

--------------------------------------------------------------------------------

function modifier_spectre_mercurial_form_aura:GetModifierAura()
	return "modifier_spectre_mercurial_form_buff"
end

--------------------------------------------------------------------------------

function modifier_spectre_mercurial_form_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_spectre_mercurial_form_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------

function modifier_spectre_mercurial_form_aura:GetAuraRadius()
	return self.radius
end

function modifier_spectre_mercurial_form_aura:GetAuraDuration()
	return 0.5
end

--------------------------------------------------------------------------------
function modifier_spectre_mercurial_form_aura:IsPurgable()
    return false
end

function modifier_spectre_mercurial_form_aura:IsHidden()
	return true
end