ifrit_firebat = class({})

function ifrit_firebat:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_ifrit_kindled_soul_active") then
		return "custom/ifrit_firebat_kindled"
	else
		return "custom/ifrit_firebat"
	end
end

function ifrit_firebat:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	local direction = CalculateDirection(position, caster)
	local distance = CalculateDistance(position, caster)
	local distanceTraveled = 0
	
	local speed = self:GetTalentSpecialValueFor("dash_speed") * FrameTime()
	local radius = self:GetTalentSpecialValueFor("burn_radius")
	if caster:HasModifier("modifier_ifrit_kindled_soul_active") then 
		speed = self:GetTalentSpecialValueFor("kindled_dash_speed") * FrameTime() 
		radius = self:GetTalentSpecialValueFor("kindled_burn_radius")
	end
	caster:AddNewModifier(caster, self, "modifier_ifrit_firebat_invuln", {})
	EmitSoundOn("Hero_EmberSpirit.FlameGuard.Cast", caster)
	
	local internalTimer = 0.5 -- proc on first cast
	Timers:CreateTimer(0, function()
		if CalculateDistance(caster, position) > speed and distanceTraveled < distance then
			if caster:HasTalent("ifrit_firebat_talent_1") then direction = caster:GetForwardVector() end
			caster:SetAbsOrigin( caster:GetAbsOrigin() + direction * speed )
			
			distanceTraveled = distanceTraveled + speed
			internalTimer = internalTimer + FrameTime()
			if internalTimer >= 0.5 then
				local duration = self:GetTalentSpecialValueFor("burn_duration")
				internalTimer = 0
				for _, enemy in ipairs(caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius, {})) do
					enemy:AddNewModifier(caster, self, "modifier_ifrit_firebat_fire_debuff", {duration = duration})
				end
			end
			return FrameTime()
		else
			caster:SetAbsOrigin( caster:GetAbsOrigin() + direction * speed )
			EmitSoundOn("Hero_EmberSpirit.FireRemnant.Create", caster)
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), false)
			caster:RemoveModifierByName("modifier_ifrit_firebat_invuln")
			return nil
		end
	end)
end


modifier_ifrit_firebat_invuln = class({})
LinkLuaModifier("modifier_ifrit_firebat_invuln", "heroes/ifrit/ifrit_firebat.lua", 0)

function modifier_ifrit_firebat_invuln:OnCreated()
	if IsServer() then
		self:GetAbility():SetActivated(false)
	end
end

function modifier_ifrit_firebat_invuln:OnRefresh()
	if IsServer() then
		self:GetAbility():SetActivated(false)
	end
end

function modifier_ifrit_firebat_invuln:OnDestroy()
	if IsServer() then
		self:GetAbility():SetActivated(true)
	end
end

function modifier_ifrit_firebat_invuln:CheckState()
	local state = { [MODIFIER_STATE_ATTACK_IMMUNE] = true,
					[MODIFIER_STATE_DISARMED] = true,
					[MODIFIER_STATE_MAGIC_IMMUNE] = true,
					[MODIFIER_STATE_FLYING] = true,
					[MODIFIER_STATE_UNSELECTABLE] = true}
	return state
end

function modifier_ifrit_firebat_invuln:GetEffectName()
	return "particles/units/heroes/hero_ember_spirit/ember_spirit_remnant_dash.vpcf"
end





LinkLuaModifier( "modifier_ifrit_firebat_fire_debuff", "heroes/ifrit/ifrit_firebat.lua", LUA_MODIFIER_MOTION_NONE )
modifier_ifrit_firebat_fire_debuff = class({})

function modifier_ifrit_firebat_fire_debuff:OnCreated()
	self.damage_over_time = self:GetAbility():GetTalentSpecialValueFor("burn_dot")
	self.tick_interval = 1
	if self:GetCaster():HasScepter() then self.damage_over_time = self.damage_over_time * 2 end
	if IsServer() then 
		self:StartIntervalThink(self.tick_interval) 
	end
end

function modifier_ifrit_firebat_fire_debuff:OnRefresh()
	self.damage_over_time = self.damage_over_time + self:GetAbility():GetTalentSpecialValueFor("burn_dot")
	if self:GetCaster():HasScepter() then self.damage_over_time = self.damage_over_time * 2 end
end

function modifier_ifrit_firebat_fire_debuff:OnIntervalThink()
	ApplyDamage( {victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage_over_time, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()} )
end

--------------------------------------------------------------------------------

function modifier_ifrit_firebat_fire_debuff:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_ifrit_firebat_fire_debuff:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end


function modifier_ifrit_firebat_fire_debuff:IsFireDebuff()
	return true
end