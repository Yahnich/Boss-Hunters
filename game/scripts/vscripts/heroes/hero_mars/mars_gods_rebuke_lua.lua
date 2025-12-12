mars_gods_rebuke_lua = class({})

function mars_gods_rebuke_lua:IsStealable()
	return true
end

function mars_gods_rebuke_lua:IsHiddenWhenStolen()
	return false
end

function mars_gods_rebuke_lua:GetManaCost( iLvl )
	if self:GetCaster():HasModifier("modifier_mars_spear_rebuke_mana") then
		return 0
	else
		return self.BaseClass.GetManaCost( self, iLvl )
	end
end

function mars_gods_rebuke_lua:GetCooldown( iLvl )
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("scepter_cd")
	else
		return self.BaseClass.GetCooldown( self, iLvl )
	end
end

function mars_gods_rebuke_lua:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("distance")
end

function mars_gods_rebuke_lua:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()

	EmitSoundOn("Hero_Mars.Shield.Cast", caster)

	self.hitUnits = {}
	self:Rebuke(caster, pos)
	self.hitUnits = {}
	if caster:HasTalent("special_bonus_unique_mars_phalanx_1") then
		for _, warrior in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), -1, {flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE } ) ) do
			if warrior:HasModifier("modifier_mars_phalanx_warrior") then
				warrior:StartGesture( ACT_DOTA_ATTACK )
				self:Rebuke( warrior, warrior:GetAbsOrigin() + warrior:GetForwardVector() * 150 )
			end
		end
	end
	caster:RemoveModifierByName("modifier_mars_spear_rebuke_mana")
end

function mars_gods_rebuke_lua:Rebuke(source, position)
	local caster = self:GetCaster()
	local origin = source or caster
	local pos = position

	local direction = CalculateDirection(pos, origin:GetAbsOrigin())

	local angle = self:GetSpecialValueFor("angle")	
	local distance = self:GetSpecialValueFor("distance")	
	local knockback_duration = self:GetSpecialValueFor("knockback_duration")	
	local knockback_distance = self:GetSpecialValueFor("knockback_distance")

	local circleRadius = math.tan(angle/2) * distance

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_shield_bash.vpcf", PATTACH_POINT, origin)
				ParticleManager:SetParticleControlForward(nfx, 0, direction)
				ParticleManager:SetParticleControl(nfx, 1, Vector(circleRadius, circleRadius, circleRadius))
				ParticleManager:ReleaseParticleIndex(nfx)

	caster:AddNewModifier(caster, self, "modifier_mars_gods_rebuke_lua_crit", {Duration = 1})

	local enemies = caster:FindEnemyUnitsInCone(direction, origin:GetAbsOrigin(), circleRadius, distance)
	
	local slow_duration = self:GetSpecialValueFor("slow_duration")
	local talentBigStacks = caster:FindTalentValue("special_bonus_unique_mars_gods_rebuke_lua_2")
	local talentSmallStacks = caster:FindTalentValue("special_bonus_unique_mars_gods_rebuke_lua_2", "minion")
	local talentStacks = 0

	for _,enemy in pairs(enemies) do
		if not self.hitUnits[enemy] then
			if caster == target then EmitSoundOn("Hero_Mars.Shield.Crit", caster) end

			local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_shield_bash_crit.vpcf", PATTACH_POINT, origin)
						ParticleManager:SetParticleControlEnt(nfx2, 0, enemy, PATTACH_POINT, "attach_hitloc", enemy:GetAbsOrigin(), true)
						ParticleManager:SetParticleControlEnt(nfx2, 1, enemy, PATTACH_POINT, "attach_hitloc", enemy:GetAbsOrigin(), true)
						ParticleManager:SetParticleControlForward(nfx2, 1, CalculateDirection(enemy, origin))
						ParticleManager:ReleaseParticleIndex(nfx2)
			if not enemy:TriggerSpellAbsorb( self ) then
				if not enemy:IsKnockedBack() then
					enemy:ApplyKnockBack(origin:GetAbsOrigin(), knockback_duration, knockback_duration, knockback_distance, 0, caster, self, false)
				end
				talentStacks = talentStacks + TernaryOperator( talentSmallStacks, enemy:IsMinion(), talentBigStacks )
				enemy:AddNewModifier( caster, self, "modifier_mars_gods_rebuke_lua_slow", {duration = slow_duration} )
				caster:PerformAbilityAttack(enemy, true, self, 0, false, true)
			end
			self.hitUnits[enemy] = true
		end
	end
	if caster == origin and caster:HasTalent("special_bonus_unique_mars_gods_rebuke_lua_2") then
		local duration = self:GetCaster():FindTalentValue("special_bonus_unique_mars_gods_rebuke_lua_2", "duration")
		local maxStacks = self:GetCaster():FindTalentValue("special_bonus_unique_mars_gods_rebuke_lua_2", "max")
		caster:AddNewModifier(caster, self, "modifier_mars_gods_rebuke_lua_talent_two", {Duration = duration}):SetStackCount( math.min( maxStacks, talentStacks ) )
	end

	caster:RemoveModifierByName("modifier_mars_gods_rebuke_lua_crit")
