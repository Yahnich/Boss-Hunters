mars_gods_rebuke_lua = class({})
LinkLuaModifier( "modifier_mars_gods_rebuke_lua_crit", "heroes/hero_mars/mars_gods_rebuke_lua.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mars_gods_rebuke_lua_talent", "heroes/hero_mars/mars_gods_rebuke_lua.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mars_gods_rebuke_lua_talent_two", "heroes/hero_mars/mars_gods_rebuke_lua.lua" ,LUA_MODIFIER_MOTION_NONE )

function mars_gods_rebuke_lua:IsStealable()
	return true
end

function mars_gods_rebuke_lua:IsHiddenWhenStolen()
	return false
end

function mars_gods_rebuke_lua:GetIntrinsicModifierName()
	return "modifier_mars_gods_rebuke_lua_talent"
end

function mars_gods_rebuke_lua:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("distance")
end

function mars_gods_rebuke_lua:OnSpellStart()
	local pos = self:GetCursorPosition()

	EmitSoundOn("Hero_Mars.Shield.Cast", self:GetCaster())

	self:Rebuke(pos)
end

function mars_gods_rebuke_lua:Rebuke(vLocation)
	local caster = self:GetCaster()
	local pos = vLocation

	local direction = CalculateDirection(pos, caster:GetAbsOrigin())

	local angle = self:GetSpecialValueFor("angle")	
	local distance = self:GetSpecialValueFor("distance")	
	local knockback_duration = self:GetSpecialValueFor("knockback_duration")	
	local knockback_distance = self:GetSpecialValueFor("knockback_distance")	
	local bonus_damage = self:GetSpecialValueFor("bonus_damage_vs_bosses")	

	local circleRadius = math.tan(angle/2) * distance

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_shield_bash.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlForward(nfx, 0, direction)
				ParticleManager:SetParticleControl(nfx, 1, Vector(circleRadius, circleRadius, circleRadius))
				ParticleManager:ReleaseParticleIndex(nfx)

	caster:AddNewModifier(caster, self, "modifier_mars_gods_rebuke_lua_crit", {Duration = 1})

	local enemies = caster:FindEnemyUnitsInCone(direction, caster:GetAbsOrigin(), circleRadius, distance)
	if #enemies > 0 and caster:HasTalent("special_bonus_unique_mars_gods_rebuke_lua_2") then
		local duration = self:GetCaster():FindTalentValue("special_bonus_unique_mars_gods_rebuke_lua_2", "duration")
		caster:AddNewModifier(caster, self, "modifier_mars_gods_rebuke_lua_talent_two", {Duration = duration})
	end
	for _,enemy in pairs(enemies) do
		EmitSoundOn("Hero_Mars.Shield.Crit", caster)

		local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_shield_bash_crit.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx2, 0, enemy, PATTACH_POINT, "attach_hitloc", enemy:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx2, 1, enemy, PATTACH_POINT, "attach_hitloc", enemy:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlForward(nfx2, 1, CalculateDirection(enemy, caster))
					ParticleManager:ReleaseParticleIndex(nfx2)
		if not enemy:TriggerSpellAbsorb( self ) then
			if not enemy:IsKnockedBack() then
				enemy:ApplyKnockBack(caster:GetAbsOrigin(), knockback_duration, knockback_duration, knockback_distance, 0, caster, self, true)
			end
			
			caster:PerformAbilityAttack(enemy, true, self, 0, false, true)

			if enemy:IsAlive() and ( enemy:IsBoss() or enemy:IsHero() or enemy:IsAncient() ) then
				self:DealDamage(caster, enemy, bonus_damage, {}, OVERHEAD_ALERT_DAMAGE)
			end
		end
	end

	caster:RemoveModifierByName("modifier_mars_gods_rebuke_lua_crit")
end

modifier_mars_gods_rebuke_lua_crit = class({})

function modifier_mars_gods_rebuke_lua_crit:OnCreated()
	self:OnRefresh()
end

function modifier_mars_gods_rebuke_lua_crit:OnRefresh()
	self.crit = self:GetSpecialValueFor("crit_mult")
	if IsServer() then
		self:GetParent():HookInModifier("GetModifierCriticalDamage", self)
	end
end

function modifier_mars_gods_rebuke_lua_crit:OnDestroy()
	if IsServer() then
		self:GetParent():HookOutModifier("GetModifierCriticalDamage", self)
	end
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

function modifier_mars_gods_rebuke_lua_crit:GetModifierCriticalDamage()
	return self.crit
end

modifier_mars_gods_rebuke_lua_talent = class({})

function modifier_mars_gods_rebuke_lua_talent:OnCreated()
	self.crit = self:GetSpecialValueFor("crit_mult")	
end

function modifier_mars_gods_rebuke_lua_talent:IsPurgable()
	return false
end

function modifier_mars_gods_rebuke_lua_talent:IsPurgeException()
	return false
end

function modifier_mars_gods_rebuke_lua_talent:IsHidden()
	return true
end

function modifier_mars_gods_rebuke_lua_talent:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_mars_gods_rebuke_lua_talent:OnAttackLanded(params)
	if IsServer() then
		local caster = self:GetCaster()
		local target = params.target
		local attacker = params.attacker

		if attacker == caster then
			local chance = caster:FindTalentValue("special_bonus_unique_mars_gods_rebuke_lua_1")
			if caster:HasTalent("special_bonus_unique_mars_gods_rebuke_lua_1") and not attacker:IsInAbilityAttackMode() and RollPercentage(chance) then
				EmitSoundOn("Hero_Mars.Shield.Cast.Small", caster)
				self:GetAbility():Rebuke(target:GetAbsOrigin())
			end
		end
	end
end

modifier_mars_gods_rebuke_lua_talent_two = class({})

function modifier_mars_gods_rebuke_lua_talent_two:OnCreated()
	self.damageblock = self:GetCaster():FindTalentValue("special_bonus_unique_mars_gods_rebuke_lua_2", "block")
end

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
	return self.damageblock
end

function modifier_mars_gods_rebuke_lua_talent_two:GetStatusEffectName()
	return "particles/status_fx/status_effect_mars_spear.vpcf"
end

function modifier_mars_gods_rebuke_lua_talent_two:StatusEffectPriority()
	return 10
end