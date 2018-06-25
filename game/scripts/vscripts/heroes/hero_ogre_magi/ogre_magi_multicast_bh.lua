ogre_magi_multicast_bh = class({})
LinkLuaModifier("modifier_ogre_magi_multicast_bh", "heroes/hero_ogre_magi/ogre_magi_multicast_bh", LUA_MODIFIER_MOTION_NONE)

function ogre_magi_multicast_bh:GetIntrinsicModifierName()
	return "modifier_ogre_magi_multicast_bh"
end

modifier_ogre_magi_multicast_bh = class({})
function modifier_ogre_magi_multicast_bh:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
	return funcs
end

function modifier_ogre_magi_multicast_bh:OnAbilityFullyCast(params)
	if IsServer() then
		local caster = self:GetCaster()
		if params.unit == caster then
			local two_times = self:GetSpecialValueFor("multicast_2_times")
			local three_times = self:GetSpecialValueFor("multicast_3_times")
			local four_times = self:GetSpecialValueFor("multicast_4_times")
			local multiCast = 1
			local currentCasts = 1

			local tick_rate = 0.25

			local bonusCastRange = 0

			local ability = params.ability
			if RollPercentage(two_times) then
				multiCast = 2
			elseif RollPercentage(three_times) then
				multiCast = 3
			elseif RollPercentage(four_times) then
				multiCast = 4
			end
			--print(multiCast)
			if multiCast > 1 then
				local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf", PATTACH_POINT_FOLLOW, caster)
							ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
							ParticleManager:SetParticleControl(nfx, 1, Vector(multiCast, 1, 1))
							ParticleManager:ReleaseParticleIndex(nfx)
			end

			--FireBlast-------------------------------------------
			------------------------------------------------------
			if ability == caster:FindAbilityByName("ogre_magi_fireblast_bh") then
				if multiCast > 1 then
					ability.newCoolDown = math.random(0, self:GetSpecialValueFor("fireblast_cooldown"))
					bonusCastRange = math.random(0, self:GetSpecialValueFor("fireblast_range"))
					EmitSoundOn("Hero_OgreMagi.Fireblast.x" .. (multiCast - 1), ability:GetCursorTarget()) 
				end

				Timers:CreateTimer(tick_rate, function()
					if currentCasts < multiCast then
						local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), ability:GetTrueCastRange()+caster:GetModelRadius()+bonusCastRange, {})
						for _,enemy in pairs(enemies) do
							caster:SetCursorCastTarget(enemy)
							ability:Fireblast()
							break
						end
						currentCasts = currentCasts + 1
						return tick_rate
					else
						return nil
					end
				end)

			--Ignite----------------------------------------------
			------------------------------------------------------
			elseif ability == caster:FindAbilityByName("ogre_magi_ignite_bh") then
				if multiCast > 1 then
					bonusCastRange = math.random(0, 450)
				end

				Timers:CreateTimer(tick_rate, function()
					if currentCasts < multiCast then
						local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), ability:GetTrueCastRange()+caster:GetModelRadius()+bonusCastRange, {})
						for _,enemy in pairs(enemies) do
							caster:SetCursorCastTarget(enemy)
							ability:Ignite()
							break
						end
						currentCasts = currentCasts + 1
						return tick_rate
					else
						return nil
					end
				end)

			--BloodLust-------------------------------------------
			------------------------------------------------------
			elseif ability == caster:FindAbilityByName("ogre_magi_bloodlust_bh") then
				if multiCast > 1 then
					ability.newCoolDown = math.random(0, self:GetSpecialValueFor("bloodlust_cooldown"))
				end

				Timers:CreateTimer(tick_rate, function()
					if currentCasts < multiCast then
						local friends = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), ability:GetTrueCastRange()+caster:GetModelRadius(), {})
						for _,friend in pairs(friends) do
							caster:SetCursorCastTarget(friend)
							ability:Bloodlust()
							break
						end
						currentCasts = currentCasts + 1
						return tick_rate
					else
						return nil
					end
				end)

			--Unrefined Fireblast---------------------------------
			------------------------------------------------------
			elseif ability == caster:FindAbilityByName("ogre_magi_fireblast_bh") then
				if multiCast > 1 then
					ability.newCoolDown = math.random(0, self:GetSpecialValueFor("unrefined_fireblast_cooldown"))
					EmitSoundOn("Hero_OgreMagi.Fireblast.x" .. (multiCast - 1), ability:GetCursorTarget()) 
				end

				Timers:CreateTimer(tick_rate, function()
					if currentCasts < multiCast then
						ability:Fireblast()
						currentCasts = currentCasts + 1
						return tick_rate
					else
						return nil
					end
				end)

			--Immolate--------------------------------------------
			------------------------------------------------------
			elseif ability == caster:FindAbilityByName("ogre_magi_immolate") then
				Timers:CreateTimer(tick_rate, function()
					if currentCasts < multiCast then
						local friends = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), ability:GetTrueCastRange()+caster:GetModelRadius(), {})
						for _,friend in pairs(friends) do
							caster:SetCursorCastTarget(friend)
							ability:Immolate()
							break
						end
						currentCasts = currentCasts + 1
						return tick_rate
					else
						return nil
					end
				end)

			end
		end
	end
end

function modifier_ogre_magi_multicast_bh:IsHidden()
	return true
end