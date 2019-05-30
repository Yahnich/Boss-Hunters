mars_bulwark_lua = class({})
LinkLuaModifier( "modifier_mars_bulwark_lua", "heroes/hero_mars/mars_bulwark_lua.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mars_bulwark_lua_talent", "heroes/hero_mars/mars_bulwark_lua.lua" ,LUA_MODIFIER_MOTION_NONE )

function mars_bulwark_lua:IsStealable()
	return false
end

function mars_bulwark_lua:IsHiddenWhenStolen()
	return false
end

function mars_bulwark_lua:GetIntrinsicModifierName()
	return "modifier_mars_bulwark_lua"
end

modifier_mars_bulwark_lua = class({})

function modifier_mars_bulwark_lua:OnCreated()
	if IsServer() then
		self.physical_damage_reduction = self:GetSpecialValueFor("physical_damage_reduction")
		self.forward_angle = self:GetSpecialValueFor("forward_angle")
		self.physical_damage_reduction_side = self:GetSpecialValueFor("physical_damage_reduction_side")
		self.side_angle = self:GetSpecialValueFor("side_angle")
	end
end

function modifier_mars_bulwark_lua:IsPurgable()
	return false
end

function modifier_mars_bulwark_lua:IsPurgeException()
	return false
end

function modifier_mars_bulwark_lua:IsDebuff()
	return false
end

function modifier_mars_bulwark_lua:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED,
			 MODIFIER_EVENT_ON_ABILITY_EXECUTED }
end

function modifier_mars_bulwark_lua:OnAttackLanded(params)
	if IsServer() then
		local caster = self:GetCaster()
		local target = params.target
		local attacker = params.attacker
		local damage = params.damage

		if target == caster and attacker ~= caster then
			-- The y value of the angles vector contains the angle we actually want: where targets are directionally facing in the world.
			local victim_angle = target:GetAnglesAsVector().y
			local origin_difference = attacker:GetAbsOrigin() - target:GetAbsOrigin()
			-- Get the radian of the origin difference between the attacker and Bristleback. We use this to figure out at what angle the attacker is at relative to Bristleback.
			local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
			-- Convert the radian to degrees.
			origin_difference_radian = origin_difference_radian * 180
			local attacker_angle = origin_difference_radian / math.pi
			-- See the opening block comment for why I do this. Basically it's to turn negative angles into positive ones and make the math simpler.
			attacker_angle = attacker_angle + 180
			-- Finally, get the angle at which Bristleback is facing the attacker.
			local result_angle = attacker_angle - victim_angle
			result_angle = math.abs(result_angle)

			-- Check for the side angle first. If the attack doesn't pass this check, we don't have to do back angle calculations.
			if result_angle >= (180 - (self.side_angle / 2)) and result_angle <= (180 + (self.side_angle / 2)) then 
				-- Check for back angle. If this check doesn't pass, then do side angle "damage reduction".
				if result_angle >= (180 - (self.forward_angle / 2)) and result_angle <= (180 + (self.forward_angle / 2)) then 
					-- This is the actual "damage reduction".
					local damageBlock = damage - self.physical_damage_reduction
					if damageBlock < 0 then
						damageBlock = damage
					end

					target:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)

					EmitSoundOn("Hero_Mars.Shield.Block", caster)

					local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_shield_of_mars.vpcf", PATTACH_POINT_FOLLOW, target)
								ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
								ParticleManager:ReleaseParticleIndex(nfx)

					target:SetHealth( damageBlock + target:GetHealth())
					SendOverheadEventMessage(target:GetPlayerOwner(), OVERHEAD_ALERT_BLOCK, target, damageBlock, target:GetPlayerOwner())

					if caster:HasTalent("special_bonus_unique_mars_bulwark_lua_1") and CalculateDistance(target, caster) <= caster:GetAttackRange()
						and RollPercentage(caster:FindTalentValue("special_bonus_unique_mars_bulwark_lua_1", "chance")) then
						local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_arena_of_blood_spear.vpcf", PATTACH_POINT, caster)
									ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
									ParticleManager:SetParticleControlForward(nfx, 0, CalculateDirection(attacker, caster))
									ParticleManager:ReleaseParticleIndex(nfx)

						local talentDamage = -caster:FindTalentValue("special_bonus_unique_mars_bulwark_lua_1", "damage")
						caster:PerformAbilityAttack(attacker, true, self:GetAbility(), talentDamage, true, false)
					end
				else
					-- This is the actual "damage reduction".
					local damageBlock = damage - self.physical_damage_reduction_side
					if damageBlock < 0 then
						damageBlock = damage
					end
					
					EmitSoundOn("Hero_Mars.Shield.BlockSmall", caster)

					local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_shield_of_mars_small.vpcf", PATTACH_POINT_FOLLOW, target)
								ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
								ParticleManager:ReleaseParticleIndex(nfx)
								
					target:SetHealth( damageBlock + target:GetHealth())
					SendOverheadEventMessage(target:GetPlayerOwner(), OVERHEAD_ALERT_BLOCK, target, damageBlock, target:GetPlayerOwner())
				end
			end
		end
	end
