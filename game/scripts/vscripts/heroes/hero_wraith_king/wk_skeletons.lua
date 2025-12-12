wk_skeletons = class({})
LinkLuaModifier("modifier_wk_skeletons_ai", "heroes/hero_wraith_king/wk_skeletons", LUA_MODIFIER_MOTION_NONE)

function wk_skeletons:IsStealable()
    return true
end

function wk_skeletons:IsHiddenWhenStolen()
    return false
end

function wk_skeletons:GetCastPoint()
    return 1
end

function wk_skeletons:GetIntrinsicModifierName()
	return "modifier_wk_skeletons_passive"
end

function wk_skeletons:OnSpellStart()
    local caster = self:GetCaster()
    local point = caster:GetAbsOrigin()

    local tick_rate = self:GetSpecialValueFor("spawn_interval")
    caster:EmitSound("n_creep_TrollWarlord.RaiseDead")
	
	self.skeletons = self.skeletons or {}
	for i = #self.skeletons, 1, -1 do
		local skellington = self.skeletons[i]
		if skellington:IsNull() then
			table.remove( self.skeletons, i )
		end
	end
    if self.skeletonModifier and not self.skeletonModifier:IsNull() then
    	local skellingtonsToSpawn = self.skeletonModifier:GetStackCount()
		if caster:HasTalent("special_bonus_unique_wk_skeletons_1") then
			skellingtonsToSpawn = skellingtonsToSpawn * ( caster:FindTalentValue("special_bonus_unique_wk_skeletons_1") + 1 )
		end
    	local i = 0
    	self.skeletonModifier:SetStackCount( 0 )

    	Timers:CreateTimer(tick_rate, function()
			i = i + 1
			local skeletonMan = self.skeletons[i]
			if skeletonMan and not skeletonMan:IsNull() then
				self:UpdateSkeleton( skeletonMan )
				local pointRando = point + ActualRandomVector(500, 150)
				FindClearSpaceForUnit(skeletonMan, pointRando, true)
				skeletonMan:EmitSound("n_creep_Skeleton.Spawn")
				skeletonMan:StartGesture( ACT_DOTA_SPAWN )
			else
				local pointRando = point + ActualRandomVector(500, 150)
				self:SpawnSkeleton(pointRando, true)
			end
			if i < skellingtonsToSpawn then
				return tick_rate
			end
    	end)
		if caster:HasScepter() then
			if self.deathKnight then
				if self.deathKnight:IsAlive() then
					self.deathKnight:RefreshAllCooldowns( )
					self.deathKnight:SetHealth( self.deathKnight:GetMaxHealth() )
					self.deathKnight:SetMana( self.deathKnight:GetMaxMana() )
				else
					self:UpdateSkeleton( skeleton )
				end
			else
				Timers:CreateTimer(tick_rate, function() self:SpawnDeathKnight( point - caster:GetForwardVector() * 150, skellingtonsToSpawn ) end)
			end
		end
    end
end

