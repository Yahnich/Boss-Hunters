spectre_haunt_bh = class({})

function spectre_haunt_bh:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_spectre_haunt_2", "cd")
end

function spectre_haunt_bh:OnUpgrade( )
	local caster = self:GetCaster()
	local reality = caster:FindAbilityByName("spectre_reality_bh")
	if reality and reality:GetLevel() == 0 then
		reality:SetLevel( 1 )
		reality:SetActivated( false )
		reality.livingIllusions = {}
	end
end

function spectre_haunt_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetSpecialValueFor("duration")
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
		if not enemy:IsMinion() then
			self:SpawnHauntIllusion( enemy, duration )
			EmitSoundOn( "Hero_Spectre.Haunt", enemy )
		end
		enemy:AddNewModifier( caster, self, "modifier_spectre_haunt_darkness", {duration} )
	end
	
	ParticleManager:FireParticle( "particles/econ/items/spectre/spectre_arcana/spectre_arcana_haunt_caster.vpcf", PATTACH_POINT_FOLLOW, caster )
	EmitSoundOn( "Hero_Spectre.HauntCast", caster )
end

function spectre_haunt_bh:SpawnHauntIllusion( target, fDur )
	local caster = self:GetCaster()
	local duration = fDur or self:GetSpecialValueFor("duration")
	local outgoing = self:GetSpecialValueFor("illusion_damage_outgoing") - 100
	local incoming = self:GetSpecialValueFor("illusion_total_damage_incoming") - 100
	local position = target
	if target.GetAbsOrigin then -- entity
		position = target:GetAbsOrigin()
	end
	position = position + RandomVector( caster:GetAttackRange() * 0.75 )
	local illusions = caster:ConjureImage( {outgoing_damage = outgoing, incoming_damage = incoming, position = position, controllable = false}, duration, caster, 1 )
	
	local haunt = illusions[1]
	local attackTarget
	if target.GetAbsOrigin then -- entity
		haunt:SetAttacking( target )
		attackTarget = target
		Timers:CreateTimer(0.5, function()
			haunt:SetAttacking( enemy )
			if not target or target:IsNull() then return end
			ExecuteOrderFromTable({
				UnitIndex = haunt:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = target:entindex()
			})
			if haunt and not haunt:IsNull() and haunt:IsAlive() then
				return 0.5
			end
		end )
	else
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( haunt:GetAbsOrigin(), -1, {order = FIND_CLOSEST} ) ) do
			haunt:SetAttacking( enemy )
			attackTarget = enemy
			Timers:CreateTimer(0.5, function()
				if not target or target:IsNull() then return end
				ExecuteOrderFromTable({
					UnitIndex = haunt:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = enemy:entindex()
				})
				if haunt and not haunt:IsNull() and haunt:IsAlive() then
					return 0.5
				end
			end )
			break
		end
	end
	
	if attackTarget then
		if caster:HasTalent("special_bonus_unique_spectre_haunt_1") then
			local dagger = caster:FindAbilityByName( "spectre_spectral_dagger_bh" )
			if dagger and dagger:GetLevel() > 0 then
				dagger:LaunchSpectralDagger( attackTarget:GetAbsOrigin(), haunt )
			end
		end
	end
	
	haunt:AddNewModifier( caster, self, "modifier_spectre_haunt_ghost", {duration = duration-0.1} )
	return haunt
end

modifier_spectre_haunt_darkness = class({})
LinkLuaModifier( "modifier_spectre_haunt_darkness", "heroes/hero_spectre/spectre_haunt_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_spectre_haunt_darkness:OnCreated()
	self.vision = self:GetSpecialValueFor("vision")
end

function modifier_spectre_haunt_darkness:OnCreated()
	return {MODIFIER_PROPERTY_FIXED_DAY_VISION, MODIFIER_PROPERTY_FIXED_NIGHT_VISION}
end

function modifier_spectre_haunt_darkness:GetFixedNightVision()
	return self.vision
end

function modifier_spectre_haunt_darkness:GetFixedDayVision()
	return self.vision
end

modifier_spectre_haunt_ghost = class({})
LinkLuaModifier( "modifier_spectre_haunt_ghost", "heroes/hero_spectre/spectre_haunt_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_spectre_haunt_ghost:OnCreated()
		local caster = self:GetCaster()
		local reality = caster:FindAbilityByName("spectre_reality_bh")
		if not reality.livingIllusions then reality.livingIllusions = {} end
		table.insert ( reality.livingIllusions, self:GetParent():entindex() )
		if reality then
			reality:SetActivated( true )
		end
	end
	
	function modifier_spectre_haunt_ghost:OnDestroy()
		local caster = self:GetCaster()
		local reality = caster:FindAbilityByName("spectre_reality_bh")
		for i = #reality.livingIllusions, 1, -1 do
			local illusionIndex = reality.livingIllusions[i]
			local illusion = EntIndexToHScript( illusionIndex )
			if illusionIndex == self:GetParent():entindex() or not illusion or illusion:IsNull() or not illusion:IsAlive() then
				table.remove( reality.livingIllusions, i )
			end
		end
		if reality and #reality.livingIllusions == 0 then
			reality:SetActivated( false )
		end
	end
end

function modifier_spectre_haunt_ghost:CheckState()
	return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
end

function modifier_spectre_haunt_ghost:IsHidden()
	return true
end