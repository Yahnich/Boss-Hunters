et_elder_spirit = class({})
LinkLuaModifier( "modifier_elder_spirit_check", "heroes/hero_et/et_elder_spirit.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_elder_spirit_check_out", "heroes/hero_et/et_elder_spirit.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_elder_spirit", "heroes/hero_et/et_elder_spirit.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_elder_spirit_enemy", "heroes/hero_et/et_elder_spirit.lua",LUA_MODIFIER_MOTION_NONE )

function et_elder_spirit:GetAbilityTextureName()
	if not self:GetCaster():HasModifier("modifier_elder_spirit_check") and self:GetLevel() > 0 then
		return "elder_titan_return_spirit"
	end

	return "elder_titan_ancestral_spirit"
end

function et_elder_spirit:IsStealable()
	return false
end

function et_elder_spirit:GetBehavior()
	if not self:GetCaster():HasModifier("modifier_elder_spirit_check") and self:GetLevel() > 0 then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	end
	return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
end

function et_elder_spirit:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function et_elder_spirit:GetIntrinsicModifierName()
	if not self:GetCaster():HasModifier("modifier_elder_spirit_check_out") then
		return "modifier_elder_spirit_check"
	end
end

function et_elder_spirit:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	EmitSoundOn("Hero_ElderTitan.AncestralSpirit.Cast", caster)

	if not self:GetCaster():HasModifier("modifier_elder_spirit_check") then
		StopSoundOn("Hero_ElderTitan.AncestralSpirit.Cast", caster)
		EmitSoundOn("Hero_ElderTitan.AncestralSpirit.Return", caster)

		self.spirit = false
		self.spiritPull = true
		self.truePull = true
		self:RefundManaCost()
		
		self:SetCooldown()
		caster:AddNewModifier(caster, self, "modifier_elder_spirit_check", {})
	else
		self.spirit = true
		self.spiritPull = false
		self.truePull = false

		if caster:HasTalent("special_bonus_unique_et_elder_spirit_2") then
			caster:AddNewModifier(caster, self, "modifier_elder_spirit_check_out", {})
		else
			caster:AddNewModifier(caster, self, "modifier_elder_spirit_check_out", {Duration = self:GetTalentSpecialValueFor("duration")})
		end

		ParticleManager:FireParticle("particles/units/heroes/hero_elder_titan/elder_titan_ancestral_spirit_cast.vpcf", PATTACH_POINT, caster, {[2] = point})
		
		caster:RemoveModifierByName("modifier_elder_spirit_check")
		local spirit = caster:CreateSummon("npc_elder_spirit", point)
		EmitSoundOn("Hero_ElderTitan.AncestralSpirit.Spawn", spirit)
		FindClearSpaceForUnit(spirit, point, true)
		if caster:FindAbilityByName("et_echo_stomp"):IsTrained() then
			spirit:AddAbility("et_echo_stomp"):SetLevel(caster:FindAbilityByName("et_echo_stomp"):GetLevel())
			spirit:FindAbilityByName("et_echo_stomp"):SetActivated(false)
		end
		if caster:FindAbilityByName("et_natural_order"):IsTrained() then
			spirit:AddAbility("et_natural_order"):SetLevel(caster:FindAbilityByName("et_natural_order"):GetLevel())
			--spirit:FindAbilityByName("et_natural_order"):SetActivated(false)
		end
		if caster:FindAbilityByName("et_earthbreaker"):IsTrained() then
			spirit:AddAbility("et_earthbreaker"):SetLevel(caster:FindAbilityByName("et_earthbreaker"):GetLevel())
			spirit:FindAbilityByName("et_earthbreaker"):SetActivated(false)
		end
		if caster:FindAbilityByName("et_earth_splitter"):IsTrained() then
			spirit:AddAbility("et_earth_splitter"):SetLevel(caster:FindAbilityByName("et_earth_splitter"):GetLevel())
			spirit:FindAbilityByName("et_earth_splitter"):SetActivated(false)
		end
		spirit:AddNewModifier(caster, self, "modifier_elder_spirit", {})
		spirit:SetBaseMoveSpeed(caster:GetIdealSpeed())
		
		self:EndCooldown()
	end
end

modifier_elder_spirit_check = class({})
function modifier_elder_spirit_check:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
    return funcs
end

function modifier_elder_spirit_check:GetModifierDamageOutgoing_Percentage()
    return self:GetTalentSpecialValueFor("bonus_damage")
end

function modifier_elder_spirit_check:GetEffectName()
    return "particles/units/heroes/hero_elder_titan/elder_titan_ancestral_spirit_buff.vpcf"
