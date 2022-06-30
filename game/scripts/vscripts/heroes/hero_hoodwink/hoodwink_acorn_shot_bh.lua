hoodwink_acorn_shot_bh = class({})

function hoodwink_acorn_shot_bh:GetCastRange( target, position )
	return self:GetCaster():GetAttackRange() + self:GetTalentSpecialValueFor("bonus_range")
end

function hoodwink_acorn_shot_bh:GetBehavior( )
	local behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_POINT
	if self:GetCaster():HasTalent("special_bonus_unique_hoodwink_acorn_shot_1") then
		behavior = behavior + DOTA_ABILITY_BEHAVIOR_AOE
	end
	return behavior
end

function hoodwink_acorn_shot_bh:GetAOERadius( )
	return self:GetCaster():FindTalentValue("special_bonus_unique_hoodwink_acorn_shot_1", "radius")
end

function hoodwink_acorn_shot_bh:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl )
end

function hoodwink_acorn_shot_bh:GetManaCost( iLvl )
	if self:GetCaster():HasTalent("special_bonus_unique_hoodwink_acorn_shot_2") then
		return 0
	else
		return self.BaseClass.GetManaCost( self, iLvl )
	end
end

function hoodwink_acorn_shot_bh:GetIntrinsicModifierName()
	return "modifier_hoodwink_acorn_shot_charges"
end

function hoodwink_acorn_shot_bh:OnInventoryContentsChanged()
	local caster = self:GetCaster()
	local modifier = caster:FindModifierByName( self:GetIntrinsicModifierName() )
	if not modifier then return end
	if caster:HasScepter() and not self.hasScepter then
		if not self.firstScepter and modifier then
			self.firstScepter = true
			modifier:SetStackCount( modifier:GetStackCount() + ( self:GetTalentSpecialValueFor("scepter_ability_charges") - self:GetTalentSpecialValueFor("ability_charges") ) )
		end
		modifier:Update( false )
		self.hasScepter = true
	elseif not caster:HasScepter() and self.hasScepter then
		modifier:Update( false )
		self.hasScepter = false
	end
end

