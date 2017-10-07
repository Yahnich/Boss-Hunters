wraith_one_for_all = class({})

function wraith_one_for_all:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_wraith_all_for_one") then
		return "custom/wraith_all_for_one"
	else
		return "custom/wraith_one_for_all"
	end
end

function wraith_one_for_all:ResetToggleOnRespawn()
	return false
end

function wraith_one_for_all:GetIntrinsicModifierName()
	local caster = self:GetCaster()
	if not caster:HasModifier("modifier_wraith_one_for_all_scepter_passive") then caster:AddNewModifier(caster, self, "modifier_wraith_one_for_all_scepter_passive", {}) end
	if not caster:HasModifier("modifier_wraith_one_for_all") and not caster:HasModifier("modifier_wraith_all_for_one") then
		return "modifier_wraith_one_for_all"
	elseif caster:HasModifier("modifier_wraith_all_for_one") then
		return "modifier_wraith_all_for_one"
	else
		return "modifier_wraith_one_for_all"
	end
end

function wraith_one_for_all:OnSpellStart( bForce )
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_wraith_one_for_all") then
		caster:RemoveModifierByName("modifier_wraith_one_for_all")
		caster:AddNewModifier(caster, self, "modifier_wraith_all_for_one", {}) 
	else
		caster:RemoveModifierByName("modifier_wraith_all_for_one")
		caster:AddNewModifier(caster, self, "modifier_wraith_one_for_all", {})
	end
end

modifier_wraith_one_for_all = class({})
LinkLuaModifier("modifier_wraith_one_for_all", "heroes/wraith/wraith_one_for_all.lua", 0)


function modifier_wraith_one_for_all:GetTexture()
	return "custom/wraith_one_for_all"
end

function modifier_wraith_one_for_all:OnCreated()
	self.damage_redirection = self:GetSpecialValueFor("damage_redirection")
	self.hp_steal = self:GetSpecialValueFor("hp_steal")
	self.aura_radius = self:GetSpecialValueFor("aura_radius")
end

function modifier_wraith_one_for_all:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_wraith_one_for_all:GetModifierAura()
	return "modifier_wraith_one_for_all_aura"
end

--------------------------------------------------------------------------------

function modifier_wraith_one_for_all:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_wraith_one_for_all:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_wraith_one_for_all:GetAuraEntityReject( entity )
	return self:GetCaster() == entity
end

--------------------------------------------------------------------------------

function modifier_wraith_one_for_all:GetAuraRadius()
	return self.aura_radius
end

function modifier_wraith_one_for_all:IsAuraActiveOnDeath()
	return false
end

--------------------------------------------------------------------------------
function modifier_wraith_one_for_all:IsPurgable()
    return false
end

function modifier_wraith_one_for_all:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_wraith_one_for_all:GetEffectName()
	return "particles/heroes/wraith/wraith_one_for_all.vpcf"
end

function modifier_wraith_one_for_all:RemoveOnDeath()
	return false
end

function modifier_wraith_one_for_all:IsPermanent()
	return true
end

function modifier_wraith_one_for_all:IsPermanent()
	return true
end

modifier_wraith_one_for_all_aura = class({})
LinkLuaModifier("modifier_wraith_one_for_all_aura", "heroes/wraith/wraith_one_for_all.lua", 0)

function modifier_wraith_one_for_all_aura:GetTexture()
	return "custom/wraith_one_for_all"
end

function modifier_wraith_one_for_all_aura:OnCreated()
	self.damage_redirection = self:GetSpecialValueFor("damage_redirection")
	self.hp_steal = self:GetSpecialValueFor("hp_steal") / 100
	self.heal_amp = self:GetSpecialValueFor("talent_heal_amp")
end

function modifier_wraith_one_for_all_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE}
end

function modifier_wraith_one_for_all_aura:GetModifierIncomingDamage_Percentage(params)
	if IsServer() and params.unit ~= self:GetCaster() and not self:GetCaster():HasModifier("modifier_wraith_all_for_one") and not self:GetParent():IsIllusion() and not HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) then
		local spread = math.abs(params.damage * self.damage_redirection) / 100
		local hp = math.abs(params.damage / self:GetParent():GetMaxHealth() * (self.damage_redirection / 100)) * self:GetCaster():GetMaxHealth()
		local damage = math.ceil( math.min(spread, hp) )
		ParticleManager:FireRopeParticle("particles/heroes/wraith/wraith_all_for_one_damage.vpcf", PATTACH_POINT_FOLLOW, self:GetParent(), self:GetCaster())
		ApplyDamage({attacker = params.attacker, victim = self:GetCaster(), damage = damage, damage_type = params.damage_type, ability = params.inflictor, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_REFLECTION})
		return self.damage_redirection
	end
