wk_reincarnation = class({})
LinkLuaModifier("modifier_wk_reincarnation", "heroes/hero_wraith_king/wk_reincarnation.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wk_reincarnation_wraith_form_buff", "heroes/hero_wraith_king/wk_reincarnation.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wk_reincarnation_wraith_form", "heroes/hero_wraith_king/wk_reincarnation.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wk_reincarnation_slow", "heroes/hero_wraith_king/wk_reincarnation.lua", LUA_MODIFIER_MOTION_NONE)

function wk_reincarnation:IsStealable()
    return false
end

function wk_reincarnation:IsHiddenWhenStolen()
    return false
end

function wk_reincarnation:GetManaCost(iLevel)
	local caster = self:GetCaster()
    local talent = "special_bonus_unique_wk_reincarnation_2"
    if caster:HasTalent( talent ) then return 0 end
    return 160
end

function wk_reincarnation:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    local caster = self:GetCaster()
    local talent = "special_bonus_unique_wk_reincarnation_2"
    if caster:HasTalent( talent ) then cooldown = cooldown + caster:FindTalentValue( talent ) end
    return cooldown
end

function wk_reincarnation:GetIntrinsicModifierName()
	return "modifier_wk_reincarnation"
end

modifier_wk_reincarnation =  class({})

function modifier_wk_reincarnation:OnCreated()    
		-- Ability properties
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()    
		self.particle_death = "particles/units/heroes/hero_skeletonking/wraith_king_reincarnate.vpcf"
		self.sound_death = "Hero_SkeletonKing.Reincarnate"
		self.sound_reincarnation = "Hero_SkeletonKing.Reincarnate.Stinger"
		self.sound_be_back = "Hero_WraithKing.IllBeBack"
		self.modifier_wraith = "modifier_wk_reincarnation_wraith_form"

		-- Ability specials
		self.reincarnate_delay = self.ability:GetTalentSpecialValueFor("reincarnate_time")        
		self.slow_radius = self.ability:GetTalentSpecialValueFor("radius")
		self.slow_duration = self.ability:GetTalentSpecialValueFor("duration")
		self.scepter_wraith_form_radius = self.ability:GetTalentSpecialValueFor("aura_radius")        

	if IsServer() then
		-- Set WK as immortal!
		self.can_die = false

		-- Start interval think
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_wk_reincarnation:IsHidden() 
	if self:GetParent() == self.caster then
		return true
	else
		return false
	end
end
function modifier_wk_reincarnation:IsPurgable() return false end
function modifier_wk_reincarnation:IsDebuff() return false end

function modifier_wk_reincarnation:OnIntervalThink()
	-- If caster has sufficent mana and the ability is ready, apply
	if self.ability:IsOwnersManaEnough() and self.ability:IsCooldownReady() then
		self.can_die = false
	else
		self.can_die = true
	end
end

function modifier_wk_reincarnation:OnRefresh()
	self:OnCreated()
end

function modifier_wk_reincarnation:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_REINCARNATION,                      
					  MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
					  MODIFIER_EVENT_ON_DEATH,
					  MODIFIER_PROPERTY_RESPAWNTIME_STACKING}

	return decFuncs
end

function modifier_wk_reincarnation:ReincarnateTime()
	if IsServer() then  
		if not self.can_die and self.caster:IsRealHero() then
			self:GetCaster():EmitSound("Hero_SkeletonKing.Reincarnate")
			return self.reincarnate_delay
		end

		return nil
	end
end

function modifier_wk_reincarnation:GetActivityTranslationModifiers()
	if self.reincarnation_death then
		return "reincarnate"
	end

	return nil
end

function modifier_wk_reincarnation:OnDeath(keys)
	if IsServer() then
		local unit = keys.unit
		local reincarnate = keys.reincarnate
		
		if unit == self.caster and self.ability:IsCooldownReady() and self.ability:IsOwnersManaEnough() then
			self.ability:UseResources(true, false, true)
			unit:EmitSound("Hero_SkeletonKing.Reincarnate.Stinger")
			local enemies = self.caster:FindEnemyUnitsInRadius(self.caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
			for _,enemy in pairs(enemies) do
				enemy:AddNewModifier(self.caster, self.ability, "modifier_wk_reincarnation_slow", {Duration = self:GetTalentSpecialValueFor("duration")})
				
				if self.caster:HasTalent("special_bonus_unique_wk_reincarnation_1") then
					self.caster:FindAbilityByName("wk_blast"):FireBlast(enemy)
				end
			end
		end
	end
end

-- WRAITH FORM AURA FUNCTIONS
function modifier_wk_reincarnation:GetAuraRadius()
	return self.scepter_wraith_form_radius
end

function modifier_wk_reincarnation:GetAuraEntityReject(target)
	-- Aura ignores everyone that are already under the effects of Wraith Form 
	if target:HasModifier(self.modifier_wraith) then
		return true 
	end

	if target == self:GetCaster() then
		return true 
	end

	return false    
end

function modifier_wk_reincarnation:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO
end

function modifier_wk_reincarnation:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_wk_reincarnation:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_wk_reincarnation:GetModifierAura()
	return "modifier_wk_reincarnation_wraith_form_buff"
end

function modifier_wk_reincarnation:IsAura()
	if self.caster:IsRealHero() and self.caster:HasScepter() and self.caster == self:GetParent() then
		return true        
	end

	return false
end


-- Wraith Form modifier (given from aura, not yet Wraith Form)
modifier_wk_reincarnation_wraith_form_buff = modifier_wk_reincarnation_wraith_form_buff or class({})

function modifier_wk_reincarnation_wraith_form_buff:OnCreated()
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	self.modifier_wraith_form = "modifier_wk_reincarnation_wraith_form"

	-- Ability specials    
	self.scepter_wraith_form_duration = self.ability:GetTalentSpecialValueFor("scepter_duration")
end

function modifier_wk_reincarnation_wraith_form_buff:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MIN_HEALTH,
					  MODIFIER_EVENT_ON_TAKEDAMAGE}

	return decFuncs
