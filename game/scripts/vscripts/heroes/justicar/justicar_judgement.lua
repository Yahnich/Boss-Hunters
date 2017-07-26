justicar_judgement = class({})

function justicar_judgement:CastFilterResultTarget(target)
	if IsServer() then
		if not target:IsSameTeam( self:GetCaster() ) then return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeam() ) end
		if target == self:GetCaster() then return UF_SUCCESS end
		if target ~= self:GetCaster() and self:GetCaster():HasTalent("justicar_judgement_talent_1") then
			return UF_SUCCESS
		else
			return UF_FAIL_CUSTOM
		end
	end
end

function justicar_judgement:GetCustomCastErrorTarget(target)
	return "Cannot be cast on allies without talent"
end

function justicar_judgement:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	target:AddNewModifier(caster, self, "modifier_justicar_judgement_buff", {duration = self:GetTalentSpecialValueFor("duration")})
	EmitSoundOn("Hero_Omniknight.GuardianAngel.Cast", caster)
end

modifier_justicar_judgement_buff = class({})
LinkLuaModifier("modifier_justicar_judgement_buff", "heroes/justicar/justicar_judgement.lua", 0)

if IsServer() then
	function modifier_justicar_judgement_buff:OnCreated()
		self.damageheal = self:GetAbility():GetTalentSpecialValueFor("damage_to_heal") / 100
		self.reflect = self:GetAbility():GetTalentSpecialValueFor("reflect_damage")
	end

	function modifier_justicar_judgement_buff:OnRefresh()
		self.damageheal = self:GetAbility():GetTalentSpecialValueFor("damage_to_heal") / 100
		self.reflect = self:GetAbility():GetTalentSpecialValueFor("reflect_damage")
	end

	function modifier_justicar_judgement_buff:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
		}
		return funcs
	end

	function modifier_justicar_judgement_buff:OnTakeDamage(params)
		if params.unit == self:GetParent() and params.damage > params.unit:GetMaxHealth() * 0.005 then
			self.healvalue = (self.healvalue or 0) + params.damage * self.damageheal
			self:GetAbility():DealDamage(self:GetParent(), params.attacker, self.reflect + self:GetCaster():GetInnerSun())
			self:GetCaster():ResetInnerSun()
		end
	end

	function modifier_justicar_judgement_buff:OnDestroy()
		if self.healvalue then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_justicar_judgement_heal", {duration = self:GetAbility():GetTalentSpecialValueFor("heal_duration"), heal = self.healvalue})
		end
	end
end

function modifier_justicar_judgement_buff:GetEffectName()
	return "particles/heroes/justicar/justicar_judgement.vpcf"
end

modifier_justicar_judgement_heal = class({})
LinkLuaModifier("modifier_justicar_judgement_heal", "heroes/justicar/justicar_judgement.lua", 0)

if IsServer() then
	function modifier_justicar_judgement_heal:OnCreated(kv)
		self.heal = kv.heal + self:GetCaster():GetInnerSun()
		self:GetCaster():ResetInnerSun()
		self.tick = 0.3
		self.healtick = self.heal * self.tick / self:GetRemainingTime()
		self:StartIntervalThink(self.tick)
	end

	function modifier_justicar_judgement_heal:OnIntervalThink()
		self:GetParent():HealEvent(self.healtick, self:GetAbility(), self:GetCaster())
	end
end