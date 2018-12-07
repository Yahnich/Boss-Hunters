wk_skeletons = class({})
LinkLuaModifier("modifier_wk_skeletons_passive", "heroes/hero_wraith_king/wk_skeletons", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wk_skeletons_charges", "heroes/hero_wraith_king/wk_skeletons", LUA_MODIFIER_MOTION_NONE)
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
    if caster:HasModifier("modifier_wk_skeletons_charges") then
    	self.stacks = caster:FindModifierByName("modifier_wk_skeletons_charges"):GetStackCount()
    	local i = 0

    	caster:RemoveModifierByName("modifier_wk_skeletons_charges")

    	Timers:CreateTimer(tick_rate, function()
    		if caster:HasTalent("special_bonus_unique_wk_skeletons_2") then
    			local pointRando = point + ActualRandomVector(500, 150)
	    		self:SpawnSkeleton(pointRando)
    		else
	    		if i < self.stacks then
	    			local pointRando = point + ActualRandomVector(500, 150)
	    			self:SpawnSkeleton(pointRando)
	    			i = i + 1
	    			return tick_rate
	    		end
	    	end
    	end)
    else
    	self:RefundManaCost()
    	self:EndCooldown()
    end
end

function wk_skeletons:SpawnSkeleton(position)
	local caster = self:GetCaster()
 
	local duration = self:GetTalentSpecialValueFor("skeleton_duration")
	local damage = caster:GetAttackDamage() * self:GetTalentSpecialValueFor("skeleton_damage")/100
	local health = caster:GetMaxHealth() * self:GetTalentSpecialValueFor("skeleton_health")/100

	local unit = nil

	--Skeleton Knights----------------------------
	if caster:HasTalent("special_bonus_unique_wk_skeletons_2") then
		health = health * self.stacks
		damage = damage * self.stacks
		local mana = caster:GetMaxMana()
		local armor = caster:GetPhysicalArmorValue()
		local attackTime = caster:GetSecondsPerAttack()

		local ability1 = caster:FindAbilityByName("wk_blast")
		local ability2 = caster:FindAbilityByName("wk_crit")

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_tombstone_spawn.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(nfx, 0, position)
					ParticleManager:ReleaseParticleIndex(nfx)

		skeleton = caster:CreateSummon("npc_dota_skeleton_knight", position, duration, true)

		local sword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/skeleton_king/sk_sns2b/sk_sns2b.vmdl"})
		sword:FollowEntity(skeleton, true)

		local glove = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/skeleton_king/sk_dreadknight_arms/sk_dreadknight_arms.vmdl"})
		glove:FollowEntity(skeleton, true)
		skeleton:AddNewModifier(caster, self, "modifier_wk_skeletons_ai", {})

		skeleton:SetMana(mana)
		skeleton:SetPhysicalArmorBaseValue(armor)
		skeleton:SetBaseAttackTime(attackTime)

		skeleton:AddAbility("wk_blast"):SetLevel(ability1:GetLevel())
		skeleton:AddAbility("wk_crit"):SetLevel(ability2:GetLevel())

	--Skeleton Warriors----------------------------
	else
		local nfx = ParticleManager:CreateParticle("particles/items2_fx/ward_spawn_generic.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(nfx, 0, position)
					ParticleManager:ReleaseParticleIndex(nfx)

		skeleton = caster:CreateSummon("npc_dota_wraith_king_skeleton_warrior", position, duration, true)

	end

	FindClearSpaceForUnit(skeleton, position, true)

	skeleton:SetBaseMaxHealth( health )
	skeleton:SetMaxHealth( health )
	skeleton:SetHealth( health )
	skeleton:SetAverageBaseDamage( damage, 15 )
	skeleton:SetBaseMoveSpeed(caster:GetIdealSpeedNoSlows())
	skeleton:SetHullRadius(2)
	skeleton:EmitSound("n_creep_Skeleton.Spawn")
end

function wk_skeletons:IncrementCharge()
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_wk_skeletons_charges") then
		if caster:FindModifierByName("modifier_wk_skeletons_charges"):GetStackCount() < self:GetTalentSpecialValueFor("max_skeleton_charges") then
			caster:AddNewModifier(caster, self, "modifier_wk_skeletons_charges", {}):IncrementStackCount()
		else
			caster:AddNewModifier(caster, self, "modifier_wk_skeletons_charges", {})
		end
	else
		caster:AddNewModifier(caster, self, "modifier_wk_skeletons_charges", {}):IncrementStackCount()
	end
end

modifier_wk_skeletons_passive = class({})
function modifier_wk_skeletons_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_wk_skeletons_passive:OnDeath(params)
	if IsServer() then
		local caster = self:GetCaster()
		local attacker = params.attacker
		local unit = params.unit

		if attacker == caster and unit ~= caster then
			self:GetAbility():IncrementCharge()
		end
	end
end

function modifier_wk_skeletons_passive:IsHidden()
	return true
end

modifier_wk_skeletons_charges = class({})
function modifier_wk_skeletons_charges:IsHidden() return false end
function modifier_wk_skeletons_charges:IsDebuff() return false end
function modifier_wk_skeletons_charges:IsPurgeException() return false end
function modifier_wk_skeletons_charges:IsPurgable() return false end

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

