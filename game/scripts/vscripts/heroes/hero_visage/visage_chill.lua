visage_chill = class({})
LinkLuaModifier( "modifier_visage_chill_buff", "heroes/hero_visage/visage_chill.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_visage_chill_debuff", "heroes/hero_visage/visage_chill.lua" ,LUA_MODIFIER_MOTION_NONE )

function visage_chill:IsStealable()
    return true
end

function visage_chill:IsHiddenWhenStolen()
    return false
end

function visage_chill:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local duration = self:GetTalentSpecialValueFor("duration")

	EmitSoundOn("Hero_Visage.GraveChill.Cast", caster)
	EmitSoundOn("Hero_Visage.GraveChill.Target", target)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_grave_chill_cast_beams.vpcf", PATTACH_POINT_FOLLOW, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nfx)
	if target:TriggerSpellAbsorb( self ) then return end
	caster:AddNewModifier(caster, self, "modifier_visage_chill_buff", {Duration = duration})
	local units = caster:FindAllUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE })
	for _,unit in pairs(units) do
		if unit:GetOwner() == caster and unit:GetUnitLabel() == "visage_familiars" then
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_grave_chill_cast_beams.vpcf", PATTACH_POINT_FOLLOW, unit)
			ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(nfx, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(nfx)
			
			unit:AddNewModifier(caster, self, "modifier_visage_chill_buff", {Duration = duration})
		end
	end
	target:AddNewModifier(caster, self, "modifier_visage_chill_debuff", {Duration = duration})
end

modifier_visage_chill_buff = class({})
function modifier_visage_chill_buff:OnCreated(table)
	local caster = self:GetCaster()

	self.bous_as = self:GetTalentSpecialValueFor("bonus_as")
	self.bonus_ms = self:GetTalentSpecialValueFor("bonus_ms")

	if IsServer() then
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_grave_chill_caster.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 2, caster, PATTACH_POINT_FOLLOW, "attach_wingtipL", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 3, caster, PATTACH_POINT_FOLLOW, "attach_wingtipR", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 4, caster, PATTACH_POINT_FOLLOW, "attach_tail_tip", caster:GetAbsOrigin(), true)
		
		self:AttachEffect(nfx)				
	end
end

function modifier_visage_chill_buff:OnRefresh(table)
	local caster = self:GetCaster()

	self.bous_as = self:GetTalentSpecialValueFor("bonus_as")
	self.bonus_ms = self:GetTalentSpecialValueFor("bonus_ms")
end

function modifier_visage_chill_buff:DeclareFunctions()
	return {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_visage_chill_buff:GetModifierAttackSpeedBonus()
	return self.bous_as
end

function modifier_visage_chill_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_ms
end

function modifier_visage_chill_buff:IsDebuff()
	return false
end

modifier_visage_chill_debuff = class({})
function modifier_visage_chill_debuff:OnCreated(table)
	local caster = self:GetCaster()

	self.bous_as = self:GetTalentSpecialValueFor("bonus_as")
	self.bonus_ms = self:GetTalentSpecialValueFor("bonus_ms")
	if caster:HasTalent("special_bonus_unique_visage_chill_1") then
		self.damage = caster:GetLevel() * caster:FindTalentValue("special_bonus_unique_visage_chill_1", "damage")
		self.evasion_growth = caster:FindTalentValue("special_bonus_unique_visage_chill_1", "evasion")
		self.evasion = self.evasion_growth
		self:StartIntervalThink(0.5)
	end
	if IsServer() then
		local parent = self:GetParent()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_grave_chill_tgt.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 2, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					
		self:AttachEffect(nfx)
	end
end

function modifier_visage_chill_debuff:OnRefresh(table)
	local caster = self:GetCaster()

	self.bous_as = -self:GetTalentSpecialValueFor("bonus_as")
	self.bonus_ms = -self:GetTalentSpecialValueFor("bonus_ms")

	if caster:HasTalent("special_bonus_unique_visage_chill_1") then
		self.damage = caster:GetLevel() * caster:FindTalentValue("special_bonus_unique_visage_chill_1", "damage")
		self.evasion_growth = caster:FindTalentValue("special_bonus_unique_visage_chill_1", "evasion")
		self.evasion = self.evasion_growth
	end
end

function modifier_visage_chill_debuff:OnIntervalThink()
	self.evasion = self.evasion + self.evasion_growth
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		ability:DealDamage(caster, parent, self.damage, {damage_type = DAMAGE_TYPE_MAGICAL}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
	end
end

function modifier_visage_chill_debuff:DeclareFunctions()
	return {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function modifier_visage_chill_debuff:GetModifierAttackSpeedBonus()
	return -self.bous_as
end

function modifier_visage_chill_debuff:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_visage_chill_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self.bonus_ms
end

function modifier_visage_chill_debuff:GetStatusEffectName()
	return "particles/units/heroes/hero_visage/status_effect_visage_chill_slow.vpcf"
end

function modifier_visage_chill_debuff:StatusEffectPriority()
	return 10
end

function modifier_visage_chill_debuff:IsDebuff()
	return true
end