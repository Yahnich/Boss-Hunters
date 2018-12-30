pango_heart = class({})
LinkLuaModifier("modifier_pango_heart_handle", "heroes/hero_pango/pango_heart", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pango_heart_delay", "heroes/hero_pango/pango_heart", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pango_heart_debuff", "heroes/hero_pango/pango_heart", LUA_MODIFIER_MOTION_NONE)

function pango_heart:IsStealable()
	return false
end

function pango_heart:IsHiddenWhenStolen()
	return false
end

function pango_heart:GetIntrinsicModifierName()
	return "modifier_pango_heart_handle"
end

modifier_pango_heart_handle = class({})
function modifier_pango_heart_handle:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_pango_heart_handle:OnAttackLanded(params)
	if IsServer() then
		local caster = self:GetCaster()
		local attacker = params.attacker
		local target = params.target

		local chance = self:GetTalentSpecialValueFor("chance")

		if attacker == caster and self:RollPRNG(chance) then
			if not target:HasModifier("modifier_pango_heart_delay") then
				EmitSoundOn("Hero_Pangolier.HeartPiercer", target)
				ParticleManager:FireRopeParticle("particles/units/heroes/hero_pangolier/pangolier_luckyshot_disarm_cast.vpcf", PATTACH_POINT_FOLLOW, caster, target, {}, "attach_hitloc")
				target:AddNewModifier(caster, self:GetAbility(), "modifier_pango_heart_delay", {Duration = self:GetTalentSpecialValueFor("debuff_delay")})
			end
		end
	end
end

function modifier_pango_heart_handle:IsHidden()
	return true
end

modifier_pango_heart_delay = class({})

function modifier_pango_heart_delay:OnRemoved()
	if IsServer() then
		EmitSoundOn("Hero_Pangolier.HeartPiercer.Proc.Creep", self:GetParent())
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_pango_heart_debuff", {Duration = self:GetTalentSpecialValueFor("duration")})
	end
end

function modifier_pango_heart_delay:GetEffectName()
	return "particles/units/heroes/hero_pangolier/pangolier_heartpiercer_delay.vpcf"
end

function modifier_pango_heart_delay:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_pango_heart_delay:IsHidden()
	return true
end

modifier_pango_heart_debuff = class({})

function modifier_pango_heart_debuff:OnCreated()
	self.reduction = self:GetParent():GetPhysicalArmorValue() * self:GetTalentSpecialValueFor("armor_reduc")/100
	self.slow = self:GetTalentSpecialValueFor("slow_pct")
end

function modifier_pango_heart_debuff:OnRefresh(table)
	self.reduction = self:GetParent():GetPhysicalArmorValue() * self:GetTalentSpecialValueFor("armor_reduc")/100
	self.slow = self:GetTalentSpecialValueFor("slow_pct")
end

function modifier_pango_heart_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_pango_heart_debuff:GetModifierPhysicalArmorBonus()
	return self.reduction
end

function modifier_pango_heart_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_pango_heart_debuff:IsDebuff()
	return true
end

function modifier_pango_heart_debuff:GetEffectName()
	return "particles/units/heroes/hero_pangolier/pangolier_heartpiercer_debuff.vpcf"
end

function modifier_pango_heart_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end