furion_tree_jail = class({})
LinkLuaModifier( "modifier_furion_sprout_sleep_thinker", "heroes/hero_furion/furion_tree_jail.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_furion_sprout_sleep_aura", "heroes/hero_furion/furion_tree_jail.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_furion_sprout_sleep", "heroes/hero_furion/furion_tree_jail.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_entangle_enemy", "heroes/hero_furion/furion_entangle.lua",LUA_MODIFIER_MOTION_NONE )

function furion_tree_jail:IsStealable()
	return true
end

function furion_tree_jail:IsHiddenWhenStolen()
	return false
end

function furion_tree_jail:GetAOERadius()
	return self:GetTalentSpecialValueFor("tree_radius")
end

function furion_tree_jail:PiercesDisableResistance()
    return true
end

function furion_tree_jail:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	if self:GetCursorTarget() then
		local point = self:GetCursorTarget():GetAbsOrigin()
	end
	local duration = self:GetTalentSpecialValueFor("duration")
	local vision_range = self:GetTalentSpecialValueFor("vision_range")
	local trees = self:GetTalentSpecialValueFor("tree_count")
	local radius = self:GetTalentSpecialValueFor("tree_radius")
	local angle = math.pi/(trees/2)
	
	-- Creates 16 temporary trees at each 45 degree interval around the clicked point
	for i=1,trees do
		local position = Vector(point.x+radius*math.sin(angle), point.y+radius*math.cos(angle), point.z)
		CreateTempTree(position, duration)
		angle = angle + math.pi/(trees/2)
	end
	local dummy = caster:CreateDummy(point)
	dummy:AddNewModifier(caster, self, "modifier_furion_sprout_sleep_thinker", {duration = duration})
	-- Gives vision to the caster's team in a radius around the clicked point for the duration
	AddFOWViewer(caster:GetTeam(), point, vision_range, duration, false)
	local sprout = ParticleManager:CreateParticle("particles/units/heroes/hero_furion/furion_sprout.vpcf", PATTACH_ABSORIGIN, dummy)
		ParticleManager:SetParticleControl( sprout, 0, dummy:GetOrigin() )
	ParticleManager:ReleaseParticleIndex(sprout)
	EmitSoundOn("Hero_Furion.Sprout", dummy)
end


modifier_furion_sprout_sleep_thinker = class({})

function modifier_furion_sprout_sleep_thinker:OnCreated( kv )
	self.aura_radius = self:GetAbility():GetTalentSpecialValueFor( "sleep_radius" )
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_furion_sprout_sleep_thinker:OnIntervalThink()
	if self:GetCaster():FindAbilityByName("furion_entangle") and RollPercentage(self:GetCaster():FindAbilityByName("furion_entangle"):GetTalentSpecialValueFor("chance")) and self:GetCaster():HasTalent("special_bonus_unique_furion_tree_jail_1") then
		local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self.aura_radius, {})
		for _,enemy in pairs(enemies) do
			enemy:AddNewModifier(self:GetCaster(), self:GetCaster():FindAbilityByName("furion_entangle"), "modifier_entangle_enemy", {Duration = self:GetCaster():FindAbilityByName("furion_entangle"):GetTalentSpecialValueFor("duration")})
			break
		end
	end
end

function modifier_furion_sprout_sleep_thinker:OnDestroy( kv )
	if IsServer() then
		self:GetParent():RemoveSelf()
	end
end

function modifier_furion_sprout_sleep_thinker:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_furion_sprout_sleep_thinker:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_furion_sprout_sleep_thinker:GetModifierAura()
	return "modifier_furion_sprout_sleep_aura"
end

--------------------------------------------------------------------------------

function modifier_furion_sprout_sleep_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

--------------------------------------------------------------------------------

function modifier_furion_sprout_sleep_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

--------------------------------------------------------------------------------

function modifier_furion_sprout_sleep_thinker:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------
function modifier_furion_sprout_sleep_thinker:IsPurgable()
    return false
end

function modifier_furion_sprout_sleep_thinker:CheckState()
    local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true
	}
	return state
end

function modifier_furion_sprout_sleep_thinker:GetEffectName()
	return "particles/furion_sprout_sleep.vpcf"
end

modifier_furion_sprout_sleep_aura = class({})

function modifier_furion_sprout_sleep_aura:OnCreated()
	self.sleepDelay = self:GetAbility():GetTalentSpecialValueFor("sleep_delay")
	self.sleepDuration = self:GetAbility():GetTalentSpecialValueFor("sleep_duration")
	self.chokeDamage = self:GetAbility():GetTalentSpecialValueFor("damage") * self.sleepDelay
	if IsServer() then
		self:StartIntervalThink(self.sleepDelay)
	end
end

function modifier_furion_sprout_sleep_aura:OnRefresh()
	self.sleepDelay = self:GetAbility():GetTalentSpecialValueFor("sleep_delay")
	self.sleepDuration = self:GetAbility():GetTalentSpecialValueFor("sleep_duration")
	self.chokeDamage = self:GetAbility():GetTalentSpecialValueFor("damage") * self.sleepDelay
end

function modifier_furion_sprout_sleep_aura:OnIntervalThink()
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.chokeDamage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_furion_sprout_sleep", {duration = self.sleepDuration})
end

modifier_furion_sprout_sleep = class({})

function modifier_furion_sprout_sleep:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_TAKEDAMAGE
			}
	return funcs
end

function modifier_furion_sprout_sleep:OnTakeDamage(params)
	if IsServer() then
		if params.unit == self:GetParent() and params.inflictor ~= self:GetAbility() then
			if params.inflictor and params.inflictor:GetName() == "furion_entangle" then return end
			self:Destroy()
		end
	end
end

function modifier_furion_sprout_sleep:GetEffectName()
	return "particles/generic_gameplay/generic_sleep.vpcf"
end

function modifier_furion_sprout_sleep:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_furion_sprout_sleep:CheckState()
    local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end

function modifier_furion_sprout_sleep:IsHidden()
	return true
end