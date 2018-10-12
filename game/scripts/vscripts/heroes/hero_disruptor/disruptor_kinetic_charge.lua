disruptor_kinetic_charge = class({})

function disruptor_kinetic_charge:CastFilterResultTarget( target )
	if self:GetCaster():HasTalent("special_bonus_unique_disruptor_kinetic_charge_2") then
		return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_CHECK_DISABLE_HELP, target:GetTeamNumber())
	else
		return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, target:GetTeamNumber())
	end
end

	return UF_FAIL_DISABLE_HELP 

function disruptor_kinetic_charge:OnSpellStart()
	local hTarget = self:GetCursorTarget()
	local caster = self:GetCaster()
	ApplyDamage({ victim = hTarget, attacker = caster, damage = self:GetAbilityDamage(), damage_type = self:GetAbilityDamageType(), ability = self })
	if hTarget:IsSameTeam( caster ) then
		hTarget:AddNewModifier(caster, self, "modifier_disruptor_kinetic_charge_push", {duration = self:GetTalentSpecialValueFor("pull_duration")})
	else
		hTarget:AddNewModifier(caster, self, "modifier_disruptor_kinetic_charge_pull", {duration = self:GetTalentSpecialValueFor("pull_duration")})
	end
end

LinkLuaModifier( "modifier_disruptor_kinetic_charge_push", "lua_abilities/heroes/disruptor.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_disruptor_kinetic_charge_push = class({})

function modifier_disruptor_kinetic_charge_push:OnCreated()
	self.aura_radius = self:GetAbility():GetSpecialValueFor("pull_radius")
	self.slow = self:GetAbility():GetSpecialValueFor("pull_slow") * (-1)
	self.pullTick = self:GetAbility():GetSpecialValueFor("pull_speed") * 0.03
	self.pullRadius = self:GetAbility():GetSpecialValueFor("pull_radius")
	if IsServer() then
		self:StartIntervalThink(0.03)
	end
end

function modifier_disruptor_kinetic_charge_push:OnIntervalThink()
	local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.aura_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false )
	for _, unit in pairs(units) do
		if unit:HasModifier("modifier_disruptor_kinetic_charge_pull_aura") then
			local casterPos = self:GetParent():GetAbsOrigin()
			local targetPos = unit:GetAbsOrigin()
			local direction = targetPos - casterPos
			local vec = direction:Normalized() * self.pullTick
			if direction:Length2D() <= self.pullRadius and direction:Length2D() >= 200 then
				unit:SetAbsOrigin(targetPos + vec)
			end
			if RollPercentage(3) then
				EmitSoundOn("Item.Maelstrom.Chain_Lightning", unit)
				local AOE_effect = ParticleManager:CreateParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_POINT_FOLLOW  , self:GetParent())
					ParticleManager:SetParticleControlEnt(AOE_effect, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(AOE_effect, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(AOE_effect, 2, Vector(RandomInt(1,10),RandomInt(1,10),RandomInt(1,10)))
				ParticleManager:ReleaseParticleIndex(AOE_effect)
			end
		end
	end
	ResolveNPCPositions( self:GetParent():GetAbsOrigin(), self.aura_radius )
end

function modifier_disruptor_kinetic_charge_push:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			}
	return funcs
end

function modifier_disruptor_kinetic_charge_push:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

--------------------------------------------------------------------------------
function modifier_disruptor_kinetic_charge_push:IsAura()
	return true
end

function modifier_disruptor_kinetic_charge_push:GetModifierAura()
	return "modifier_disruptor_kinetic_charge_pull_aura"
end

function modifier_disruptor_kinetic_charge_push:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_disruptor_kinetic_charge_push:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

--------------------------------------------------------------------------------

function modifier_disruptor_kinetic_charge_push:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_disruptor_kinetic_charge_push:GetAuraRadius()
	return self.aura_radius
end

LinkLuaModifier( "modifier_disruptor_kinetic_charge_pull", "lua_abilities/heroes/disruptor.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_disruptor_kinetic_charge_pull = class({})

function modifier_disruptor_kinetic_charge_pull:OnCreated()
	self.aura_radius = self:GetAbility():GetSpecialValueFor("pull_radius")
	self.slow = self:GetAbility():GetSpecialValueFor("pull_slow")
	self.pullTick = self:GetAbility():GetSpecialValueFor("pull_speed") * 0.03
	self.pullRadius = self:GetAbility():GetSpecialValueFor("pull_radius")
	if IsServer() then
		self:StartIntervalThink(0.03)
	end
end

function modifier_disruptor_kinetic_charge_pull:OnIntervalThink()
	local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.aura_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false )
	for _, unit in pairs(units) do
		if unit:HasModifier("modifier_disruptor_kinetic_charge_pull_aura") then
			local casterPos = self:GetParent():GetAbsOrigin()
			local casterPos = unit:GetAbsOrigin()
			local direction = targetPos - casterPos
			local vec = direction:Normalized() * self.pullTick
			if direction:Length2D() <= self.pullRadius and direction:Length2D() >= 200 then
				unit:SetAbsOrigin(targetPos - vec)
			end
			if RollPercentage(3) then
				EmitSoundOn("Item.Maelstrom.Chain_Lightning", unit)
				local AOE_effect = ParticleManager:CreateParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_POINT_FOLLOW  , self:GetParent())
					ParticleManager:SetParticleControlEnt(AOE_effect, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(AOE_effect, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(AOE_effect, 2, Vector(RandomInt(1,10),RandomInt(1,10),RandomInt(1,10)))
				ParticleManager:ReleaseParticleIndex(AOE_effect)
			end
		end
	end
	ResolveNPCPositions( self:GetParent():GetAbsOrigin(), self.aura_radius )
end

function modifier_disruptor_kinetic_charge_pull:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			}
	return funcs
end

function modifier_disruptor_kinetic_charge_pull:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

--------------------------------------------------------------------------------
function modifier_disruptor_kinetic_charge_pull:IsAura()
	return true
end

function modifier_disruptor_kinetic_charge_pull:GetModifierAura()
	return "modifier_disruptor_kinetic_charge_pull_aura"
end

function modifier_disruptor_kinetic_charge_pull:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_disruptor_kinetic_charge_pull:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

--------------------------------------------------------------------------------

function modifier_disruptor_kinetic_charge_pull:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_disruptor_kinetic_charge_pull:GetAuraRadius()
	return self.aura_radius
end

LinkLuaModifier( "modifier_disruptor_kinetic_charge_pull_aura", "lua_abilities/heroes/disruptor.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_disruptor_kinetic_charge_pull_aura = class({})

function modifier_disruptor_kinetic_charge_pull_aura:OnCreated()
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_disruptor_kinetic_charge_pull_aura:GetEffectName()
	return "particles/disruptor_kinetic_charge_debuff.vpcf"
end

function modifier_disruptor_kinetic_charge_pull_aura:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent() )
end