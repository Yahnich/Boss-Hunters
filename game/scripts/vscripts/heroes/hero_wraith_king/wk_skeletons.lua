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

    local tick_rate = self:GetTalentSpecialValueFor("spawn_interval")
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
			if skeletonMan and not skeletonMan:IsNull()then
				self:UpdateSkeleton( skeletonMan )
				local pointRando = point + ActualRandomVector(500, 150)
				FindClearSpaceForUnit(skeletonMan, pointRando, true)
				skeletonMan:EmitSound("n_creep_Skeleton.Spawn")
				skeletonMan:StartGesture( ACT_DOTA_SPAWN )
			else
				local pointRando = point + ActualRandomVector(500, 150)
				self:SpawnSkeleton(pointRando)
			end
			if i < skellingtonsToSpawn then
				return tick_rate
			end
    	end)
    end
end

function wk_skeletons:SpawnDeathKnight(position)
	local caster = self:GetCaster()
	local nfx = ParticleManager:CreateParticle("particles/items2_fx/ward_spawn_generic.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(nfx, 0, position)
	ParticleManager:ReleaseParticleIndex(nfx)
	local skeleton = caster:CreateSummon("npc_dota_skeleton_knight", position, -1, true)

	FindClearSpaceForUnit(skeleton, position, true)
	
	skeleton:SetHullRadius(4)
	skeleton:EmitSound("n_creep_Skeleton.Spawn")
	skeleton:StartGesture( ACT_DOTA_SPAWN )

	table.insert( self.skeletons, skeleton )
	
	local caster = self:GetCaster()
	local damage = ( self:GetTalentSpecialValueFor("skeleton_base_dmg") + self:GetTalentSpecialValueFor("skeleton_lvl_dmg") * caster:GetLevel() ) * caster:FindTalentValue("special_bonus_unique_wk_reincarnation_1")
	local health = ( self:GetTalentSpecialValueFor("skeleton_base_hp") + self:GetTalentSpecialValueFor("skeleton_lvl_hp") * caster:GetLevel() ) * caster:FindTalentValue("special_bonus_unique_wk_reincarnation_1")
	
	local sword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/skeleton_king/sk_sns2b/sk_sns2b.vmdl"})
	sword:FollowEntity(skeleton, true)

	local glove = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/skeleton_king/sk_dreadknight_arms/sk_dreadknight_arms.vmdl"})
	glove:FollowEntity(skeleton, true)
	skeleton:AddNewModifier(caster, self, "modifier_wk_skeletons_ai", {})
	
	skeleton:SetMana( skeleton:GetMaxMana() )
	skeleton:SetPhysicalArmorBaseValue( caster:GetPhysicalArmorValue(false) )
	skeleton:SetCoreHealth( health )
	skeleton:SetAverageBaseDamage( damage, 15 )
	skeleton:SetBaseMoveSpeed(caster:GetIdealSpeedNoSlows())
	
	skeleton:AddAbility("wk_blast"):SetLevel(caster:FindAbilityByName("wk_blast"):GetLevel())
	skeleton:AddAbility("wk_crit"):SetLevel(caster:FindAbilityByName("wk_crit"):GetLevel())
	skeleton:AddAbility("wk_reincarnation"):SetLevel(caster:FindAbilityByName("wk_reincarnation"):GetLevel())
end

function wk_skeletons:SpawnSkeleton(position)
	local caster = self:GetCaster()
	local nfx = ParticleManager:CreateParticle("particles/items2_fx/ward_spawn_generic.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(nfx, 0, position)
	ParticleManager:ReleaseParticleIndex(nfx)
	local skeleton = caster:CreateSummon("npc_dota_wraith_king_skeleton_warrior", position, -1, false)

	FindClearSpaceForUnit(skeleton, position, true)
	
	skeleton:SetHullRadius(4)
	skeleton:EmitSound("n_creep_Skeleton.Spawn")
	skeleton:StartGesture( ACT_DOTA_SPAWN )

	table.insert( self.skeletons, skeleton )
	skeleton:SetUnitCanRespawn( true )
	self:UpdateSkeleton( skeleton )
end

function wk_skeletons:UpdateSkeleton( skeleton )
	local caster = self:GetCaster()
	local damage = self:GetTalentSpecialValueFor("skeleton_base_dmg") + self:GetTalentSpecialValueFor("skeleton_lvl_dmg") * caster:GetLevel()
	local health = self:GetTalentSpecialValueFor("skeleton_base_hp") + self:GetTalentSpecialValueFor("skeleton_lvl_hp") * caster:GetLevel()

	if not skeleton:IsAlive() then skeleton:RespawnUnit() end
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
end

function wk_skeletons:IncrementCharge(amount)
	local caster = self:GetCaster()
	
	local bCount = amount or 1
	local skeletonMax = self:GetTalentSpecialValueFor("max_skeleton_charges")
	local stacks = self.skeletonModifier:GetStackCount()
	if stacks < skeletonMax then
		self.skeletonModifier:SetStackCount( math.min( skeletonMax, stacks + bCount ) )
	end
end

modifier_wk_skeletons_passive = class({})
LinkLuaModifier("modifier_wk_skeletons_passive", "heroes/hero_wraith_king/wk_skeletons", LUA_MODIFIER_MOTION_NONE)

function modifier_wk_skeletons_passive:OnCreated()
	self:GetAbility().skeletonModifier = self
	self.unitCharges = self:GetTalentSpecialValueFor("unit_charges")
	self.bossCharges = self:GetTalentSpecialValueFor("boss_charges")
	self.minionCharges = self:GetTalentSpecialValueFor("minion_charges")
	self.auraKills = self:GetTalentSpecialValueFor("aura_kills")
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

		if attacker == caster and unit ~= caster then
			local amount = self.unitCharges
			if unit:IsBoss() then
				amount = self.bossCharges
			elseif unit:IsMinion() then
				amount = self.minionCharges
			end
			self:GetAbility():IncrementCharge(amount)
			return
		end
		if attacker ~= caster and not unit:IsSameTeam( caster ) then
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

modifier_wk_skeletons_ai = class({})
function modifier_wk_skeletons_ai:OnCreated(table)
	if IsServer() then
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_ghosts_ambient.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
					ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AttachEffect(nfx)

		--self:StartIntervalThink(0.25)
	end
end

function modifier_wk_skeletons_ai:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not parent:GetAttackTarget() then
		local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), 1000)
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				parent:SetAttacking(enemy)
				break
			end
		else
			--parent:MoveToNPC(caster)
		end
	end
end

function modifier_wk_skeletons_ai:GetStatusEffectName()
	return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
end

function modifier_wk_skeletons_ai:StatusEffectPriority()
	return 10
end

function modifier_wk_skeletons_ai:IsHidden()
	return true
end