end

function modifier_wraith_one_for_all_aura:GetModifierHealAmplify_Percentage()
	if self:GetCaster():HasTalent("wraith_one_for_all_talent_1") then
		return self.heal_amp
	end
end

function modifier_wraith_one_for_all_aura:OnHealRedirect(params)
	if params.target == self:GetParent() then
		local redirectedHeal = math.abs(params.amount*self.hp_steal)
		self:GetCaster():HealEvent(redirectedHeal, params.source, params.healer)
		ParticleManager:FireRopeParticle("particles/heroes/wraith/wraith_all_for_one_steal.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), self:GetParent())
		return -redirectedHeal
	end
end

function modifier_wraith_one_for_all_aura:GetEffectName()
	return "particles/heroes/wraith/wraith_one_for_all.vpcf"
end


modifier_wraith_all_for_one = class({})
LinkLuaModifier("modifier_wraith_all_for_one", "heroes/wraith/wraith_one_for_all.lua", 0)

function modifier_wraith_all_for_one:GetTexture()
	return "custom/wraith_all_for_one"
end

function modifier_wraith_all_for_one:OnCreated()
	self.damage_redirection = self:GetSpecialValueFor("damage_redirection")
	self.aura_radius = self:GetSpecialValueFor("aura_radius")
	self.heal_amp = self:GetSpecialValueFor("talent_heal_amp")
end

function modifier_wraith_all_for_one:OnDestroy()
	if IsServer() then
		if not self:GetParent():IsAlive() then
			local ability = self:GetAbility()
			Timers:CreateTimer(function()
				ability:ToggleAbility()
			end)
		end
	end
end

function modifier_wraith_all_for_one:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_wraith_all_for_one:GetModifierAura()
	return "modifier_wraith_all_for_one_aura"
end

--------------------------------------------------------------------------------

function modifier_wraith_all_for_one:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_wraith_all_for_one:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_wraith_all_for_one:GetAuraEntityReject( entity )
	return self:GetCaster() == entity
end
--------------------------------------------------------------------------------

function modifier_wraith_all_for_one:GetAuraRadius()
	return self.aura_radius
end

function modifier_wraith_all_for_one:IsAuraActiveOnDeath()
	return false
end


function modifier_wraith_all_for_one:RemoveOnDeath()
	return false
end


function modifier_wraith_all_for_one:IsPermanent()
	return true
end

--------------------------------------------------------------------------------
function modifier_wraith_all_for_one:IsPurgable()
    return false
end

function modifier_wraith_all_for_one:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_EVENT_ON_DEATH, MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE}
end

function modifier_wraith_all_for_one:GetModifierHealAmplify_Percentage()
	if self:GetCaster():HasTalent("wraith_one_for_all_talent_1") then
		return self.heal_amp
	end
end

