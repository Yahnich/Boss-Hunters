enchantress_attendants = class({})
LinkLuaModifier("modifier_enchantress_attendants", "heroes/hero_enchantress/enchantress_attendants", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_enchantress_attendants_fake", "heroes/hero_enchantress/enchantress_attendants", LUA_MODIFIER_MOTION_NONE)

function enchantress_attendants:IsStealable()
    return true
end

function enchantress_attendants:IsHiddenWhenStolen()
    return false
end

function enchantress_attendants:GetBehavior()
    if self:GetCaster():HasScepter() then
    	return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_TOGGLE
    end
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function enchantress_attendants:GetManaCost(iLevel)
	if self:GetCaster():HasScepter() then
    	return 0
    end
    return self.BaseClass.GetManaCost( self, iLevel )
end

function enchantress_attendants:OnSpellStart()
	local caster = self:GetCaster()

	local duration = self:GetTalentSpecialValueFor("duration")
	local count = self:GetTalentSpecialValueFor("count")

	caster:AddNewModifier(caster, self, "modifier_enchantress_attendants_fake", {Duration = duration})

	for i=1,count do
		caster:AddNewModifier(caster, self, "modifier_enchantress_attendants", {Duration = duration})
	end

	self:StartDelayedCooldown()
end

function enchantress_attendants:OnToggle()
	local caster = self:GetCaster()

	local duration = self:GetTalentSpecialValueFor("duration")
	local count = self:GetTalentSpecialValueFor("count")

	if caster:HasModifier("modifier_enchantress_attendants_fake") or caster:HasModifier("modifier_enchantress_attendants") then
		caster:RemoveModifierByName("modifier_enchantress_attendants_fake")
		for i=1,count do
			caster:RemoveModifierByName("modifier_enchantress_attendants")
		end
	else
		caster:AddNewModifier(caster, self, "modifier_enchantress_attendants_fake", {})

		for i=1,count do
			caster:AddNewModifier(caster, self, "modifier_enchantress_attendants", {})
		end
	end
	
end

modifier_enchantress_attendants_fake = class({})
function modifier_enchantress_attendants_fake:OnCreated(table)
	EmitSoundOn("Hero_Enchantress.NaturesAttendantsCast", self:GetParent())
	if self:GetParent():HasScepter() and IsServer() then
		self:StartIntervalThink(0.03)
	end
end

function modifier_enchantress_attendants_fake:OnIntervalThink()
	local caster = self:GetCaster()
	if caster:GetMana() >= caster:GetMaxMana() * (self:GetTalentSpecialValueFor("scepter_mana_cost")/100) * 0.03 then
		caster:SpendMana(caster:GetMaxMana() * (self:GetTalentSpecialValueFor("scepter_mana_cost")/100) * 0.03, self:GetAbility())
	else
		self:ToggleAbility()
	end
end

function modifier_enchantress_attendants_fake:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_Enchantress.NaturesAttendantsCast", self:GetParent())
	end
end

function modifier_enchantress_attendants_fake:IsDebuff()
	return false
end

modifier_enchantress_attendants = class({})
function modifier_enchantress_attendants:OnCreated(table)
	if IsServer() then
		local parent = self:GetParent()

		self.radius = self:GetTalentSpecialValueFor("radius")
		self.heal = self:GetTalentSpecialValueFor("heal")

		self.pWispy =   ParticleManager:CreateParticle("particles/units/heroes/hero_enchantress/enchantress_natures_attendants_heal_wispc.vpcf", PATTACH_POINT, parent)
						ParticleManager:SetParticleControlEnt(self.pWispy, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)

		self:AttachEffect(self.pWispy)

		self:StartIntervalThink(1)
	end
end

function modifier_enchantress_attendants:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()

	if caster:HasTalent("special_bonus_unique_enchantress_attendants_1") then
		local enemies = parent:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.radius)
		for _,enemy in pairs(enemies) do
			self:GetAbility():DealDamage(caster, enemy, self.heal, {damage_type = DAMAGE_TYPE_PURE}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		end
	end
	ParticleManager:SetParticleControlEnt(self.pWispy, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	local allies = parent:FindFriendlyUnitsInRadius(parent:GetAbsOrigin(), self.radius)
	for _,ally in pairs(allies) do
		if ally:GetHealth() < ally:GetMaxHealth() then
			ParticleManager:SetParticleControlEnt(self.pWispy, 0, ally, PATTACH_POINT_FOLLOW, "attach_hitloc", ally:GetAbsOrigin(), true)
			ally:HealEvent(self.heal, self:GetAbility(), caster, false)
			break
		end
	end
end

function modifier_enchantress_attendants:OnRemoved()
	if IsServer() then
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_enchantress_attendants:IsDebuff()
	return false
end

function modifier_enchantress_attendants:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_enchantress_attendants:IsHidden()
	return true
end

function modifier_enchantress_attendants:IsPurgable()
	return not self:GetCaster():HasScepter()
end