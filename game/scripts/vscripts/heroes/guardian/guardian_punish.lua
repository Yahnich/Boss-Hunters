sylph_jetstream = sylph_jetstream or class({})

-- "Hero_Windrunner.ShackleshotStun" attack sound
-- "Hero_Windrunner.ShackleshotCast" leap sound

function sylph_jetstream:OnSpellStart()
	EmitSoundOn("Hero_Windrunner.ShackleshotCast", self:GetCaster())
	print(self:GetCursorPosition())
	self:GetCaster():MoveToPosition(self:GetCursorPosition())
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sylph_jetstream_rush", {})
end

LinkLuaModifier( "modifier_sylph_jetstream_rush", "heroes/sylph/sylph_jetstream.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
modifier_sylph_jetstream_rush = modifier_sylph_jetstream_rush or class({})

function modifier_sylph_jetstream_rush:OnCreated()
	if IsServer() then self:StartIntervalThink(0.15) end
	self.speed = self:GetAbility():GetSpecialValueFor("speed")
	self.timer = self:GetParent():GetSecondsPerAttack()
end

function modifier_sylph_jetstream_rush:OnIntervalThink()
	if not self:GetParent():IsMoving() then
		self:Destroy()
	end
	self.timer = self.timer + 0.15
	if self.timer >= self:GetParent():GetSecondsPerAttack() then
		self.timer = 0
		local units = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetCaster():GetAbsOrigin(), nil, self:GetCaster():GetAttackRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
		for _,unit in pairs(units) do
			self:GetParent():PerformAttack(unit, true, true, true, true, true, false, false)
		end
	end
end

function modifier_sylph_jetstream_rush:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_MAX,
	}
	return funcs
end

function modifier_sylph_jetstream_rush:CheckState()
	local state = {[MODIFIER_STATE_COMMAND_RESTRICTED] = true}
	return state
end

function modifier_sylph_jetstream_rush:GetModifierMoveSpeed_Absolute()
	return self.speed
end

function modifier_sylph_jetstream_rush:GetModifierMoveSpeed_Max()
	return self.speed
end

function modifier_sylph_jetstream_rush:GetModifierMoveSpeed_Limit()
	return self.speed
end

function modifier_sylph_jetstream_rush:GetEffectName()
	return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end