function modifier_wraith_all_for_one:GetModifierIncomingDamage_Percentage(params)
	if IsServer() and not self:GetCaster():HasModifier("modifier_wraith_one_for_all") and not self:GetParent():IsIllusion() and not HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) then
		local allies = self:GetParent():FindFriendlyUnitsInRadius( self:GetParent():GetAbsOrigin(), self.aura_radius )
		local filteredAllies = {}
		for _, ally in ipairs(allies) do
			if ally ~= self:GetParent() and ally:GetUnitName() ~= "npc_dota_courier" and not self:GetParent():IsIllusion() then table.insert(filteredAllies, ally) end
		end
		local allyCount = #filteredAllies
		if allyCount > 0 then
			local allyPct = math.abs(self.damage_redirection / allyCount) / 100
			local spreadDamage = params.damage * allyPct
			local damagePct = params.damage / self:GetParent():GetMaxHealth()
			for _, ally in ipairs(filteredAllies) do
				local altSpread = math.abs(damagePct * ally:GetMaxHealth() * allyPct / 100)
				local damage = math.ceil(math.min(altSpread, spreadDamage))
				ParticleManager:FireRopeParticle("particles/heroes/wraith/wraith_all_for_one_damage.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), ally)
				ApplyDamage({attacker = params.attacker, victim = ally, damage = damage, damage_type = params.damage_type, ability = params.inflictor, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_REFLECTION})
			end
			return self.damage_redirection
		end
	end
end

function modifier_wraith_all_for_one:GetEffectName()
	return "particles/heroes/wraith/wraith_all_for_one.vpcf"
end

modifier_wraith_all_for_one_aura = class({})
LinkLuaModifier("modifier_wraith_all_for_one_aura", "heroes/wraith/wraith_one_for_all.lua", 0)

function modifier_wraith_all_for_one_aura:OnCreated()
	self.hp_steal = self:GetSpecialValueFor("hp_steal") / 100
end

function modifier_wraith_all_for_one_aura:GetTexture()
	return "custom/wraith_all_for_one"
end

function modifier_wraith_all_for_one_aura:GetEffectName()
	return "particles/heroes/wraith/wraith_all_for_one.vpcf"
end

function modifier_wraith_all_for_one_aura:OnHealRedirect(params)
	if params.target == self:GetCaster() then
		local redirectedHeal = math.abs(params.amount*self.hp_steal)
		self:GetParent():HealEvent(redirectedHeal, params.source, params.healer)
		ParticleManager:FireRopeParticle("particles/heroes/wraith/wraith_all_for_one_steal.vpcf", PATTACH_POINT_FOLLOW, self:GetParent(), self:GetCaster())
		return -redirectedHeal
	end
end

modifier_wraith_one_for_all_scepter = class({})
LinkLuaModifier("modifier_wraith_one_for_all_scepter", "heroes/wraith/wraith_one_for_all.lua", 0)

if IsServer() then
	function modifier_wraith_one_for_all_scepter:OnCreated()
		EmitSoundOn("Hero_SkeletonKing.Reincarnate.Ghost", self:GetParent())
	end
	
	function modifier_wraith_one_for_all_scepter:OnDestroy()
		self:GetParent():Kill(self:GetAbility(), self:GetParent())
	end
end

function modifier_wraith_one_for_all_scepter:GetEffectName()
	return "particles/units/heroes/hero_skeletonking/wraith_king_ghosts_ambient.vpcf"
end

function modifier_wraith_one_for_all_scepter:GetStatusEffectName()
	return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
end

function modifier_wraith_one_for_all_scepter:StatusEffectPriority()
	return 50
end

function modifier_wraith_one_for_all_scepter:DeclareFunctions()
	return {MODIFIER_PROPERTY_MIN_HEALTH}
end

function modifier_wraith_one_for_all_scepter:GetMinHealth()
	return 1
end



modifier_wraith_one_for_all_scepter_passive = class({})
LinkLuaModifier("modifier_wraith_one_for_all_scepter_passive", "heroes/wraith/wraith_one_for_all.lua", 0)

function modifier_wraith_one_for_all_scepter_passive:IsHidden()
	return true
end

function modifier_wraith_one_for_all_scepter_passive:IsPermanent()
	return true
end

function modifier_wraith_one_for_all_scepter_passive:RemoveOnDeath()
	return false
end

function modifier_wraith_one_for_all_scepter_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_wraith_one_for_all_scepter_passive:OnDeath(params)
	if params.unit:IsSameTeam(self:GetParent()) 
	and CalculateDistance(params.unit, self:GetParent()) < 900 
	and self:GetCaster():HasScepter() 
	and not params.unit:HasModifier("modifier_wraith_one_for_all_scepter_cooldown") 
	and not params.unit:IsIllusion()
	and not params.unit:WillReincarnate() then
		local position = params.unit:GetAbsOrigin()
		Timers:CreateTimer(function()
			params.unit:RespawnHero(false, false, false)
			FindClearSpaceForUnit(params.unit, position, true)
			params.unit:SetHealth(1)
			params.unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_wraith_one_for_all_scepter", {duration = self:GetSpecialValueFor("scepter_duration")})
			params.unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_wraith_one_for_all_scepter_cooldown", {duration = self:GetSpecialValueFor("scepter_cooldown")})
		end)
	end
end

modifier_wraith_one_for_all_scepter_cooldown = class({})
LinkLuaModifier("modifier_wraith_one_for_all_scepter_cooldown", "heroes/wraith/wraith_one_for_all.lua", 0)

function modifier_wraith_one_for_all_scepter_cooldown:IsHidden()
	return false
end

function modifier_wraith_one_for_all_scepter_cooldown:RemoveOnDeath()
	return false
end

function modifier_wraith_one_for_all_scepter_cooldown:IsPurgable()
	return false
end