function hoodwink_acorn_shot_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget() or self:GetCursorPosition()
	local position = self:GetCursorPosition()
	
	self.projectileData = self.projectileData or {}
	self:FireAcorn( target )
	
	if caster:HasTalent("special_bonus_unique_hoodwink_acorn_shot_1") then
		local radius = caster:FindTalentValue("special_bonus_unique_hoodwink_acorn_shot_1", "radius")
		local enemies = caster:FindEnemyUnitsInRadius( position, radius )
		print( "enemies:", #enemies )
		if #enemies <= 1 then
			local acorns = caster:FindTalentValue("special_bonus_unique_hoodwink_acorn_shot_1", "value2")
			for i = 1, acorns do
				self:FireAcorn( position + ActualRandomVector( radius ), 1 )
			end
		else
			for _, enemy in ipairs( enemies ) do
				if enemy ~= target then
					self:FireAcorn( enemy, 0 )
				end
			end
		end
	end
	
	EmitSoundOn( "Hero_Hoodwink.AcornShot.Cast", caster )
end

function hoodwink_acorn_shot_bh:FireAcorn( target, bounces )
	local caster = self:GetCaster()
	local bounces = bounces or self:GetTalentSpecialValueFor("bounce_count")
	if not target.GetAbsOrigin then -- vector
		local direction = CalculateDirection( target, caster )
		local distance = CalculateDistance( target, caster )
		local projIndex = self:FireLinearProjectile("particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_initial.vpcf", self:GetTalentSpecialValueFor("projectile_speed") * direction, distance, 100, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 200)
		self.projectileData[projIndex] = {}
		self.projectileData[projIndex].isTracking = false
		self.projectileData[projIndex].bounces = bounces
	else -- vector
		local projIndex = self:FireTrackingProjectile("particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_tracking.vpcf", target, self:GetTalentSpecialValueFor("projectile_speed"), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 200)
		self.projectileData[projIndex] = {}
		self.projectileData[projIndex].isTracking = true
		self.projectileData[projIndex].bounces = bounces
	end
end

function hoodwink_acorn_shot_bh:OnProjectileHitHandle( target, position, projectile )
	local data = self.projectileData[projectile]
	local caster = self:GetCaster()
	if data then
		if data.isTracking then
			if target then
				caster:PerformGenericAttack(target, true, self:GetTalentSpecialValueFor("bonus_damage"))
				target:AddNewModifier( caster, self, "modifier_hoodwink_acorn_shot_bh_slow", { duration = self:GetTalentSpecialValueFor("debuff_duration")} )
				EmitSoundOn( "Hero_Hoodwink.AcornShot.Target", caster )
				EmitSoundOn( "Hero_Hoodwink.AcornShot.Slow", caster )
				if self.projectileData[projectile].bounces > 0 then
					for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(position, self:GetTalentSpecialValueFor("bounce_range")) ) do
						if enemy ~= target then
							EmitSoundOn( "Hero_Hoodwink.AcornShot.Bounce", caster )
							local projIndex = self:FireTrackingProjectile("particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_tracking.vpcf", enemy, self:GetTalentSpecialValueFor("projectile_speed"), {source = target}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 200)
							self.projectileData[projIndex] = {}
							self.projectileData[projIndex].isTracking = true
							self.projectileData[projIndex].bounces = self.projectileData[projectile].bounces - 1
							self.projectileData[projectile] = nil
							break
						end
					end
				end
			end
		elseif not target then
			EmitSoundOn( "Hero_Hoodwink.AcornShot.Target", caster )
			local dummy = caster:CreateDummy( position, 20 )
			dummy:AddNewModifier( caster, self, "hoodwink_acorn_shot_bh_dummy", {} )
			AddFOWViewer( caster:GetTeam(), position, 200, 20, false )
			CreateTempTree( position, 20 )
			ResolveNPCPositions( position, 128 )
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(position, self:GetTalentSpecialValueFor("bounce_range")) ) do
				if enemy ~= target then
					EmitSoundOn( "Hero_Hoodwink.AcornShot.Bounce", caster )
					local projIndex = self:FireTrackingProjectile("particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_tracking.vpcf", enemy, self:GetTalentSpecialValueFor("projectile_speed"), {source = dummy}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 200)
					self.projectileData[projIndex] = {}
					self.projectileData[projIndex].isTracking = true
					self.projectileData[projIndex].bounces = data.bounces
					self.projectileData[projectile] = nil
					break
				end
			end
		end
	end
end

