earth_spirit_rock_pull_bh = class({})
LinkLuaModifier( "modifier_rock_pull", "heroes/hero_earth_spirit/earth_spirit_rock_pull_bh.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rock_pull_enemy", "heroes/hero_earth_spirit/earth_spirit_rock_pull_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

function earth_spirit_rock_pull_bh:IsStealable()
	return true
end

function earth_spirit_rock_pull_bh:IsHiddenWhenStolen()
	return false
end

function earth_spirit_rock_pull_bh:CastFilterResultTarget( target )
	if target:GetName() == "npc_dota_earth_spirit_stone" then
		return UF_SUCCESS
	else
		return UnitFilter( target, TernaryOperator( DOTA_UNIT_TARGET_TEAM_BOTH ,self:GetCaster():HasTalent("special_bonus_unique_earth_spirit_rock_pull_1"), DOTA_UNIT_TARGET_TEAM_ENEMY ), DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0,self:GetCaster():GetTeamNumber() )
	end
end

function earth_spirit_rock_pull_bh:OnAbilityPhaseStart()
	self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_3 )
	return true
end

function earth_spirit_rock_pull_bh:OnAbilityPhaseInterrupted()
	self:GetCaster():RemoveGesture( ACT_DOTA_CAST_ABILITY_3 )
end


function earth_spirit_rock_pull_bh:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
	if not target then
		local stones = caster:FindFriendlyUnitsInRadius(self:GetCursorPosition(), 250, {type = DOTA_UNIT_TARGET_ALL, flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE })
		for _,stone in ipairs(stones) do
			if stone:GetName() == "npc_dota_earth_spirit_stone" then
				target = stone
				break
			end
		end
	end
	if not target then
		self:EndCooldown()
		self:RefundManaCost()
		caster:RemoveGesture( ACT_DOTA_CAST_ABILITY_3 )
		return
	end
    EmitSoundOn("Hero_EarthSpirit.GeomagneticGrip.Cast", caster)

    local maxTargets = 1
    local curTargets = 0
    if caster:HasTalent("special_bonus_unique_earth_spirit_rock_pull_2") then
    	maxTargets = maxTargets + caster:FindTalentValue("special_bonus_unique_earth_spirit_rock_pull_2")
    end
	if target:GetName() == "npc_dota_earth_spirit_stone" or ( self:GetCaster():HasTalent("special_bonus_unique_earth_spirit_rock_pull_1") and target:IsSameTeam(caster) ) then
		target:AddNewModifier(caster, self, "modifier_rock_pull", {})
	elseif not target:IsSameTeam(caster) then
		target:AddNewModifier(caster, self, "modifier_rock_pull_enemy", {duration = 0.5})
	end
	EmitSoundOn("Hero_EarthSpirit.GeomagneticGrip.Target", target)
	
	-- Magnetized effects
	if target:HasModifier("modifier_magnetize") or target:HasModifier("modifier_magnetize_stone") then
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
			if enemy:HasModifier("modifier_magnetize") then
				enemy:AddNewModifier(caster, self, "modifier_rock_pull_enemy", {duration = 0.5})
			end
		end
	end
end

modifier_rock_pull = class({})

function modifier_rock_pull:OnCreated(table)
	if IsServer() then
		caster = self:GetCaster()
		target = self:GetParent()
		self.silence = self:GetSpecialValueFor("duration")
		self.radius = self:GetSpecialValueFor("radius")
		self.damage = self:GetSpecialValueFor("damage")
		self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_geomagentic_target_sphere.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlForward( self.nfx, 3, CalculateDirection(self:GetParent(), self:GetCaster() ) )
		self:AddEffect( self.nfx )
		self.hitTable = {}
		self:StartMotionController()
	end
end

function modifier_rock_pull:DoControlledMotion()
	caster = self:GetCaster()
	target = self:GetParent()
	ability = self:GetAbility()

	local direction = CalculateDirection(target, caster)
	local distance = CalculateDistance(target, caster)
	
	local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), self.radius)
	for _,enemy in pairs(enemies) do
		if not self.hitTable[enemy] then
			EmitSoundOn("Hero_EarthSpirit.BoulderSmash.Silence", enemy)
			enemy:Silence(ability, caster, self.silence)
			ability:DealDamage( caster, enemy, self.damage )
			self.hitTable[enemy] = true
			if enemy:HasModifier("modifier_magnetize") then
				for _, enemyRipple in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
					if enemyRipple:HasModifier("modifier_magnetize") then
						enemyRipple:Silence(ability, caster, self.silence)
						ability:DealDamage( caster, enemyRipple, self.damage )
					end
				end
			end
		end
	end

	if distance > 150 then
		target:SetAbsOrigin( GetGroundPosition( target:GetAbsOrigin() - direction * 30, target ) )
		ParticleManager:SetParticleControlForward( self.nfx, 3, direction )
	else
		FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)
		self:Destroy()
	end
end

-- function modifier_rock_pull:GetEffectName()
	-- return "particles/units/heroes/hero_earth_spirit/espirit_geomagentic_target_sphere.vpcf"
-- end

function modifier_rock_pull:IsHidden()
	return true
end

modifier_rock_pull_enemy = class({})

function modifier_rock_pull_enemy:OnCreated(table)
	if IsServer() then
		self:OnRefresh()
		
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_geomagentic_target_sphere.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlForward( nfx, 3, CalculateDirection(self:GetParent(), self:GetCaster() ) )
		self:GetParent():ApplyKnockBack(self:GetCaster():GetAbsOrigin(), self:GetRemainingTime(), self:GetRemainingTime(), -50, 0, self:GetCaster(), ability, false)
		self:AddEffect( nfx )
	end
end

function modifier_rock_pull_enemy:OnRefresh(table)
	if IsServer() then
		EmitSoundOn("Hero_EarthSpirit.GeomagneticGrip.Damage", self:GetParent())
		if not self:GetParent():TriggerSpellAbsorb( self:GetAbility() ) then self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetSpecialValueFor("target_damage"), {}, 0) end
	end
end

function modifier_rock_pull_enemy:IsHidden()
	return true
end

-- function modifier_rock_pull_enemy:GetEffectName()
	-- return "particles/units/heroes/hero_earth_spirit/espirit_geomagentic_target_sphere.vpcf"
-- end