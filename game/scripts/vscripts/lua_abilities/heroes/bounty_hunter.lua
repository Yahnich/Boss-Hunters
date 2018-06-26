bounty_hunter_jinada_ebf = class({})

function bounty_hunter_jinada_ebf:GetCooldown(nLevel)
	local cooldown = self.BaseClass.GetCooldown( self, nLevel )
	if self:GetCaster():HasModifier("modifier_bounty_hunter_jinada_talent") then cooldown = cooldown - self:GetCaster():FindTalentValue("special_bonus_unique_bounty_hunter") end
	return cooldown
end

function bounty_hunter_jinada_ebf:GetIntrinsicModifierName()
	return "modifier_bounty_hunter_jinada_crit"
end

if IsServer() then
	function bounty_hunter_jinada_ebf:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		ExecuteOrderFromTable({
			UnitIndex = caster:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = target:entindex()
		})
		self:EndCooldown()
		self:SetActivated(false)
		caster:AddNewModifier(caster, self, "modifier_bounty_hunter_jinada_dash", {})
		self:GetCaster():SetForceAttackTarget(target)
	end
end

LinkLuaModifier( "modifier_bounty_hunter_jinada_slow", "lua_abilities/heroes/bounty_hunter.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_bounty_hunter_jinada_slow = class({})

function modifier_bounty_hunter_jinada_slow:OnCreated()
	self.movespeed = self:GetAbility():GetSpecialValueFor("bonus_movespeed")
	self.attackspeed = self:GetAbility():GetSpecialValueFor("bonus_attackspeed")
end

function modifier_bounty_hunter_jinada_slow:GetStatusEffectName()
	return "particles/units/heroes/hero_bounty_hunter/status_effect_bounty_hunter_jinda_slow.vpcf"
end

function modifier_bounty_hunter_jinada_slow:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
			}
	return funcs
end

function modifier_bounty_hunter_jinada_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_bounty_hunter_jinada_slow:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

LinkLuaModifier( "modifier_bounty_hunter_jinada_crit", "lua_abilities/heroes/bounty_hunter.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_bounty_hunter_jinada_crit = class({})

function modifier_bounty_hunter_jinada_crit:OnCreated()
	self.crit = self:GetAbility():GetSpecialValueFor("crit_multiplier")
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_bounty_hunter_jinada_crit:OnIntervalThink()
	if self:GetCaster():HasTalent("special_bonus_unique_bounty_hunter") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetCaster():FindAbilityByName("special_bonus_unique_bounty_hunter"), "modifier_bounty_hunter_jinada_talent", {})
		self:StartIntervalThink(-1)
	end
end

function modifier_bounty_hunter_jinada_crit:IsHidden()
	return true
end


function modifier_bounty_hunter_jinada_crit:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
				MODIFIER_EVENT_ON_ATTACK_LANDED
			}
	return funcs
end

