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
	local maxTargets = self:GetTalentSpecialValueFor("max_targets")
	local currentTargets = 0
	if hTarget then
		hTarget:AddNewModifier(caster, self, "modifier_windrunner_bolas_primary", {Duration = self:GetTalentSpecialValueFor("duration")})
		self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	end
end

modifier_windrunner_bolas_primary = class({})
function modifier_windrunner_bolas_primary:OnCreated(table)
    if IsServer() then
    	local caster = self:GetCaster()
    	local parent = self:GetParent()
		local ability = self:GetAbility()
    	local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), {order = FIND_CLOSEST})
    	if #enemies > 1 then
    		for _,enemy in pairs(enemies) do
    			if enemy ~= parent then
    				EmitSoundOn("Hero_Windrunner.ShackleshotBind", parent)
					local stun = ability:Stun(parent, self:GetTalentSpecialValueFor("duration") )
	    			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_windrunner/windrunner_shackleshot_pair.vpcf", PATTACH_POINT, caster)
	    						ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT, "attach_hitloc", parent:GetAbsOrigin(), true)
	    						ParticleManager:SetParticleControlEnt(nfx, 1, enemy, PATTACH_POINT, "attach_hitloc", enemy:GetAbsOrigin(), true)
	    						ParticleManager:SetParticleControl(nfx, 2, Vector(self:GetTalentSpecialValueFor("duration"), 0, 0))
	    			stun:AttachEffect(nfx)

					ability:Stun(enemy, self:GetTalentSpecialValueFor("duration") )
	    			if caster:HasTalent("special_bonus_unique_windrunner_bolas_2") then
	    				self:GetAbility():DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	    			end
	    			break
	    		end
    		end
    	else
    		local newDuration = self:GetTalentSpecialValueFor("duration")/10
    		EmitSoundOn("Hero_Windrunner.ShackleshotStun", parent)
			local stun = ability:Stun(parent, newDuration)
    		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_windrunner/windrunner_shackleshot_single.vpcf", PATTACH_POINT, caster)
    					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT, "attach_hitloc", parent:GetAbsOrigin(), true)
    					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT, "attach_hitloc", parent:GetAbsOrigin(), true)
    					ParticleManager:SetParticleControlForward(nfx, 2, ability.direction)
    		stun:AttachEffect(nfx)
    	end
		self:Destroy()
    end
end