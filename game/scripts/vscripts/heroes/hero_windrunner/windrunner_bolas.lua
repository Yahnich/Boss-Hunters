windrunner_bolas = class({})
LinkLuaModifier("modifier_windrunner_bolas_primary", "heroes/hero_windrunner/windrunner_bolas", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_windrunner_bolas_secondary", "heroes/hero_windrunner/windrunner_bolas", LUA_MODIFIER_MOTION_NONE)

function windrunner_bolas:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	self.direction = CalculateDirection(target, caster)

	EmitSoundOn("Hero_Windrunner.ShackleshotCast", caster)
	self:FireTrackingProjectile("particles/units/heroes/hero_windrunner/windrunner_shackleshot.vpcf", target, 1650, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1)
end

function windrunner_bolas:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	local maxTargets = self:GetSpecialValueFor("max_targets")
	local currentTargets = 0
	if hTarget then
		hTarget:AddNewModifier(caster, self, "modifier_windrunner_bolas_primary", {Duration = self:GetSpecialValueFor("duration")})
		self:DealDamage(caster, hTarget, self:GetSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	end
end

modifier_windrunner_bolas_primary = class({})
function modifier_windrunner_bolas_primary:OnCreated(table)
    if IsServer() then
    	local caster = self:GetCaster()
    	local parent = self:GetParent()
    	local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self:GetSpecialValueFor("radius"), {order = FIND_CLOSEST})
    	if #enemies > 1 then
    		for _,enemy in pairs(enemies) do
    			if enemy ~= parent then
    				EmitSoundOn("Hero_Windrunner.ShackleshotBind", parent)
	    			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_windrunner/windrunner_shackleshot_pair.vpcf", PATTACH_POINT, caster)
	    						ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT, "attach_hitloc", parent:GetAbsOrigin(), true)
	    						ParticleManager:SetParticleControlEnt(nfx, 1, enemy, PATTACH_POINT, "attach_hitloc", enemy:GetAbsOrigin(), true)
	    						ParticleManager:SetParticleControl(nfx, 2, Vector(self:GetSpecialValueFor("duration"), 0, 0))
	    			self:AttachEffect(nfx)

	    			enemy:AddNewModifier(caster, self:GetAbility(), "modifier_windrunner_bolas_secondary", {Duration = self:GetDuration()})

	    			if caster:HasTalent("special_bonus_unique_windrunner_bolas_2") then
	    				self:GetAbility():DealDamage(caster, enemy, self:GetSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	    			end
	    			break
	    		end
    		end
    	else
    		local newDuration = self:GetSpecialValueFor("duration")/10
    		self:SetDuration(newDuration, true)
    		EmitSoundOn("Hero_Windrunner.ShackleshotStun", parent)
    		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_windrunner/windrunner_shackleshot_single.vpcf", PATTACH_POINT, caster)
    					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT, "attach_hitloc", parent:GetAbsOrigin(), true)
    					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT, "attach_hitloc", parent:GetAbsOrigin(), true)
    					ParticleManager:SetParticleControlForward(nfx, 2, self:GetAbility().direction)
    		self:AttachEffect(nfx)

    		self:GetAbility():Stun(parent, newDuration)
    	end
    end
end

function modifier_windrunner_bolas_primary:IsDebuff()
	return true
end

function modifier_windrunner_bolas_primary:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true}
	return state
end

function modifier_windrunner_bolas_primary:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_windrunner_bolas_primary:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end

modifier_windrunner_bolas_secondary = class({})
function modifier_windrunner_bolas_secondary:IsDebuff()
	return true
end

function modifier_windrunner_bolas_secondary:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true}
	return state
end

function modifier_windrunner_bolas_secondary:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_windrunner_bolas_secondary:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end