function modifier_bounty_hunter_jinada_crit:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			if params.attacker:HasModifier("modifier_bounty_hunter_jinada_dash") then
				local dashModifier = params.attacker:FindModifierByName("modifier_bounty_hunter_jinada_dash")
				dashModifier:DecrementStackCount()
				
				EmitSoundOn("Hero_BountyHunter.Jinada", params.attacker)
				
				local jinada = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinda_slow.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target)
				ParticleManager:SetParticleControlEnt(jinada, 1, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(jinada)
				params.attacker:Stop()
				if dashModifier:GetStackCount() < 1 then 
					params.attacker:RemoveModifierByName("modifier_bounty_hunter_jinada_dash")
					params.attacker:SetForceAttackTarget(nil)
				else
					local units = FindUnitsInRadius(params.attacker:GetTeam(), params.target:GetAbsOrigin(), nil, self:GetAbility():GetTrueCastRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
					if #units > 1 then
						for _,unit in ipairs(units) do
							if unit ~= params.target then
								self:GetCaster():SetForceAttackTarget(nil)
								ExecuteOrderFromTable({
									UnitIndex = params.attacker:entindex(),
									OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
									TargetIndex = unit:entindex()
								})
								self:GetCaster():SetForceAttackTarget(unit)
								return
							end
						end
						params.attacker:SetForceAttackTarget(nil)
					else
						params.attacker:RemoveModifierByName("modifier_bounty_hunter_jinada_dash")
						params.attacker:SetForceAttackTarget(nil)
					end
				end
			end
		end
	end
end

function modifier_bounty_hunter_jinada_crit:GetModifierPreAttack_CriticalStrike(params)
	if self:GetAbility():IsCooldownReady() then
		self:GetAbility():SetActivated(true) 
		local cd = self:GetAbility():SetCooldown()

		return self.crit
	elseif self:GetParent():HasModifier("modifier_bounty_hunter_jinada_dash") then
		return self.crit
	else
		return
	end
end

LinkLuaModifier( "modifier_bounty_hunter_jinada_dash", "lua_abilities/heroes/bounty_hunter.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_bounty_hunter_jinada_dash = class({})

function modifier_bounty_hunter_jinada_dash:OnCreated()
	self.speed = self:GetAbility():GetSpecialValueFor("dash_speed")
	if IsServer() then
		local hunterLvl = self:GetCaster():FindAbilityByName("bounty_hunter_veteran_hunter"):GetSpecialValueFor("bonus_jinada_targets")
		self:SetStackCount(hunterLvl)
		self:StartIntervalThink(0.5)
	end
end

function modifier_bounty_hunter_jinada_dash:OnDestroy()
	if IsServer() then self:GetParent():SetForceAttackTarget(nil) end
end

function modifier_bounty_hunter_jinada_dash:IsHidden()
	return true
end

function modifier_bounty_hunter_jinada_dash:CheckState()
    local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}
	return state
end

function modifier_bounty_hunter_jinada_dash:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
				MODIFIER_PROPERTY_MOVESPEED_LIMIT,
				MODIFIER_PROPERTY_MOVESPEED_MAX	
			}
	return funcs
end

function modifier_bounty_hunter_jinada_dash:GetModifierMoveSpeed_Absolute()
	return self.speed
end

function modifier_bounty_hunter_jinada_dash:GetModifierMoveSpeed_Limit()
	return self.speed
end

function modifier_bounty_hunter_jinada_dash:GetModifierMoveSpeed_Max()
	return self.speed
end

function modifier_bounty_hunter_jinada_dash:GetEffectName()
	return	"particles/bounty_hunter_shinigami_buff.vpcf"
end


LinkLuaModifier( "modifier_bounty_hunter_jinada_talent", "lua_abilities/heroes/bounty_hunter.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_bounty_hunter_jinada_talent = class({})

function modifier_bounty_hunter_jinada_talent:IsHidden()
	return true
end

function modifier_bounty_hunter_jinada_talent:RemoveOnDeath()
	return false
end


bounty_hunter_veteran_hunter = class({})

function bounty_hunter_veteran_hunter:GetIntrinsicModifierName()
	return "modifier_bounty_hunter_veteran_hunter"
end

LinkLuaModifier( "modifier_bounty_hunter_veteran_hunter", "lua_abilities/heroes/bounty_hunter.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_bounty_hunter_veteran_hunter = class({})

function modifier_bounty_hunter_veteran_hunter:OnCreated()
	self.maxShurikens = self:GetAbility():GetSpecialValueFor("bonus_toss_targets")
	self.minShurikens = self:GetAbility():GetSpecialValueFor("min_shurikens")
	self.bonusTrack = self:GetAbility():GetSpecialValueFor("bonus_track_targets")
end

function modifier_bounty_hunter_veteran_hunter:OnRefresh()
	self.maxShurikens = self:GetAbility():GetSpecialValueFor("bonus_toss_targets")
	self.minShurikens = self:GetAbility():GetSpecialValueFor("min_shurikens")
	self.bonusTrack = self:GetAbility():GetSpecialValueFor("bonus_track_targets")
end

function modifier_bounty_hunter_veteran_hunter:IsHidden()
	return true
end

function modifier_bounty_hunter_veteran_hunter:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
			}
	return funcs
end

function modifier_bounty_hunter_veteran_hunter:OnAbilityFullyCast(params)
	if IsServer() then
		if params.unit == self:GetParent() then
			if params.ability:GetName() == "bounty_hunter_shuriken_toss" then
				local shurikens = self.maxShurikens
				local units = FindUnitsInRadius(params.unit:GetTeam(), params.unit:GetAbsOrigin(), nil, params.ability:GetCastRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
				if #units < shurikens then shurikens = #units end
				if shurikens < self.minShurikens then shurikens = self.minShurikens end
				for _,unit in pairs(units) do
					if unit ~= params.target then
						params.unit:SetCursorCastTarget(unit)
						params.ability:OnSpellStart()
						shurikens = shurikens - 1
						if shurikens < 1 then break end
					end
				end
				if shurikens > 0 then
					Timers:CreateTimer(0.1,function()
						params.unit:SetCursorCastTarget(params.target)
						params.ability:OnSpellStart()
						shurikens = shurikens - 1
						if shurikens > 0 then return 0.1 end
					end)
				end
			elseif params.ability:GetName() == "bounty_hunter_track" then
				local tracks = self.bonusTrack
				local units = FindUnitsInRadius(params.unit:GetTeam(), params.unit:GetAbsOrigin(), nil, params.ability:GetCastRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
				for _,unit in pairs(units) do
					params.unit:SetCursorCastTarget(unit)
					params.ability:OnSpellStart()
					tracks = tracks - 1
					if tracks < 1 then break end
				end
			end
		end
	end
end