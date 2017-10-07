forest_envelop = class({})

function forest_envelop:CastFilterResultTarget(target)
	local caster = self:GetCaster()
	if caster ~= target and not target:HasModifier("modifier_forest_envelop_self") and not target:HasModifier("modifier_forest_envelop_target") then
		return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, caster:GetTeamNumber())
	else
		return UF_FAIL_CUSTOM
	end
end

function forest_envelop:GetCustomCastErrorTarget(target)
	return "Skill cannot target caster or enveloped/enveloping units."
end


function forest_envelop:GetBehavior()
	if not self:GetCaster():HasModifier("modifier_forest_envelop_self") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	end
end

function forest_envelop:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if self:GetCaster():HasModifier("modifier_forest_envelop_self") then
		caster:RemoveModifierByName("modifier_forest_envelop_self")
		EmitSoundOn("Hero_Furion.Teleport_Disappear", caster)
	else
		EmitSoundOn("Hero_Furion.Sprout", caster)
		caster:AddNewModifier(caster, self, "modifier_forest_envelop_self", {})
		self:EndCooldown()
	end
end

modifier_forest_envelop_self = class({})
LinkLuaModifier("modifier_forest_envelop_self", "heroes/forest/forest_envelop.lua", 0)


function modifier_forest_envelop_self:OnCreated()
	self.cdr = self:GetSpecialValueFor("cooldown_reduction")
	if IsServer() then
		self.parentUnit = self:GetAbility():GetCursorTarget()
		self.parentUnit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_forest_envelop_target", {})
		self:GetParent():SetAbsOrigin(self.parentUnit:GetAbsOrigin())
		self:StartIntervalThink(0.03)
		if self:GetParent():HasTalent("forest_envelop_talent_1") then self:SetStackCount(self.parentUnit:GetMaxHealth()) end
	end
end

function modifier_forest_envelop_self:IsHidden()
	return true
end

function modifier_forest_envelop_self:OnIntervalThink()
	if not self.parentUnit:IsAlive() then self:Destroy() end
	if self:GetParent():HasTalent("forest_envelop_talent_1") then self:SetStackCount(self.parentUnit:GetMaxHealth()) end
	if CalculateDistance(self:GetParent(), self.parentUnit) < 300 then
		self:GetParent():SetAbsOrigin(self.parentUnit:GetAbsOrigin())
	else
		self.parentUnit:SetAbsOrigin(self:GetParent():GetAbsOrigin())
	end
end

function modifier_forest_envelop_self:OnDestroy()
	if IsServer() then self.parentUnit:RemoveModifierByName("modifier_forest_envelop_target") end
end

function modifier_forest_envelop_self:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_DISARMED] = true,
	}
end

function modifier_forest_envelop_self:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MODEL_SCALE}
end

function modifier_forest_envelop_self:GetModifierModelScale()
	return -35
end

function modifier_forest_envelop_self:GetModifierPercentageCooldownStacking()
	return self.cdr
end

function modifier_forest_envelop_self:GetModifierHealthBonus()
	return self:GetStackCount()
end

modifier_forest_envelop_target = class({})
LinkLuaModifier("modifier_forest_envelop_target", "heroes/forest/forest_envelop.lua", 0)

function modifier_forest_envelop_target:OnCreated()
	self.armor = self:GetCaster():GetPhysicalArmorValue()
	self.armorToAlly = self:GetSpecialValueFor("armor_to_ally") / 100
	self:StartIntervalThink(1)
end

function modifier_forest_envelop_target:OnDestroy()
	if IsServer() then self:GetAbility():UseResources(false, false, true) end
end



function modifier_forest_envelop_target:OnIntervalThink()
	self.armor = self:GetCaster():GetPhysicalArmorValue()
end

function modifier_forest_envelop_target:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_forest_envelop_target:GetModifierIncomingDamage_Percentage(params)
	if not HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) then
		local damage = params.original_damage
		if params.damage_type == DAMAGE_TYPE_PHYSICAL then
			damage = params.damage / (100 - self:GetCaster():GetPhysicalArmorReduction())/100
		elseif params.damage_type == DAMAGE_TYPE_MAGICAL then
			damage = params.damage / (1 - self:GetCaster():GetMagicalArmorValue())
		end
		ApplyDamage({victim = self:GetCaster(), attacker = params.attacker, damage = damage, damage_type = params.damage_type, ability = params.inflictor, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION})
		return -1000
	else
		return -1000
	end
end
function modifier_forest_envelop_target:GetModifierPhysicalArmorBonus()
	return self.armor * self.armorToAlly
end