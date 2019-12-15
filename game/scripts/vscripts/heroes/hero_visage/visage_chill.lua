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
	target:AddNewModifier(caster, self, "modifier_visage_chill_debuff", {Duration = duration})
end

modifier_visage_chill_buff = class({})
function modifier_visage_chill_buff:OnCreated(table)
	local caster = self:GetCaster()

	self.bous_as = self:GetTalentSpecialValueFor("bonus_as")
	self.bonus_ms = self:GetTalentSpecialValueFor("bonus_ms")

	if caster:HasTalent("special_bonus_unique_visage_chill_2") then
		self.bous_as = self.bous_as + 50
		self.bonus_ms = self.bonus_ms + 50 
	end

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

	if caster:HasTalent("special_bonus_unique_visage_chill_2") then
		self.bous_as = self.bous_as + 50
		self.bonus_ms = self.bonus_ms + 50 
	end
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

	if caster:HasTalent("special_bonus_unique_visage_chill_2") then
		self.bous_as = self.bous_as + 50
		self.bonus_ms = self.bonus_ms + 50 
	end

	if IsServer() then
		local parent = self:GetParent()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_grave_chill_tgt.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 2, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					
		self:AttachEffect(nfx)

		if caster:HasTalent("special_bonus_unique_visage_chill_1") then
			self.damage = caster:GetIntellect() * caster:FindTalentValue("special_bonus_unique_visage_chill_1", "int")/100
			self.chill_amount = caster:FindTalentValue("special_bonus_unique_visage_chill_1", "chill_amount")

			self:StartIntervalThink(1)
		end
	end
end

function modifier_visage_chill_debuff:OnRefresh(table)
	local caster = self:GetCaster()

	self.bous_as = -self:GetTalentSpecialValueFor("bonus_as")
	self.bonus_ms = -self:GetTalentSpecialValueFor("bonus_ms")

	if caster:HasTalent("special_bonus_unique_visage_chill_2") then
		self.bous_as = self.bous_as + 50
		self.bonus_ms = self.bonus_ms + 50 
	end

	if IsServer() then
		if caster:HasTalent("special_bonus_unique_visage_chill_1") then
			self.damage = caster:GetIntellect() * caster:FindTalentValue("special_bonus_unique_visage_chill_1", "int")/100
			self.chill_amount = caster:FindTalentValue("special_bonus_unique_visage_chill_1", "chill_amount")
		end
	end
end

function modifier_visage_chill_debuff:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()

		parent:AddChill(ability, caster, self:GetDuration(), self.chill_amount)
		ability:DealDamage(caster, parent, self.damage, {damage_type = DAMAGE_TYPE_MAGICAL}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
	end
end

function modifier_visage_chill_debuff:DeclareFunctions()
	return {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_visage_chill_debuff:GetModifierAttackSpeedBonus()
	return -self.bous_as
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