function wk_skeletons:SpawnDeathKnight(position, power)
	local caster = self:GetCaster()
	local nfx = ParticleManager:CreateParticle("particles/items2_fx/ward_spawn_generic.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(nfx, 0, position)
	ParticleManager:ReleaseParticleIndex(nfx)
	local skeleton = caster:CreateSummon("npc_dota_skeleton_knight", position, -1, true)

	FindClearSpaceForUnit(skeleton, position, true)
	
	skeleton:SetHullRadius(4)
	skeleton:EmitSound("n_creep_Skeleton.Spawn")
	skeleton:StartGesture( ACT_DOTA_SPAWN )

	self.deathKnight = skeleton
	skeleton.isDeathKnight = true
	skeleton.deathKnightMultiplier = power
	
	local sword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/skeleton_king/sk_sns2b/sk_sns2b.vmdl"})
	sword:FollowEntity(skeleton, true)

	local glove = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/skeleton_king/sk_dreadknight_arms/sk_dreadknight_arms.vmdl"})
	glove:FollowEntity(skeleton, true)
	skeleton:SetUnitCanRespawn( true )
	self:UpdateSkeleton( skeleton )
end

function wk_skeletons:SpawnSkeleton(position, bCapAmount)
	local caster = self:GetCaster()
	local nfx = ParticleManager:CreateParticle("particles/items2_fx/ward_spawn_generic.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(nfx, 0, position)
	ParticleManager:ReleaseParticleIndex(nfx)
	
	skeleton = caster:CreateSummon("npc_dota_wraith_king_skeleton_warrior", position, -1, false)
	FindClearSpaceForUnit(skeleton, position, true)
	
	skeleton:SetHullRadius(4)
	skeleton:EmitSound("n_creep_Skeleton.Spawn")
	skeleton:StartGesture( ACT_DOTA_SPAWN )

	if bCapAmount then 
		table.insert( self.skeletons, skeleton )
		skeleton:SetUnitCanRespawn( true )
	end
	self:UpdateSkeleton( skeleton )
end

function wk_skeletons:UpdateSkeleton( skeleton )
	local caster = self:GetCaster()
	local damage = (self:GetSpecialValueFor("skeleton_base_dmg") + self:GetSpecialValueFor("skeleton_lvl_dmg") * caster:GetLevel() )
	local health = self:GetSpecialValueFor("skeleton_base_hp") + self:GetSpecialValueFor("skeleton_lvl_hp") * caster:GetLevel()
	

	if not skeleton:IsAlive() then skeleton:RespawnUnit() end
	
	if skeleton.isDeathKnight then
		damage = damage * skeleton.deathKnightMultiplier
		health = health * skeleton.deathKnightMultiplier
		
		skeleton:SetMana( skeleton:GetMaxMana() )
		skeleton:SetPhysicalArmorBaseValue( caster:GetPhysicalArmorValue(false) )
	end
	
	skeleton:SetCoreHealth( health )
	skeleton:SetAverageBaseDamage( damage, 15 )
	skeleton:SetBaseMoveSpeed(caster:GetIdealSpeedNoSlows())
	
	local reincarnation = caster:FindAbilityByName("wk_reincarnation")
	if reincarnation and reincarnation:IsTrained() then
		skeletonReincarnation = skeleton:FindAbilityByName("wk_reincarnation")
		if not skeletonReincarnation then
			skeleton:AddAbility( "wk_reincarnation" ):SetLevel( reincarnation:GetLevel() )
		else
			skeletonReincarnation:SetLevel( reincarnation:GetLevel() )
			skeletonReincarnation:EndCooldown()
		end
	elseif skeleton:FindAbilityByName("wk_reincarnation") then
		skeleton:RemoveAbility("wk_reincarnation")
	end
	if skeleton.isDeathKnight then
		-- blast
		local blast = caster:FindAbilityByName("wk_blast")
		if blast and blast:IsTrained() then
			skeletonBlast = skeleton:FindAbilityByName("wk_blast")
			if not skeletonBlast then
				skeleton:AddAbility( "wk_blast" ):SetLevel( blast:GetLevel() )
			else
				skeletonBlast:SetLevel( blast:GetLevel() )
				skeletonBlast:EndCooldown()
			end
		elseif skeleton:FindAbilityByName("wk_blast") then
			skeleton:RemoveAbility("wk_blast")
		end
		-- crit
		local crit = caster:FindAbilityByName("wk_crit")
		if crit and crit:IsTrained() then
			skeletonCrit = skeleton:FindAbilityByName("wk_crit")
			if not skeletonCrit then
				skeleton:AddAbility( "wk_crit" ):SetLevel( crit:GetLevel() )
			else
				skeletonCrit:SetLevel( crit:GetLevel() )
				skeletonCrit:EndCooldown()
			end
		elseif skeleton:FindAbilityByName("wk_crit") then
			skeleton:RemoveAbility("wk_crit")
		end
	end
end

function wk_skeletons:IncrementCharge(amount)
	local caster = self:GetCaster()
	
	local bCount = amount or 1
	local skeletonMax = self:GetSpecialValueFor("max_skeleton_charges")
	local stacks = self.skeletonModifier:GetStackCount()
	if stacks < skeletonMax then
		self.skeletonModifier:SetStackCount( math.min( skeletonMax, stacks + bCount ) )
	end
end

modifier_wk_skeletons_passive = class({})
LinkLuaModifier("modifier_wk_skeletons_passive", "heroes/hero_wraith_king/wk_skeletons", LUA_MODIFIER_MOTION_NONE)

function modifier_wk_skeletons_passive:OnCreated()
	self:GetAbility().skeletonModifier = self
	self.unitCharges = self:GetSpecialValueFor("unit_charges")
	self.bossCharges = self:GetSpecialValueFor("boss_charges")
	self.minionCharges = self:GetSpecialValueFor("minion_charges")
	self.auraKills = self:GetSpecialValueFor("aura_kills")
	self.currentKills = 0
end

function modifier_wk_skeletons_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_wk_skeletons_passive:OnDeath(params)
	if IsServer() then
		local caster = self:GetCaster()
		local attacker = params.attacker
		local unit = params.unit

		if attacker == caster and unit ~= caster and not unit:IsMinion() then
			local amount = self.unitCharges
			if unit:IsBoss() then
				amount = self.bossCharges
			-- elseif unit:IsMinion() then
				-- amount = self.minionCharges
			end
			self:GetAbility():IncrementCharge(amount)
			return
		end
		if not unit:IsSameTeam( caster ) then
			local aura = caster:FindAbilityByName("wk_vamp")
			if aura and aura:IsTrained() and CalculateDistance( unit, caster ) <= aura:GetTrueCastRange() then
				self.currentKills = self.currentKills + 1
				if self.currentKills >= self.auraKills then
					self.currentKills = 0
					self:GetAbility():IncrementCharge()
				end
			end
		end
	end
end

function modifier_wk_skeletons_passive:IsHidden()
	return self:GetStackCount() == 0
end