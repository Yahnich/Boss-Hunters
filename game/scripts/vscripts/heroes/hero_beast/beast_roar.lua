beast_roar = class({})
LinkLuaModifier( "modifier_roar_slow", "heroes/hero_beast/beast_roar.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_dazed_generic", "libraries/modifiers/modifier_dazed_generic.lua", LUA_MODIFIER_MOTION_NONE)
--[[
function beast_roar:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("cast_range_scepter")
	end

end

function beast_roar:GetCooldown(iLevel)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("cast_range_scepter")
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
	
	local damage = self:GetSpecialValueFor("damage")
	local pushDur = self:GetSpecialValueFor("push_duration")
	local pushDist = self:GetSpecialValueFor("push_distance")
	local stunDur = self:GetSpecialValueFor("stun_duration")
	local totDur = stunDur + self:GetSpecialValueFor("slow_duration")
	
	local units = caster:FindAllUnitsInLine(caster:GetAbsOrigin(), point, self:GetSpecialValueFor("width"), {})
	for _, unit in pairs(units) do
		if not unit:IsSameTeam( caster ) then
			if unit:TriggerSpellAbsorb(self) then
				self:DealDamage(caster, unit, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
				unit:ApplyKnockBack(caster:GetAbsOrigin(), pushDur, pushDur, pushDist, 0, caster, self)
				Timers:CreateTimer( pushDur, function()
					self:Stun(unit, stunDur, 0)
				end)
				unit:AddNewModifier(caster, self, "modifier_roar_slow", {Duration = totDur})
				if caster:HasTalent("special_bonus_unique_beast_roar_2") then
					unit:Daze(self, caster, totDur )
				end
			end
		elseif self:GetCaster():HasModifier("modifier_cotw_hawk_spirit") then
			unit:HealEvent( damage, nil, caster )
		end
	end
end

modifier_roar_slow = class({})
function modifier_roar_slow:OnCreated()
	self.slow = self:GetSpecialValueFor("slow")
	self.mr = nil
	self.armor = nil
	if self:GetCaster():HasModifier("modifier_cotw_hawk_spirit") then
		self.mr = self:GetSpecialValueFor("hawk_mr")
		self.armor = self:GetSpecialValueFor("hawk_armor")
	end
end

function modifier_roar_slow:OnRefresh()
	self:OnCreated()
end

function modifier_roar_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_roar_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_roar_slow:GetModifierAttackSpeedBonus_Constant()
	return self.slow
end

function modifier_roar_slow:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_roar_slow:GetModifierMagicalResistanceBonus()
	return self.mr
end