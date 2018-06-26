arc_warden_echo_ward = class({})
LinkLuaModifier("modifier_arc_warden_echo_ward", "heroes/hero_arc_warden/arc_warden_echo_ward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arc_warden_echo_ward_clone", "heroes/hero_arc_warden/arc_warden_echo_ward", LUA_MODIFIER_MOTION_NONE)

function arc_warden_echo_ward:GetIntrinsicModifierName()
	return "modifier_arc_warden_echo_ward"
end

modifier_arc_warden_echo_ward = class({})
function modifier_arc_warden_echo_ward:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
	return funcs
end

function modifier_arc_warden_echo_ward:OnAbilityFullyCast(params)
	if IsServer() and self:GetAbility():IsCooldownReady() then
		local caster = self:GetCaster()
		if params.unit == caster then
			local tick_rate = self:GetTalentSpecialValueFor("delay")
			local ability = params.ability
			local currentCasts = 0
			local maxCasts = 1

			local cursorPos = ability:GetCursorPosition()

			--Flux------------------------------------------------
			------------------------------------------------------
			if ability == caster:FindAbilityByName("arc_warden_flux_bh") then
				Timers:CreateTimer(tick_rate, function()
					if currentCasts < maxCasts then
						local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), ability:GetTrueCastRange()+caster:GetModelRadius(), {})
						for _,enemy in pairs(enemies) do
							caster:SetCursorCastTarget(enemy)
							ability:Flux()
							break
						end
						currentCasts = currentCasts + 1
						self:GetAbility():SetCooldown()
						return tick_rate
					else
						return nil
					end
				end)

			--Magnetic Field--------------------------------------
			------------------------------------------------------
			elseif ability == caster:FindAbilityByName("arc_warden_magnetic_field_bh") then
				Timers:CreateTimer(tick_rate, function()
					if currentCasts < maxCasts then
						ability:Field(caster:GetAbsOrigin())
						currentCasts = currentCasts + 1
						self:GetAbility():SetCooldown()
						return tick_rate
					else
						return nil
					end
				end)

			--Spark Wraith----------------------------------------
			------------------------------------------------------
			elseif ability == caster:FindAbilityByName("arc_warden_spark_wrath_bh") then
				Timers:CreateTimer(tick_rate, function()
					if currentCasts < maxCasts then
						ability:Spark(cursorPos + ActualRandomVector(500, 250))
						currentCasts = currentCasts + 1
						self:GetAbility():SetCooldown()
						return tick_rate
					else
						return nil
					end
				end)

			end
		end
	end
end

function modifier_arc_warden_echo_ward:IsHidden()
	return true
end

modifier_arc_warden_echo_ward_clone = class({})

function modifier_arc_warden_echo_ward_clone:CheckState()
	return {[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_UNTARGETABLE] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_NO_TEAM_SELECT] = true,
			[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
			[MODIFIER_STATE_DISARMED] = true}
end