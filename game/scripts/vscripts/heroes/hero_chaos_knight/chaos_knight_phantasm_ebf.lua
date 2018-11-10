chaos_knight_phantasm_ebf = class({})

function chaos_knight_phantasm_ebf:IsStealable()
	return true
end

function chaos_knight_phantasm_ebf:IsHiddenWhenStolen()
	return false
end

function chaos_knight_phantasm_ebf:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_4
end

function chaos_knight_phantasm_ebf:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
end

function chaos_knight_phantasm_ebf:GetCooldown(iLvl)
	if self:GetCaster():HasScepter() then
		return self:GetTalentSpecialValueFor("cooldown_scepter")
	else
		return self.BaseClass.GetCooldown(self, iLvl)
	end
end

if IsServer() then
	function chaos_knight_phantasm_ebf:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget() or caster
		
		local illusions = self:GetTalentSpecialValueFor("images_count")
		local chance = self:GetTalentSpecialValueFor("extra_phantasm_chance_pct_tooltip")
		local bonusIllusion = RollPercentage( chance )
		if bonusIllusion then
			illusions = illusions + 1
			if caster:HasTalent("special_bonus_unique_chaos_knight_phantasm_2") then
				while (bonusIllusion) do
					chance = chance - 5
					bonusIllusion = RollPercentage(chance)
					illusions = illusions + 1
				end
			end
			target:EmitSound("Hero_ChaosKnight.Phantasm.Plus")
		end
		
		local firstDir = -target:GetForwardVector()
		local duration = self:GetTalentSpecialValueFor("illusion_duration")
		local outDmg = self:GetTalentSpecialValueFor("outgoing_damage")
		local inDmg = self:GetTalentSpecialValueFor("incoming_damage")
		
		local delay = self:GetTalentSpecialValueFor("invuln_duration")
		target:Dispel(caster)
		
		local cFX = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_phantasm.vpcf", PATTACH_POINT_FOLLOW, target)
		target:EmitSound("Hero_ChaosKnight.Phantasm")
		
		target:AddNewModifier(caster, self, "modifier_invulnerable", {duration = delay})
		Timers:CreateTimer(delay, function()
			ParticleManager:ClearParticle(cFX)
			if caster:HasTalent("special_bonus_unique_chaos_knight_phantasm_1") then
				local cBolt = caster:FindAbilityByName("chaos_knight_chaos_bolt_ebf")
				local cStrike = caster:FindAbilityByName("chaos_knight_chaos_strike_ebf")
				if cStrike then
					caster:AddNewModifier( caster, cStrike, "modifier_chaos_knight_chaos_strike_actCrit", {} )
				end
				if cBolt then
					local enemy = caster:FindRandomEnemyInRadius( caster:GetAbsOrigin(), cBolt:GetTrueCastRange() )
					if enemy then 
						cBolt:ThrowChaosBolt(enemy, target)
					end
				end
			end
			local callback = ( function( illusion, self, caster, ability )
				if caster:HasTalent("special_bonus_unique_chaos_knight_phantasm_1") then
					local cBolt = caster:FindAbilityByName("chaos_knight_chaos_bolt_ebf")
					local cStrike = caster:FindAbilityByName("chaos_knight_chaos_strike_ebf")
					if cStrike then
						illusion:AddNewModifier( caster, cStrike, "modifier_chaos_knight_chaos_strike_actCrit", {} )
					end
					if cBolt then
						local enemy = caster:FindRandomEnemyInRadius( illusion:GetAbsOrigin(), cBolt:GetTrueCastRange() )
						if enemy then 
							cBolt:ThrowChaosBolt(enemy, illusion)
						end
					end
				end
			end)
			for i = 1, illusions do
				local illusion = target:ConjureImage( position, duration, outDmg, inDmg, nil, self, true, caster, callback )
			end
		end)
	end
end

