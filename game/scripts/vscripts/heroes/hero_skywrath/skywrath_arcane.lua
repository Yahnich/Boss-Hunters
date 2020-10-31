skywrath_arcane = class({})

function skywrath_arcane:GetIntrinsicModifierName()
	return "modifier_skywrath_arcane"
end

function skywrath_arcane:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
end

function skywrath_arcane:GetAOERadius()
	return self:GetCaster():FindTalentValue("special_bonus_unique_skywrath_arcane_1", "radius")
end

function skywrath_arcane:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	EmitSoundOn("Hero_SkywrathMage.ArcaneBolt.Cast", caster)
	local vision = self:GetTalentSpecialValueFor("vision")
	local speed = self:GetTalentSpecialValueFor("speed")
	self:FireTrackingProjectile("particles/units/heroes/hero_skywrath_mage/skywrath_mage_arcane_bolt.vpcf", target, speed, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, vision)

    if caster:HasScepter() then
        local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTrueCastRange())
        for _,enemy in pairs(enemies) do
            if enemy ~= target then
                self:FireTrackingProjectile("particles/units/heroes/hero_skywrath_mage/skywrath_mage_arcane_bolt.vpcf", enemy, speed, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, speed)
                break
            end
        end
    end
	
	if caster:HasTalent("special_bonus_unique_skywrath_arcane_1") then
		Timers:CreateTimer( caster:FindTalentValue("special_bonus_unique_skywrath_arcane_1"), function()
			local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTrueCastRange())
			for _,enemy in pairs(enemies) do
				self:FireTrackingProjectile("particles/units/heroes/hero_skywrath_mage/skywrath_mage_arcane_bolt.vpcf", enemy, speed, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, speed)
				break
			end
		end)
	end
	
	if caster:HasTalent("special_bonus_unique_skywrath_arcane_2") then
		caster:AddNewModifier(caster, self, "modifier_skywrath_arcane_talent", {duration = caster:FindTalentValue("special_bonus_unique_skywrath_arcane_2", "duration")})
	end
end

function skywrath_arcane:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()

    if hTarget and not hTarget:TriggerSpellAbsorb( self ) then
        EmitSoundOn("Hero_SkywrathMage.ArcaneBolt.Impact", hTarget)
        local baseDamage = self:GetTalentSpecialValueFor("damage")
        self:DealDamage(caster, hTarget, baseDamage)
    end
end

modifier_skywrath_arcane = class({})
LinkLuaModifier("modifier_skywrath_arcane", "heroes/hero_skywrath/skywrath_arcane", LUA_MODIFIER_MOTION_NONE)

function modifier_skywrath_arcane:OnCreated(table)
	self.int_modifier = self:GetTalentSpecialValueFor("int_multiplier") / 100
end

function modifier_skywrath_arcane:DeclareFunctions()
	return { MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, 
			 MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE}
end


function modifier_skywrath_arcane:GetModifierOverrideAbilitySpecial(params)
	if params.ability == self:GetAbility() then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "damage" then
			return 1
		end
	end
end

function modifier_skywrath_arcane:GetModifierOverrideAbilitySpecialValue(params)
	if params.ability == self:GetAbility() then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "damage" then
			local flBaseValue = params.ability:GetLevelSpecialValueNoOverride( specialValue, params.ability_special_level )
			return flBaseValue + math.floor( caster:GetIntellect() * self.int_modifier + 0.5 )
		end
	end
end

function modifier_skywrath_arcane:IsHidden()
	return true
end

modifier_skywrath_arcane_talent = class({})
LinkLuaModifier("modifier_skywrath_arcane_talent", "heroes/hero_skywrath/skywrath_arcane", LUA_MODIFIER_MOTION_NONE)

function modifier_skywrath_arcane_talent:OnCreated()
	self:OnRefresh()
end

function modifier_skywrath_arcane_talent:OnRefresh()
	self.reflect = self:GetCaster():FindTalentValue("special_bonus_unique_skywrath_arcane_2")
	self.stacks = self:GetCaster():FindTalentValue("special_bonus_unique_skywrath_arcane_2", "stacks")
	if IsServer() then
		self:AddIndependentStack( self:GetRemainingTime(), self.stacks )
	end
	self:GetParent():HookInModifier("GetModifierDamageReflectPercentageBonus", self)
end

function modifier_skywrath_arcane_talent:OnDestroy()
	self:GetParent():HookOutModifier("GetModifierDamageReflectPercentageBonus", self)
end

function modifier_skywrath_arcane_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_skywrath_arcane_talent:GetModifierDamageReflectPercentageBonus(params)
	ParticleManager:FireRopeParticle( "particles/econ/events/ti10/maelstrom_ti10.vpcf", PATTACH_POINT_FOLLOW, params.unit, params.attacker )
	return self.reflect
end

function modifier_skywrath_arcane_talent:GetModifierIncomingDamage_Percentage()
	return -self.reflect
end

function modifier_skywrath_arcane_talent:GetEffectName()
	return "particles/units/heroes/hero_skywrath_mage/skywrath_mage_arcane_bolt_talent.vpcf"
end