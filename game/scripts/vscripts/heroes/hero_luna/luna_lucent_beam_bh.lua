luna_lucent_beam_bh = class({})

function luna_lucent_beam_bh:GetBehavior()
	if caster:HasTalent("special_bonus_unique_luna_lucent_beam_1") then
		return DOTA_ABILITY_BEHAVIOR_POINT
	else	
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
end

function luna_lucent_beam_bh:OnSpellStart()
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_luna_lucent_beam_1") then
		local target = self:GetCursorPosition()
	else	
		local target = self:GetCursorTarget()
		self:LucentBeam(target)
		
		local gifts = caster:FindAbilityByName("luna_lunar_blessing_bh")
		if gifts then
			local beams = gifts:GetTalentSpecialValueFor("bonus_lucent_targets")
			for _, enemy in ipairs() do
				if beams > 0 then
					enemy:LucentBeam(enemy)
					beams = beams - 1
				else
					break
				end
			end
		end
		caster:EmitSound("")
	end
end

function luna_lucent_beam_bh:LucentBeam(target, stun)
	local caster = self:GetCaster()
	local bStun = stun or true
	
	local damage = TernaryOperator( self:GetTalentSpecialValueFor("night_beam_damage"), not GameRules:IsDaytime(), self:GetTalentSpecialValueFor("beam_damage") )
	self:DealDamage( caster, target, damage )
	
	if bStun then
		local sDur = self:GetTalentSpecialValueFor("stun_duration")
		self:Stun( target, sDur )
	end
	
	ParticleManager:FireParticle("", PATTACH_POINT_FOLLOW, target)
	target:EmitSound("")
end