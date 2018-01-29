furion_sprout_tp = class({})
LinkLuaModifier( "modifier_sprout_tp", "heroes/hero_furion/furion_sprout_tp.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_entangle_enemy", "heroes/hero_furion/furion_entangle.lua",LUA_MODIFIER_MOTION_NONE )

function furion_sprout_tp:GetCooldown(iLevel)
	return self:GetTalentSpecialValueFor("cooldown")
end

function furion_sprout_tp:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	EmitSoundOn("Hero_Furion.Teleport_Grow", caster)

	self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_furion/furion_teleport.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(self.nfx, 0, caster:GetAbsOrigin())

	self.nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_furion/furion_teleport_end.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(self.nfx2, 1, point)

	caster:AddNewModifier(caster, self, "modifier_sprout_tp", {Duration = self:GetCastPoint()})
	
	return true
end

function furion_sprout_tp:OnAbilityPhaseInterrupted()
	if self:GetCaster():HasModifier("modifier_sprout_tp") then
		self:GetCaster():RemoveModifierByName("modifier_sprout_tp")
	end

	self:RefundManaCost()
	self:EndCooldown()

	StopSoundOn("Hero_Furion.Teleport_Grow", caster)

	ParticleManager:DestroyParticle(self.nfx, false)
	ParticleManager:DestroyParticle(self.nfx2, false)
end

function furion_sprout_tp:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	if caster:HasModifier("modifier_sprout_tp") then
		caster:RemoveModifierByName("modifier_sprout_tp")
	end

	FindClearSpaceForUnit(caster, point, true)

	GridNav:DestroyTreesAroundPoint(point, 150, true)

	ParticleManager:DestroyParticle(self.nfx, false)
	ParticleManager:DestroyParticle(self.nfx2, false)

	StopSoundOn("Hero_Furion.Teleport_Grow", caster)
	EmitSoundOn("Hero_Furion.Teleport_Disappear", caster)
	EmitSoundOn("Hero_Furion.Teleport_Appear", caster)

	Timers:CreateTimer(1, function()
		StopSoundOn("Hero_Furion.Teleport_Disappear", caster)
		StopSoundOn("Hero_Furion.Teleport_Appear", caster)
	end)

	local enemies = caster:FindEnemyUnitsInRadius(point, 500, {})
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, caster:FindAbilityByName("furion_entangle"), "modifier_entangle_enemy", {Duration = caster:FindAbilityByName("furion_entangle"):GetTalentSpecialValueFor("duration")})
	end
end

modifier_sprout_tp = class({})
function modifier_sprout_tp:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER
	}
	return funcs
end

function modifier_sprout_tp:OnOrder(params)
	if IsServer() then
		if params.unit == self:GetCaster() then
			if self:GetCaster():HasModifier("modifier_sprout_tp") then
				self:GetCaster():RemoveModifierByName("modifier_sprout_tp")
			end

			self:GetAbility():RefundManaCost()
			self:GetAbility():EndCooldown()

			StopSoundOn("Hero_Furion.Teleport_Grow", self:GetCaster())

			ParticleManager:DestroyParticle(self:GetAbility().nfx, false)
			ParticleManager:DestroyParticle(self:GetAbility().nfx2, false)
		end
	end
end

function modifier_sprout_tp:IsHidden()
	return true
end