end

function modifier_wk_reincarnation_wraith_form_buff:GetMinHealth()
	return 1
end

function modifier_wk_reincarnation_wraith_form_buff:OnTakeDamage(keys)
	if IsServer() then
		local attacker = keys.attacker
		local target = keys.unit 
		local damage = keys.damage

		-- Only apply if the unit taking damage is the parent
		if self.parent == target then
			
			-- Check if the damage is fatal 
			if damage >= self.parent:GetHealth() then

				-- Check if this unit has Reincarnation and it is ready: if so, kill the unit normally
				if self.parent:HasAbility(self.ability:GetAbilityName()) then
					local reincarnation_ability = self.parent:FindAbilityByName(self.ability:GetAbilityName())
					if reincarnation_ability then
						if reincarnation_ability:IsOwnersManaEnough() and reincarnation_ability:IsCooldownReady() then
							self:Destroy()
							self.parent:AttemptKill(self.ability, target)
							return nil
						end
					end
				end
				self.parent:EmitSound("Hero_SkeletonKing.Reincarnate.Ghost")
				self.parent:AddNewModifier(self.caster, self.ability, self.modifier_wraith_form, {duration = self.scepter_wraith_form_duration})              
			end
		end
	end
end

-- Wraith Form (actual Wraith Form)
modifier_wk_reincarnation_wraith_form = class({})

function modifier_wk_reincarnation_wraith_form:OnCreated()
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	if IsServer() then
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_ghosts_ambient.vpcf", PATTACH_POINT_FOLLOW, self.parent)
					ParticleManager:SetParticleControlEnt(nfx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		self:AttachEffect(nfx)

		self:StartIntervalThink(0.1)
	end
	self:SetStackCount(math.floor(self:GetDuration() + 0.5))
end

function modifier_wk_reincarnation_wraith_form:IsHidden() return false end
function modifier_wk_reincarnation_wraith_form:IsDebuff() return false end
function modifier_wk_reincarnation_wraith_form:IsPurgable() return false end

function modifier_wk_reincarnation_wraith_form:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
					  MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
					  MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
					  MODIFIER_PROPERTY_DISABLE_HEALING,
					  MODIFIER_PROPERTY_MODEL_SCALE}
	return decFuncs
end

function modifier_wk_reincarnation_wraith_form:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_wk_reincarnation_wraith_form:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_wk_reincarnation_wraith_form:GetAbsoluteNoDamagePure()
	return 1
end

function modifier_wk_reincarnation_wraith_form:GetDisableHealing()
	return 1
end

function modifier_wk_reincarnation_wraith_form:GetModifierModelScale()
	return 40
end

function modifier_wk_reincarnation_wraith_form:OnIntervalThink()
	if not IsServer() then
		return
	end
	self:SetStackCount(math.floor(self:GetRemainingTime() + 0.5))
end

function modifier_wk_reincarnation_wraith_form:CheckState()
	local state = {[MODIFIER_STATE_NO_HEALTH_BAR] = true,
				   [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
				   [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
	return state
end

function modifier_wk_reincarnation_wraith_form:OnRemoved()
	if IsServer() then
		self.ability:DealDamage(self.parent, self.parent, self.parent:GetMaxHealth(), {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY}, 0)
	end
end

function modifier_wk_reincarnation_wraith_form:GetStatusEffectName()
	return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
end

function modifier_wk_reincarnation_wraith_form:StatusEffectPriority()
	return 10
end

function modifier_wk_reincarnation_wraith_form:IsDebuff()
	return false
end

modifier_wk_reincarnation_slow = class({})
function modifier_wk_reincarnation_slow:IsDebuff()
    return true
end

function modifier_wk_reincarnation_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        
    }
    return funcs
end

function modifier_wk_reincarnation_slow:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("slow_ms")
end

function modifier_wk_reincarnation_slow:GetModifierAttackSpeedBonus()
    return self:GetTalentSpecialValueFor("slow_as")
end