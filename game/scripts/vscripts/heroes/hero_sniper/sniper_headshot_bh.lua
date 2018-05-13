sniper_headshot_bh = class({})
LinkLuaModifier( "modifier_sniper_headshot_bh","heroes/hero_sniper/sniper_headshot_bh.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sniper_headshot_bh_slow","heroes/hero_sniper/sniper_headshot_bh.lua",LUA_MODIFIER_MOTION_NONE )

function sniper_headshot_bh:GetIntrinsicModifierName()
	return "modifier_sniper_headshot_bh"
end

modifier_sniper_headshot_bh = class({})
function modifier_sniper_headshot_bh:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_sniper_headshot_bh:OnAttackLanded(params)
	if IsServer() then
		local caster = params.attacker
		local target = params.target
		if caster == self:GetCaster() and caster:RollPRNG(self:GetTalentSpecialValueFor("chance")) then
			--print("true2")
			--ParticleManager:FireParticle("particles/units/heroes/hero_sniper/sniper_headshot_slow_caster.vpcf", PATTACH_POINT, caster, {[1]=caster:GetAbsOrigin()})
			local nfx = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_immortal_cape/sniper_immortal_cape_headshot_slow_caster.vpcf", PATTACH_POINT, caster)
						ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT, "attach_hitloc", caster:GetAbsOrigin(), true)
						ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT, "attach_hitloc", caster:GetAbsOrigin(), true)
						ParticleManager:ReleaseParticleIndex(nfx)

			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf", PATTACH_POINT, caster)
						ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
						--ParticleManager:ReleaseParticleIndex(nfx)

			Timers:CreateTimer(self:GetTalentSpecialValueFor("duration"), function()
				ParticleManager:ClearParticle(nfx)
			end)

			if caster:HasTalent("special_bonus_unique_sniper_headshot_bh_1") then
				target:ApplyKnockBack(caster:GetAbsOrigin(), 0.1, 0.1, caster:FindTalentValue("special_bonus_unique_sniper_headshot_bh_1"), 0, caster, self:GetAbility())
			end

			target:AddNewModifier(caster, self:GetAbility(), "modifier_sniper_headshot_bh_slow", {Duration = self:GetTalentSpecialValueFor("duration")})
			self:GetAbility():DealDamage(caster, target, self:GetTalentSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)

			local assassinate = caster:FindAbilityByName("sniper_assassinate_bh")
			if caster:RollPRNG( self:GetTalentSpecialValueFor("assassinate_chance")) and not caster:HasModifier("modifier_sniper_rapid_fire") then
				if assassinate and assassinate:IsTrained() and assassinate:IsCooldownReady() and assassinate:IsOwnersManaEnough() then
					caster:SetCursorCastTarget(target)

					caster:CastAbilityImmediately( assassinate, caster:GetPlayerOwnerID() )
					local cooldown = assassinate:GetCooldownTimeRemaining() * self:GetTalentSpecialValueFor("assassinate_cooldown")/100
					--print(cooldown)
					assassinate:EndCooldown()
					assassinate:StartCooldown(cooldown)
				end
			end
		end
	end
end

function modifier_sniper_headshot_bh:IsPurgeException()
	return false
end

function modifier_sniper_headshot_bh:IsPurgable()
	return false
end

function modifier_sniper_headshot_bh:IsHidden()
	return true
end

modifier_sniper_headshot_bh_slow = class({})
function modifier_sniper_headshot_bh_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MISS_PERCENTAGE
	}
	return funcs
end

function modifier_sniper_headshot_bh_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetTalentSpecialValueFor("movespeed_slow")
end

function modifier_sniper_headshot_bh_slow:GetModifierAttackSpeedBonus_Constant()
	return self:GetTalentSpecialValueFor("attackspeed_slow")
end

function modifier_sniper_headshot_bh_slow:GetModifierMiss_Percentage()
	return self:GetTalentSpecialValueFor("blind")
end

function modifier_sniper_headshot_bh_slow:GetEffectName()
	return "particles/econ/items/sniper/sniper_immortal_cape/sniper_immortal_cape_headshot_slow_ring.vpcf"
end

function modifier_sniper_headshot_bh_slow:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_sniper_headshot_bh_slow:IsDebuff()
	return true
end