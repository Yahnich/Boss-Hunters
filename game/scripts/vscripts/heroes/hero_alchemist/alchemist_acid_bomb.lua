alchemist_acid_bomb = class({})

function alchemist_acid_bomb:IsStealable()
	return true
end

function alchemist_acid_bomb:IsHiddenWhenStolen()
	return false
end

function alchemist_acid_bomb:Precache(context)
	PrecacheResource( "model", "models/heroes/alchemist/alchemist_leftbottle.vmdl", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_alchemist/alchemist_acid_bomb_projectile.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_alchemist.vsndevts", context )
end

function alchemist_acid_bomb:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function alchemist_acid_bomb:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local dummy = self:CreateDummy( position, 0.5 )
	self:FireTrackingProjectile("particles/units/heroes/hero_alchemist/alchemist_acid_bomb_projectile.vpcf", dummy, CalculateDistance( position, caster ) / 0.2 )
end

function alchemist_acid_bomb:OnProjectileHit( target, position )
	if not target then return end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    local affect_allies = self:GetSpecialValueFor("affect_allies") > 0

    CreateModifierThinker(caster, self, "modifier_alchemist_acid_bomb_thinker", { duration = duration }, position, caster:GetTeamNumber(), false)
	-- cleanup
end

modifier_alchemist_acid_bomb_thinker = class({})
LinkLuaModifier( "modifier_alchemist_acid_bomb_thinker", "heroes/hero_alchemist/alchemist_acid_bomb", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_acid_bomb_thinker:OnCreated()
    self:OnRefresh()
	if IsClient() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	for _, unit in ipairs( caster:FindAllUnitsInRadius( self:GetParent():GetAbsOrigin(), self.radius, {team = self.target_team} ) ) do
		if unit:IsSameTeam( caster ) then
			unit:HealEvent( self.damage * self.panacea_heal, ability, caster )
		else
			ability:DealDamage( caster, unit, self.damage )
		end
		if self.alkahest_duration > 0 then
			unit:AddNewModifier( caster, ability, "modifier_alchemist_acid_bomb_alkahest", {duration = self.alkahest_duration} )
		end
	end
	 -- particles
    local particle = "particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf"
    local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(effect, 0, self:GetParent():GetOrigin())
    ParticleManager:SetParticleControl(effect, 1, Vector(self.radius, 1, self.radius))
    self:AddEffect(effect)

    -- sounds
    local sound = "Hero_Alchemist.AcidSpray"
    EmitSoundOn(sound, self:GetParent())
end
function modifier_alchemist_acid_bomb_thinker:OnRefresh()
    self.radius = self:GetSpecialValueFor("radius")
    self.damage = self:GetSpecialValueFor("damage")
    self.linger_duration = self:GetSpecialValueFor("linger_duration")
	
	self.panacea_heal = self:GetSpecialValueFor("panacea_heal") / 100
	self.alkahest_duration = self:GetSpecialValueFor("alkahest_duration")
	
    self.target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	if self.panacea_heal > 0 then
		self.target_team = DOTA_UNIT_TARGET_TEAM_BOTH
	end
end
function modifier_alchemist_acid_bomb_thinker:IsAura()
    return true
end
function modifier_alchemist_acid_bomb_thinker:GetModifierAura()
    return "modifier_alchemist_acid_bomb_aura"
end
function modifier_alchemist_acid_bomb_thinker:GetAuraRadius()
    return self.radius
end
function modifier_alchemist_acid_bomb_thinker:GetAuraDuration()
    return self.linger_duration
end
function modifier_alchemist_acid_bomb_thinker:GetAuraSearchTeam()
    return self.target_team
end
function modifier_alchemist_acid_bomb_thinker:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HEROES_AND_CREEPS
end

function modifier_alchemist_acid_bomb_thinker:IsHidden()
    return true
end
function modifier_alchemist_acid_bomb_thinker:IsPurgable()
    return false
end

modifier_alchemist_acid_bomb_aura = class({})
LinkLuaModifier( "modifier_alchemist_acid_bomb_aura", "heroes/hero_alchemist/alchemist_acid_bomb", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_acid_bomb_aura:OnCreated()
    self:OnRefresh()
    
    if IsClient() then return end
    self:StartIntervalThink( self.tick_rate )
end

function modifier_alchemist_acid_bomb_aura:OnRefresh()
    self.armor_reduction = self:GetSpecialValueFor("armor_reduction")
    self.damage_per_sec = self:GetSpecialValueFor("damage_per_sec")
    self.tick_rate = self:GetSpecialValueFor("tick_rate")
	
    self.panacea_armor = self:GetSpecialValueFor("panacea_armor") / 100
    self.panacea_heal = self:GetSpecialValueFor("panacea_heal") / 100
    self.armor_loss_per_sec = self:GetSpecialValueFor("armor_loss_per_sec")
	self.heal_per_sec = 0
	
	self.sign = -1
	
	if self:GetCaster():IsSameTeam( self:GetParent() ) then 
		self.sign = 1 * self.panacea_armor
		self.heal_per_sec = self.damage_per_sec * self.panacea_heal
		self.damage_per_sec = 0
	end
end

function modifier_alchemist_acid_bomb_aura:OnIntervalThink()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	if self.damage_per_sec <= 0 and self.heal_per_sec > 0 then
		parent:HealEvent( self.heal_per_sec * self.tick_rate, ability, caster )
	else
		ability:DealDamage( caster, parent, self.damage_per_sec * self.tick_rate )
	end
end

function modifier_alchemist_acid_bomb_aura:DeclareFunctions()
    return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_alchemist_acid_bomb_aura:GetModifierPhysicalArmorBonus()
    return ( self.armor_reduction + math.floor( self:GetElapsedTime() * self.armor_loss_per_sec ) ) * self.sign
end

modifier_alchemist_acid_bomb_alkahest = class(modifier_alchemist_acid_bomb_aura)
LinkLuaModifier( "modifier_alchemist_acid_bomb_alkahest", "heroes/hero_alchemist/alchemist_acid_bomb", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_acid_bomb_alkahest:GetModifierPhysicalArmorBonus()
    return self.armor_reduction
end