modifier_hoodwink_acorn_shot_bh_slow = class({})
LinkLuaModifier("modifier_hoodwink_acorn_shot_bh_slow", "heroes/hero_hoodwink/hoodwink_acorn_shot_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_hoodwink_acorn_shot_bh_slow:OnCreated()
	self:OnRefresh()
end

function modifier_hoodwink_acorn_shot_bh_slow:OnRefresh()
	self.moveslow = self:GetTalentSpecialValueFor("slow")
	if self:GetCaster():FindTalentValue("special_bonus_unique_hoodwink_acorn_shot_2") then
		self.attackslow = self.moveslow * self:GetTalentSpecialValueFor("slow") / 100
	end
end

function modifier_hoodwink_acorn_shot_bh_slow:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_hoodwink_acorn_shot_bh_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.moveslow
end

function modifier_hoodwink_acorn_shot_bh_slow:GetModifierAttackSpeedBonus_Constant()
	return self.attackslow
end

hoodwink_acorn_shot_bh_dummy = class({})
LinkLuaModifier("hoodwink_acorn_shot_bh_dummy", "heroes/hero_hoodwink/hoodwink_acorn_shot_bh", LUA_MODIFIER_MOTION_NONE)

function hoodwink_acorn_shot_bh_dummy:GetEffectName()
	return "particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_tree.vpcf"
end


modifier_hoodwink_acorn_shot_charges = class({})
LinkLuaModifier("modifier_hoodwink_acorn_shot_charges", "heroes/hero_hoodwink/hoodwink_acorn_shot_bh", LUA_MODIFIER_MOTION_NONE )
if IsServer() then
    function modifier_hoodwink_acorn_shot_charges:Update(bResetTimer)
		self:RefreshModifierData()
		if self:GetStackCount() >= self.kv.max_count then
			self:SetDuration(-1, true)
			if self:GetStackCount() > self.kv.max_count then self:SetStackCount( self.kv.max_count) end
		elseif bResetTimer then
			local duration = self.kv.replenish_time
            self:SetDuration(duration, true)
            self:StartIntervalThink(duration)
		end

        if self:GetStackCount() == 0 and not self:IsHidden() then
            self:GetAbility():StartCooldown(self:GetRemainingTime())
		elseif self:GetStackCount() > 0 and not self:GetAbility():IsCooldownReady() then
			self:GetAbility():EndCooldown()
        end
    end

    function modifier_hoodwink_acorn_shot_charges:OnCreated()
		kv = {
			max_count = TernaryOperator( self:GetTalentSpecialValueFor("scepter_ability_charges"), self:GetCaster():HasScepter(), self:GetTalentSpecialValueFor("ability_charges") ),
			replenish_time = TernaryOperator( self:GetTalentSpecialValueFor("scepter_charge_restore_time"), self:GetCaster():HasScepter(), self:GetTalentSpecialValueFor("charge_restore_time") )
		}
        self:SetStackCount(kv.start_count or kv.max_count)
        self.kv = kv

        if kv.start_count and kv.start_count ~= kv.max_count then
            self:Update()
        end
        self:StartIntervalThink(0.25)
    end
	
	function modifier_hoodwink_acorn_shot_charges:OnRefresh()
		self:RefreshModifierData()
        if self:GetStackCount() ~= kv.max_count then
            self:Update()
        end
    end
	
    function modifier_hoodwink_acorn_shot_charges:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }

        return funcs
    end

    function modifier_hoodwink_acorn_shot_charges:OnAbilityFullyCast(params)
        if params.unit == self:GetParent() then
			self:RefreshModifierData()
			
            local ability = params.ability
            if ability == self:GetAbility() and not self:IsHidden() then
				if self:GetStackCount() == self.kv.max_count then
					local duration = self.kv.replenish_time
					self:SetDuration(duration, true)
					self:StartIntervalThink(duration)
				end
                self:DecrementStackCount()
				ability:EndCooldown()
                self:Update()
			elseif string.find( params.ability:GetName(), "orb_of_renewal" ) and self:GetStackCount() < self.kv.max_count then
                self:IncrementStackCount()
                self:Update()
            end
        end

        return 0
    end

    function modifier_hoodwink_acorn_shot_charges:OnIntervalThink()
        local stacks = self:GetStackCount()
		local caster = self:GetCaster()
		local octarine = caster:GetCooldownReduction()
		
		self:RefreshModifierData()
		
        if stacks < self.kv.max_count then
            self:IncrementStackCount()
			self:Update(true)
        end
    end
	
	function modifier_hoodwink_acorn_shot_charges:RefreshModifierData()
		self.kv.replenish_time = TernaryOperator( self:GetTalentSpecialValueFor("scepter_charge_restore_time"), self:GetCaster():HasScepter(), self:GetTalentSpecialValueFor("charge_restore_time") )
		self.kv.max_count = TernaryOperator( self:GetTalentSpecialValueFor("scepter_ability_charges"), self:GetCaster():HasScepter(), self:GetTalentSpecialValueFor("ability_charges") )
	end
end

function modifier_hoodwink_acorn_shot_charges:DestroyOnExpire()
    return false
end

function modifier_hoodwink_acorn_shot_charges:IsPurgable()
    return false
end

function modifier_hoodwink_acorn_shot_charges:RemoveOnDeath()
    return false
end

-- function modifier_hoodwink_acorn_shot_charges:IsHidden()
	-- if self:GetCaster():HasTalent("special_bonus_unique_hoodwink_acorn_shot_1") then
    	-- return false
    -- else
    	-- return true
    -- end
-- end
