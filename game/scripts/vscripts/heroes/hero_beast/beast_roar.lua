beast_roar = class({})
LinkLuaModifier( "modifier_roar_slow", "heroes/hero_beast/beast_roar.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_dazed_generic", "libraries/modifiers/modifier_dazed_generic.lua", LUA_MODIFIER_MOTION_NONE)
--[[
function beast_roar:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self:GetTalentSpecialValueFor("cast_range_scepter")
	end

end

function beast_roar:GetCooldown(iLevel)
	if self:GetCaster():HasScepter() then
		return self:GetTalentSpecialValueFor("cast_range_scepter")
	end
	return self:GetCooldown(self:GetLevel())
end
]]

function beast_roar:IsStealable()
	return true
end

function beast_roar:IsHiddenWhenStolen()
	return false
end

function beast_roar:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_beastmaster/beastmaster_primal_roar.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(nfx, 1, point)
	ParticleManager:ReleaseParticleIndex(nfx)

	EmitSoundOn("Hero_Beastmaster.Primal_Roar", caster)

	local enemies = caster:FindEnemyUnitsInLine(caster:GetAbsOrigin(), point, self:GetTalentSpecialValueFor("width"), {})
	for _,enemy in pairs(enemies) do
		self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		enemy:ApplyKnockBack(caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("push_duration"), self:GetTalentSpecialValueFor("push_duration"), self:GetTalentSpecialValueFor("push_distance"), 0, caster, self)
		Timers:CreateTimer(self:GetTalentSpecialValueFor("push_duration"), function()
			self:Stun(enemy, self:GetTalentSpecialValueFor("stun_duration"), 0)
		end)
		Timers:CreateTimer(self:GetTalentSpecialValueFor("stun_duration"), function()
			enemy:AddNewModifier(caster, self, "modifier_roar_slow", {Duration = self:GetTalentSpecialValueFor("slow_duration")})
			if caster:HasTalent("special_bonus_unique_beast_roar_2") then
				enemy:Daze(self, caster, caster:FindTalentValue("special_bonus_unique_beast_roar_2"))
			end
		end)
	end
end

modifier_roar_slow = class({})
function modifier_roar_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		
	}
	return funcs
end

function modifier_roar_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetTalentSpecialValueFor("slow")
end

function modifier_roar_slow:GetModifierAttackSpeedBonus()
	return self:GetTalentSpecialValueFor("slow")
end