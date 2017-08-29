sylph_jetstream = sylph_jetstream or class({})

function sylph_jetstream:GetAOERadius()
	return self:GetCaster():GetIdealSpeed() * self:GetSpecialValueFor("damage_radius") / 100
end

function sylph_jetstream:OnSpellStart()
	EmitSoundOn("Hero_Windrunner.ShackleshotCast", self:GetCaster())
	self:GetCaster():MoveToPosition(self:GetCursorPosition())
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sylph_jetstream_rush", {duration = CalculateDistance(self:GetCaster(), self:GetCursorPosition()) / self:GetSpecialValueFor("speed")})
end

LinkLuaModifier( "modifier_sylph_jetstream_rush", "heroes/sylph/sylph_jetstream.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_jetstream_rush = modifier_sylph_jetstream_rush or class({})

function modifier_sylph_jetstream_rush:OnCreated()
	if IsServer() then self:StartIntervalThink(0.05) end
	self.speed = self:GetAbility():GetSpecialValueFor("speed")
	self.timer = self:GetParent():GetSecondsPerAttack() / 1.5
	if IsServer() then
		ParticleManager:FireParticle("particles/heroes/sylph/sylph_jetstream_poof.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	end
end

function modifier_sylph_jetstream_rush:OnDestroy()
	if IsServer() then
		ParticleManager:FireParticle("particles/heroes/sylph/sylph_jetstream_poof.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		self:GetAbility():ApplyAOE({radius = self:GetAbility():GetAOERadius() , damage = self:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_MAGICAL})
	end
end

function modifier_sylph_jetstream_rush:OnIntervalThink()
	self.timer = self.timer + 0.05
	if self.timer >= self:GetParent():GetSecondsPerAttack() / 1.5 then
		self.timer = 0
		local units = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetCaster():GetAbsOrigin(), nil, self:GetCaster():GetAttackRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
		for _,unit in pairs(units) do
			self:GetParent():PerformAttack(unit, true, true, true, true, true, false, false)
			if self:GetParent():HasTalent("sylph_jetstream_talent_1") then
				Timers:CreateTimer(0.1, function() self:GetParent():PerformAttack(unit, true, true, true, true, true, false, false) end)
			end
		end
	end
end

function modifier_sylph_jetstream_rush:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function modifier_sylph_jetstream_rush:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
	return funcs
end

function modifier_sylph_jetstream_rush:CheckState()
	local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,}
	return state
end

function modifier_sylph_jetstream_rush:OnOrder(params)
	if self:GetParent() == params.unit and params.order_type > 0 and params.order_type < 5 then
		self:Destroy()
	end
end

function modifier_sylph_jetstream_rush:OnAttackStart(params)
	if self:GetParent() == params.unit then
		self:Destroy()
	end
end

function modifier_sylph_jetstream_rush:OnAbilityFullyCast(params)
	if self:GetParent() == params.unit and params.ability ~= self:GetAbility() then
		self:Destroy()
	end
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


LinkLuaModifier( "modifier_sylph_jetstream_talent_1", "heroes/sylph/sylph_jetstream.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_jetstream_talent_1 = modifier_sylph_jetstream_talent_1 or class({})

function modifier_sylph_jetstream_talent_1:IsHidden()
	return true
end

function modifier_sylph_jetstream_talent_1:RemoveOnDeath()
	return false
end