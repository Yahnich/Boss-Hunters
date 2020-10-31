windrunner_bolas = class({})

function windrunner_bolas:IsStealable()
    return true
end

function windrunner_bolas:IsHiddenWhenStolen()
    return false
end

function windrunner_bolas:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	self.direction = CalculateDirection(target, caster)

	EmitSoundOn("Hero_Windrunner.ShackleshotCast", caster)
	self.projectiles = self.projectiles or {}
	self.projectiles[self:FireTrackingProjectile("particles/units/heroes/hero_windrunner/windrunner_shackleshot.vpcf", target, 1650, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1)] = caster:GetAbsOrigin()
end

function windrunner_bolas:DoBolasStun( target, duration, failure, FX, source, sourceIsTree )
	local caster = self:GetCaster()
	local fDur = duration or TernaryOperator( self:GetTalentSpecialValueFor("duration"), failure, self:GetTalentSpecialValueFor("fail_duration") )
	self:Stun(target, fDur )
	local bolas = target:AddNewModifier( caster, self, "modifier_windrunner_bolas_primary", {duration = fDur} )
	if FX == true or FX == nil then
		if failure then
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_windrunner/windrunner_shackleshot_single.vpcf", PATTACH_POINT, caster)
    					ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
    					ParticleManager:SetParticleControlEnt(nfx, 1, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
    					ParticleManager:SetParticleControlForward(nfx, 2, direction)
    		bolas:AttachEffect(nfx)
		elseif source then
			if sourceIsTree then
				local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_windrunner/windrunner_shackleshot_pair_tree.vpcf", PATTACH_POINT, target)
								ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
								ParticleManager:SetParticleControl(nfx, 1, source:GetAbsOrigin() + Vector(0,0,GetGroundHeight( target:GetAbsOrigin(), target ) - GetGroundHeight( source:GetAbsOrigin(), source ) ))
								ParticleManager:SetParticleControl( nfx, 2, Vector(bolas:GetRemainingTime(), 0, 0) )
				bolas:AttachEffect(nfx)
			else
				local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_windrunner/windrunner_shackleshot_pair.vpcf", PATTACH_POINT, caster)
								ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
								ParticleManager:SetParticleControlEnt(nfx, 1, source, PATTACH_POINT, "attach_hitloc", source:GetAbsOrigin(), true)
								ParticleManager:SetParticleControl( nfx, 2, Vector(bolas:GetRemainingTime(), 0, 0) )
				bolas:AttachEffect(nfx)
			end
		end
	end
end

function windrunner_bolas:OnProjectileHitHandle(target, position, projectile)
	local caster = self:GetCaster()
	if target and not target:TriggerSpellAbsorb( self ) then
		local maxTargets = self:GetTalentSpecialValueFor("targets")
		local currentTargets = 1
		local duration = self:GetTalentSpecialValueFor("duration")
		local searchRadius = self:GetTalentSpecialValueFor("radius")
		local direction = CalculateDirection( position, self.projectiles[projectile] )
		local shackleTargets = caster:FindEnemyUnitsInCone(direction, position, 150, searchRadius, {order = FIND_CLOSEST})
		for _, enemy in ipairs( shackleTargets ) do
			if enemy ~= target then
				if enemy:IsMinion() then
					currentTargets = currentTargets + 0.5
				else
					currentTargets = currentTargets + 1
				end
				self:DoBolasStun( enemy, duration, false, true, target )
				if currentTargets >= maxTargets then
					break
				end
			end
		end
		if currentTargets > 1 then
			self:DoBolasStun( target, duration, false, false )
		else
			local trees = GridNav:FindTreesInCone( direction, position, 150, searchRadius )
			for _, tree in ipairs( trees ) do
				self:DoBolasStun( target, duration, false, true, tree, true )
				return
			end
			self:DoBolasStun( target, self:GetTalentSpecialValueFor("fail_duration") )
		end
	end
end

modifier_windrunner_bolas_primary = class({})
LinkLuaModifier("modifier_windrunner_bolas_primary", "heroes/hero_windrunner/windrunner_bolas", LUA_MODIFIER_MOTION_NONE)
function modifier_windrunner_bolas_primary:OnCreated(kv)
	self:OnRefresh(kv)
end

function modifier_windrunner_bolas_primary:OnRefresh(kv)
	self.damage = self:GetTalentSpecialValueFor("damage") * 0.25
	self.evasion = self:GetCaster():FindTalentValue("special_bonus_unique_windrunner_bolas_1")
	if IsServer() then
		self.tick = 0.25 * ( kv.duration / kv.original_duration )
		self:StartIntervalThink( self.tick )
	end
end

function modifier_windrunner_bolas_primary:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.damage )
end

function modifier_windrunner_bolas_primary:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function modifier_windrunner_bolas_primary:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_windrunner_bolas_primary:IsHidden()
	return true
end

function modifier_windrunner_bolas_primary:IsPurgable()
	return false
end

function modifier_windrunner_bolas_primary:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end