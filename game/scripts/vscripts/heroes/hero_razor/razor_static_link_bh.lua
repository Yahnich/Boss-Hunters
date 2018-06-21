razor_static_link_bh = class({})
LinkLuaModifier("modifier_razor_static_link_bh", "heroes/hero_razor/razor_static_link_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_razor_static_link_bh_enemy", "heroes/hero_razor/razor_static_link_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_razor_static_link_bh_buff", "heroes/hero_razor/razor_static_link_bh", LUA_MODIFIER_MOTION_NONE)

function razor_static_link_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	caster:AddNewModifier(caster, self, "modifier_razor_static_link_bh", {Duration = self:GetTalentSpecialValueFor("link_duration")})
end

modifier_razor_static_link_bh = class({})
function modifier_razor_static_link_bh:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		self.target = self:GetAbility():GetCursorTarget()
		EmitSoundOn("Ability.static.start", caster)
		EmitSoundOn("Ability.static.loop", caster)
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_razor/razor_static_link.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_static", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)

		self:AttachEffect(nfx)
		self:StartIntervalThink(0.25)
	end 
end

function modifier_razor_static_link_bh:OnIntervalThink()
	if self.target:IsAlive() then
		local caster = self:GetCaster()

		--[[local distance = CalculateDistance(self.target, caster)
		if distance > 800 then
			self:Destroy()
		end]]

		for i=1, self:GetTalentSpecialValueFor("drain_rate")*0.25 do
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_razor_static_link_bh_buff", {Duration = self:GetTalentSpecialValueFor("buff_duration")}):AddIndependentStack(self:GetTalentSpecialValueFor("buff_duration"))
			if self.target:IsAlive() then
				self.target:AddNewModifier(caster, self:GetAbility(), "modifier_razor_static_link_bh_enemy", {Duration = self:GetTalentSpecialValueFor("buff_duration")}):AddIndependentStack(self:GetTalentSpecialValueFor("buff_duration"))
			end
		end
	else
		self:Destroy()
	end
end

function modifier_razor_static_link_bh:OnRemoved()
	if IsServer() then
		StopSoundOn("Ability.static.loop", self:GetCaster())
		EmitSoundOn("Ability.static.end", self:GetCaster())
	end
end

function modifier_razor_static_link_bh:IsPurgeException()
	return false
end

function modifier_razor_static_link_bh:IsPurgable()
	return false
end

function modifier_razor_static_link_bh:IsHidden()
	return true
end

function modifier_razor_static_link_bh:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_razor_static_link_bh_buff = class({})
function modifier_razor_static_link_bh_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function modifier_razor_static_link_bh_buff:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end

function modifier_razor_static_link_bh_buff:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end

function modifier_razor_static_link_bh_buff:IsDebuff()
	return false
end

function modifier_razor_static_link_bh_buff:GetEffectName()
	return "particles/units/heroes/hero_razor/razor_static_link_buff.vpcf"
end

modifier_razor_static_link_bh_enemy = class({})
function modifier_razor_static_link_bh_enemy:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function modifier_razor_static_link_bh_enemy:GetModifierPreAttack_BonusDamage()
	return -self:GetStackCount()
end

function modifier_razor_static_link_bh_enemy:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end

function modifier_razor_static_link_bh_enemy:IsDebuff()
	return true
end

function modifier_razor_static_link_bh_enemy:GetEffectName()
	return "particles/units/heroes/hero_razor/razor_static_link_debuff.vpcf"
end