end

modifier_mars_gods_rebuke_lua_slow = class({})
LinkLuaModifier( "modifier_mars_gods_rebuke_lua_slow", "heroes/hero_mars/mars_gods_rebuke_lua.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_mars_gods_rebuke_lua_slow:OnCreated()
	self:OnRefresh()
end

function modifier_mars_gods_rebuke_lua_slow:OnRefresh()
	self.slow = self:GetSpecialValueFor("slow")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_mars_gods_rebuke_lua_1")
	if self.talent1 then
		local talent1Val = self:GetCaster():FindTalentValue("special_bonus_unique_mars_gods_rebuke_lua_1") / 100
		self.as = self.slow * talent1Val
	end
end

function modifier_mars_gods_rebuke_lua_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_mars_gods_rebuke_lua_slow:GetModifierMoveSpeedBonus_Percentage(params)
	return self.slow
end

function modifier_mars_gods_rebuke_lua_slow:GetModifierAttackSpeedBonus_Constant(params)
	return self.as
end

function modifier_mars_gods_rebuke_lua_slow:GetStatusEffectName()
	return "particles/status_fx/status_effect_snapfire_slow.vpcf"
end

function modifier_mars_gods_rebuke_lua_slow:StatusEffectPriority()
	return 2
end

modifier_mars_gods_rebuke_lua_crit = class({})
LinkLuaModifier( "modifier_mars_gods_rebuke_lua_crit", "heroes/hero_mars/mars_gods_rebuke_lua.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_mars_gods_rebuke_lua_crit:OnCreated()
	self:OnRefresh()
end

function modifier_mars_gods_rebuke_lua_crit:OnRefresh()
	self.crit = self:GetSpecialValueFor("crit_mult")
	self.bonus_dmg = self:GetSpecialValueFor("bonus_damage_vs_bosses")
	self:GetParent():HookInModifier("GetModifierCriticalDamage", self)
end

function modifier_mars_gods_rebuke_lua_crit:OnDestroy()
	self:GetParent():HookOutModifier("GetModifierCriticalDamage", self)
end

function modifier_mars_gods_rebuke_lua_crit:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_mars_gods_rebuke_lua_crit:GetModifierPreAttack_BonusDamage(params)
	if params.target and not params.target:IsMinion() then
		return self.bonus_dmg
	end
end

function modifier_mars_gods_rebuke_lua_crit:GetModifierCriticalDamage()
	return self.crit
end

function modifier_mars_gods_rebuke_lua_crit:IsPurgable()
	return false
end

function modifier_mars_gods_rebuke_lua_crit:IsPurgeException()
	return false
end

function modifier_mars_gods_rebuke_lua_crit:IsHidden()
	return true
end

modifier_mars_gods_rebuke_lua_talent_two = class({})
LinkLuaModifier( "modifier_mars_gods_rebuke_lua_talent_two", "heroes/hero_mars/mars_gods_rebuke_lua.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_mars_gods_rebuke_lua_talent_two:IsPurgable()
	return true
end

function modifier_mars_gods_rebuke_lua_talent_two:IsDebuff()
	return false
end

function modifier_mars_gods_rebuke_lua_talent_two:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_mars_gods_rebuke_lua_talent_two:GetModifierIncomingDamage_Percentage()
	return -self:GetStackCount()
end

function modifier_mars_gods_rebuke_lua_talent_two:GetStatusEffectName()
	return "particles/status_fx/status_effect_mars_spear.vpcf"
end

function modifier_mars_gods_rebuke_lua_talent_two:StatusEffectPriority()
	return 10
end