end

function modifier_mars_bulwark_lua:OnAbilityExecuted(params)
	if IsServer() then
		local caster = self:GetCaster()
		local unit = params.unit
		local ability = params.ability
		if caster:HasTalent("special_bonus_unique_mars_bulwark_lua_2") and unit == caster then
			local duration = caster:FindTalentValue("special_bonus_unique_mars_bulwark_lua_2", "duration")
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_mars_bulwark_lua_talent", {Duration = duration})
		end
	end
end

modifier_mars_bulwark_lua_talent = class({})

function modifier_mars_bulwark_lua_talent:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		self.physical_damage_reduction = caster:FindTalentValue("special_bonus_unique_mars_bulwark_lua_2", "block")
		self.forward_angle = self:GetSpecialValueFor("forward_angle")
		self.physical_damage_reduction_side = caster:FindTalentValue("special_bonus_unique_mars_bulwark_lua_2", "block")
		self.side_angle = self:GetSpecialValueFor("side_angle")
	end
end

function modifier_mars_bulwark_lua_talent:IsPurgable()
	return true
end

function modifier_mars_bulwark_lua_talent:IsPurgeException()
	return false
end

function modifier_mars_bulwark_lua_talent:IsDebuff()
	return false
end

function modifier_mars_bulwark_lua_talent:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_mars_bulwark_lua_talent:OnAttackLanded(params)
	if IsServer() then
		local caster = self:GetCaster()
		local target = params.target
		local attacker = params.attacker
		local damage = params.damage

		if target == caster and attacker ~= caster then
			-- The y value of the angles vector contains the angle we actually want: where targets are directionally facing in the world.
			local victim_angle = target:GetAnglesAsVector().y
			local origin_difference = attacker:GetAbsOrigin() - target:GetAbsOrigin()
			-- Get the radian of the origin difference between the attacker and Bristleback. We use this to figure out at what angle the attacker is at relative to Bristleback.
			local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
			-- Convert the radian to degrees.
			origin_difference_radian = origin_difference_radian * 180
			local attacker_angle = origin_difference_radian / math.pi
			-- See the opening block comment for why I do this. Basically it's to turn negative angles into positive ones and make the math simpler.
			attacker_angle = attacker_angle + 180
			-- Finally, get the angle at which Bristleback is facing the attacker.
			local result_angle = attacker_angle - victim_angle
			result_angle = math.abs(result_angle)

			-- Check for the side angle first. If the attack doesn't pass this check, we don't have to do back angle calculations.
			if result_angle >= (180 - (self.side_angle / 2)) and result_angle <= (180 + (self.side_angle / 2)) then 
				-- Check for back angle. If this check doesn't pass, then do side angle "damage reduction".
				if result_angle >= (180 - (self.forward_angle / 2)) and result_angle <= (180 + (self.forward_angle / 2)) then 
					-- This is the actual "damage reduction".
					local damageBlock = damage - self.physical_damage_reduction
					if damageBlock < 0 then
						damageBlock = damage
					end

					target:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)

					local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_shield_of_mars.vpcf", PATTACH_POINT_FOLLOW, target)
								ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
								ParticleManager:ReleaseParticleIndex(nfx)

					target:SetHealth( damageBlock + target:GetHealth())
					SendOverheadEventMessage(target:GetPlayerOwner(), OVERHEAD_ALERT_BLOCK, target, damageBlock, target:GetPlayerOwner())

					if caster:HasTalent("special_bonus_unique_mars_bulwark_lua_1") and CalculateDistance(target, caster) <= caster:GetAttackRange()
						and RollPercentage(caster:FindTalentValue("special_bonus_unique_mars_bulwark_lua_1", "chance")) then
						local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_arena_of_blood_spear.vpcf", PATTACH_POINT, caster)
									ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
									ParticleManager:SetParticleControlForward(nfx, 0, CalculateDirection(attacker, caster))
									ParticleManager:ReleaseParticleIndex(nfx)

						local talentDamage = -caster:FindTalentValue("special_bonus_unique_mars_bulwark_lua_1", "damage")
						caster:PerformAbilityAttack(attacker, true, self:GetAbility(), talentDamage, true, false)
					end
				else
					-- This is the actual "damage reduction".
					local damageBlock = damage - self.physical_damage_reduction_side
					if damageBlock < 0 then
						damageBlock = damage
					end
					
					local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_shield_of_mars_small.vpcf", PATTACH_POINT_FOLLOW, target)
								ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
								ParticleManager:ReleaseParticleIndex(nfx)
								
					target:SetHealth( damageBlock + target:GetHealth())
					SendOverheadEventMessage(target:GetPlayerOwner(), OVERHEAD_ALERT_BLOCK, target, damageBlock, target:GetPlayerOwner())
				end
			end
		end
	end
end