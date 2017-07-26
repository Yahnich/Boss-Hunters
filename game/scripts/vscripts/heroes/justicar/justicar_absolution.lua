justicar_absolution = class({})

function justicar_absolution:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	EmitSoundOn("Hero_Omniknight.GuardianAngel", target)
	target:AddNewModifier(caster, self, "modifier_justicar_absolution_buff", {duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_justicar_absolution_buff = class({})
LinkLuaModifier("modifier_justicar_absolution_buff", "heroes/justicar/justicar_absolution.lua", 0)

if IsServer() then
	function modifier_justicar_absolution_buff:OnCreated(kv)
		self.damagereduction = self:GetAbility():GetTalentSpecialValueFor("damage_reduction") * (-1)
		self.debuffreduction = self:GetAbility():GetSpecialValueFor("debuff_reduction") * (-1)
		self.innersun = self:GetCaster():GetInnerSun()
		self:GetCaster():ResetInnerSun()
		self.healovertime = (self:GetAbility():GetSpecialValueFor("heal_over_time") + self.innersun) / 100
		if IsServer() then self:StartIntervalThink(0.3) end
	end

	function modifier_justicar_absolution_buff:OnRefresh(kv)
		self.damagereduction = self:GetAbility():GetTalentSpecialValueFor("damage_reduction") * (-1)
		self.debuffreduction = self:GetAbility():GetSpecialValueFor("debuff_reduction") * (-1)
		self.innersun = self.innersun + self:GetCaster():GetInnerSun()
		self:GetCaster():ResetInnerSun()
		self.healovertime = (self:GetAbility():GetSpecialValueFor("heal_over_time") + self.innersun) / 100
	end
	
	function modifier_justicar_absolution_buff:OnIntervalThink()
		self:GetParent():HealEvent(self.healovertime * self:GetParent():GetMaxHealth() + (self.innersun / self:GetDuration()) * 0.3, self:GetAbility(), self:GetCaster())
	end

	function modifier_justicar_absolution_buff:DeclareFunctions()
		local funcs = {
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		}
		return funcs
	end
	
	function modifier_justicar_absolution_buff:BonusDebuffDuration_Constant()
		return self.debuffreduction
	end

	function modifier_justicar_absolution_buff:GetModifierIncomingDamage_Percentage(params)
		if self:GetCaster():HasTalent("justicar_absolution_talent_1") then
			self:GetAbility():DealDamage(self:GetCaster(), params.attacker, params.damage * self.damagereduction)
		end
		return self.damagereduction
	end
end

function modifier_justicar_absolution_buff:GetEffectName()
	return "particles/heroes/justicar/justicar_absolution.vpcf"
end