end

modifier_elder_spirit_check_out = class({})
function modifier_elder_spirit_check_out:OnRemoved()
	if IsServer() then
		self:GetAbility().spiritPull = true
		self:GetAbility().truePull = true
	end
end

function modifier_elder_spirit_check_out:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }
    return funcs
end

function modifier_elder_spirit_check_out:GetModifierSpellAmplify_Percentage()
    return self:GetTalentSpecialValueFor("bonus_damage")
end

function modifier_elder_spirit_check_out:IsDebuff()
	return true
end

function modifier_elder_spirit_check_out:IsPurgable()
	return false
end

modifier_elder_spirit = class({})
function modifier_elder_spirit:OnCreated(table)
    if IsServer() then
    	self:StartIntervalThink(FrameTime())
    end
end

function modifier_elder_spirit:OnRemoved(table)
    if IsServer() then
    	self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_elder_spirit_check", {})
    end
end


function modifier_elder_spirit:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()

	if self:GetAbility().spiritPull then
		local direction = CalculateDirection(parent, caster)
		local distance = CalculateDistance(parent, caster)
	

		parent:StartGesture(ACT_DOTA_FLAIL)
		self.distance = self.distance or distance
		if distance > 20 then
			parent:SetForwardVector(-direction)
			parent:SetAbsOrigin(parent:GetAbsOrigin() - direction * 20)
			self.distance = (self.distance or distance) - 20
			if self.distance <= 0 then
				FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
			end
		else
			FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
			caster:RemoveModifierByName("modifier_elder_spirit_check_out")
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_elder_spirit_check", {})
			self:GetAbility().spirit = false
			self.distance = nil
			if self:GetAbility():IsCooldownReady() then
				self:GetAbility():SetCooldown()
			end

			parent:AddNoDraw()
			parent:ForceKill(false)
		end
	end
end

function modifier_elder_spirit:CheckState()
	local state = { [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
					[MODIFIER_STATE_ATTACK_IMMUNE] = true,
					[MODIFIER_STATE_MAGIC_IMMUNE] = true,
					[MODIFIER_STATE_INVULNERABLE] = true,
					[MODIFIER_STATE_UNTARGETABLE] = true,
					[MODIFIER_STATE_NO_HEALTH_BAR] = true
					}
	return state
end

function modifier_elder_spirit:DeclareFunctions()
	return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
			MODIFIER_EVENT_ON_ABILITY_START,
			MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end

function modifier_elder_spirit:OnAbilityStart(params)
	if params.unit == self:GetCaster() and self:GetAbility().truePull then
		self:GetAbility().spiritPull = false
		self:GetParent():RemoveGesture(ACT_DOTA_FLAIL)
	end
end

function modifier_elder_spirit:OnAbilityExecuted(params)
	if params.unit == self:GetCaster() and self:GetAbility().truePull then
		if params.ability:GetAbilityName() == "et_earth_splitter" then
			Timers:CreateTimer(3.14, function()
				if self:IsNull() or self:GetAbility():IsNull() then return end
				self:GetAbility().spiritPull = true
			end)
		else
			self:GetAbility().spiritPull = true
		end
	end
end

function modifier_elder_spirit:GetModifierInvisibilityLevel()
	return 240
end

function modifier_elder_spirit:GetEffectName()
    return "particles/units/heroes/hero_elder_titan/elder_titan_ancestral_spirit_ambient.vpcf"
end

function modifier_elder_spirit:GetStatusEffectName()
    return "particles/status_fx/status_effect_ancestral_spirit.vpcf"
end

function modifier_elder_spirit:StatusEffectPriority()
    return 10
end

function modifier_elder_spirit:IsHidden()
	return true
end

function modifier_elder_spirit:IsAura()
    return true
end

function modifier_elder_spirit:GetAuraDuration()
    return 0.99
end

function modifier_elder_spirit:GetAuraRadius()
    return self:GetSpecialValueFor("radius")
end

function modifier_elder_spirit:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_elder_spirit:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_elder_spirit:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_elder_spirit:GetModifierAura()
    return "modifier_elder_spirit_enemy"
end

function modifier_elder_spirit:IsAuraActiveOnDeath()
    return false
end

modifier_elder_spirit_enemy = class({})
function modifier_elder_spirit_enemy:OnCreated(table)
	if IsServer() then
		self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self:GetTalentSpecialValueFor("damage") )
		self:StartIntervalThink(1.0)
	end
end

function modifier_elder_spirit_enemy:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self:GetTalentSpecialValueFor("dot") )
end

function modifier_elder_spirit_enemy:IsHidden()
	return true
end