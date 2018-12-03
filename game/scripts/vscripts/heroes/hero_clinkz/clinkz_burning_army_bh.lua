clinkz_burning_army_bh = class({})

function clinkz_burning_army_bh:IsStealable()
    return true
end

function clinkz_burning_army_bh:IsHiddenWhenStolen()
    return false
end

function clinkz_burning_army_bh:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    local caster = self:GetCaster()
    local talent = "special_bonus_unique_clinkz_burning_army_bh_2"
    if caster:HasTalent( talent ) then cooldown = cooldown + caster:FindTalentValue( talent ) end
    return cooldown
end

function clinkz_burning_army_bh:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Hero_Clinkz.BurningArmy.Cast")
	return true
end

function clinkz_burning_army_bh:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound("Hero_Clinkz.BurningArmy.Cast")
end

function clinkz_burning_army_bh:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition() 

	caster:EmitSound("Hero_Clinkz.BurningArmy.SpellStart")
	local ogSkeletons = self:GetTalentSpecialValueFor("count")
	local skeletons = ogSkeletons
	local duration = self:GetTalentSpecialValueFor("duration")
	local attackRate = self:GetTalentSpecialValueFor("attack_rate")
	local spawnRate = self:GetTalentSpecialValueFor("spawn_interval")
	if caster:HasTalent("special_bonus_unique_clinkz_burning_army_1") then
		local angle = 0
		local radius = self:GetTalentSpecialValueFor("range") / (2 * math.pi)
		Timers:CreateTimer(spawnRate, function()
			local spawnPosition = Vector(position.x+radius*math.sin(angle), position.y+radius*math.cos(angle), position.z)
			self:CreateSkeletonArcher( spawnPosition, duration, attackRate )
			skeletons = skeletons - 1
			angle = angle + ( 2 * math.pi /(ogSkeletons) )
			if skeletons > 0 then
				return spawnRate
			end
		end)
	else
		local spawnDistance = self:GetTalentSpecialValueFor("range") / skeletons
		local spawnDirection = CalculateDirection( position, caster )
		local spawnPosition = self:GetCaster():GetAbsOrigin() + spawnDirection * spawnDistance
		Timers:CreateTimer(spawnRate, function()
			self:CreateSkeletonArcher( spawnPosition, duration, attackRate )
			skeletons = skeletons - 1
			spawnPosition = spawnPosition + spawnDistance * spawnDirection
			if skeletons > 0 then
				return spawnRate
			end
		end)
	end
end

function clinkz_burning_army_bh:CreateSkeletonArcher( position, duration, attackRate )
	local caster = self:GetCaster()
	local skeleton, duration = caster:CreateSummon("npc_dota_clinkz_skeleton_archer", position, duration or self:GetTalentSpecialValueFor("duration"), false )
	skeleton:RemoveAbility("clinkz_searing_arrows")
	-- self:StartDelayedCooldown(duration)
	skeleton:AddAbility("generic_hp_limiter"):UpgradeAbility(true)
	if caster:HasAbility("clinkz_arrows") then
		local searing = skeleton:AddAbility("clinkz_arrows")
		searing:UpgradeAbility(true)
		searing:SetLevel( caster:FindAbilityByName("clinkz_arrows"):GetLevel() )
		searing:ToggleAutoCast()
	end
	
	skeleton:SetBaseAttackTime( attackRate or self:GetTalentSpecialValueFor("attack_rate") )
	local searchRadius = skeleton:GetAttackRange()
	if caster:HasTalent("special_bonus_unique_clinkz_burning_army_2") then
		skeleton:SetBaseMoveSpeed( caster:GetIdealSpeed() )
		skeleton:SetMoveCapability( DOTA_UNIT_CAP_MOVE_GROUND )
		searchRadius = searchRadius + skeleton:GetIdealSpeed()
	else
		skeleton:SetBaseMoveSpeed( 0 )
		skeleton:SetMoveCapability( DOTA_UNIT_CAP_MOVE_NONE )
	end
	Timers:CreateTimer(0.5, function()
		if skeleton and not skeleton:IsNull() and skeleton:IsAlive() then
			if not skeleton.target or skeleton.target:IsNull() or not skeleton.target:IsAlive() then skeleton.target = nil end
			if skeleton.target and CalculateDistance( skeleton, skeleton.target ) <= skeleton:GetAttackRange() then
				skeleton:SetAttacking(skeleton.target)
				skeleton:MoveToTargetToAttack( skeleton.target )
			else
				if skeleton.target and CalculateDistance( skeleton, skeleton.target ) <= searchRadius then
					if caster:HasTalent("special_bonus_unique_clinkz_burning_army_2") and caster:HasTalent("special_bonus_unique_clinkz_burning_army_2") then
						ExecuteOrderFromTable({
							UnitIndex = skeleton:entindex(),
							OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET,
							TargetIndex = skeleton.target:entindex()
						})
					end
				else
					skeleton.target = nil
					for _, enemy in ipairs( skeleton:FindEnemyUnitsInRadius( skeleton:GetAbsOrigin(), searchRadius ) ) do
						if enemy:IsAlive() then
							skeleton.target = enemy
							skeleton:SetAttacking(skeleton.target)
							skeleton:MoveToTargetToAttack( skeleton.target )
						end
					end
				end
			end
			if not skeleton.target then
				skeleton:SetAttacking(nil)
				skeleton:MoveToTargetToAttack( nil )
				skeleton:Interrupt()
				skeleton:Stop()
				skeleton:Hold()
			end
			return 0.5
		end
	end)
	ParticleManager:FireParticle("particles/units/heroes/hero_clinkz/clinkz_burning_army_start.vpcf", PATTACH_POINT_FOLLOW, skeleton)
	local sfx = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_burning_army.vpcf", PATTACH_POINT_FOLLOW, skeleton)
	ParticleManager:ReleaseParticleIndex(sfx)
	skeleton:EmitSound("Hero_Clinkz.Skeleton_Archer.Spawn")
end