sniper_headshot_bh = class({})
LinkLuaModifier( "modifier_sniper_headshot_bh","heroes/hero_sniper/sniper_headshot_bh.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sniper_headshot_bh_slow","heroes/hero_sniper/sniper_headshot_bh.lua",LUA_MODIFIER_MOTION_NONE )

function sniper_headshot_bh:GetIntrinsicModifierName()
	return "modifier_sniper_headshot_bh"
end

modifier_sniper_headshot_bh = class({})
function modifier_sniper_headshot_bh:OnCreated()
	self:OnRefresh()
end

function modifier_sniper_headshot_bh:OnRefresh()
	self.duration = self:GetTalentSpecialValueFor("duration")
	self.chance = self:GetTalentSpecialValueFor("chance")
	self.damage = self:GetTalentSpecialValueFor("damage")
	
	local caster = self:GetCaster()
	self.talent1 = caster:HasTalent("special_bonus_unique_sniper_headshot_bh_1")
	self.talent1Dmg = self.damage * caster:FindTalentValue("special_bonus_unique_sniper_headshot_bh_1", "damage") / 100
	self.talent1Radius = caster:FindTalentValue("special_bonus_unique_sniper_headshot_bh_1", "radius")
	
	self.recordsProc = {}
end

function modifier_sniper_headshot_bh:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_sniper_headshot_bh:OnAttackLanded( params )
	if IsServer() and params.attacker == self:GetParent() and self.recordsProc[params.record] then
		local caster = params.attacker
		local target = params.target
		local ability = self:GetAbility()
		if self.talent1 then
			for _, enemy in ipairs( caster:FindEnemyUnitsInCone(CalculateDirection(target, caster), target:GetAbsOrigin(), self.talent1Radius/2, self.talent1Radius ) ) do
				ability:DealDamage( caster, enemy, self.talent1Dmg )
			end
		end
		for i = 1, self.recordsProc[params.record] do
			EmitSoundOn( "Hero_Sniper.MKG_impact", target )
		end
		target:AddNewModifier(caster, self:GetAbility(), "modifier_sniper_headshot_bh_slow", {Duration = self.duration})
		
		
		self.recordsProc[params.record] = nil
	end
end

function modifier_sniper_headshot_bh:GetModifierPreAttack_BonusDamage(params)
	if IsServer() and params.attacker and params.target then
		local caster = params.attacker
		local target = params.target
		
		local chance = self:GetTalentSpecialValueFor("chance")
		local damage = self.damage
		local duration = self.duration
		local power = 0
		if chance >= 100 then
			power = 1
			chance = chance - 100
			if chance > 0 and caster:RollPRNG( chance ) then
				damage = damage + self.damage
				duration = duration + self.duration
				power = 2
			end
		elseif caster:RollPRNG( chance ) then
			power = 1
		end
		
		if caster == self:GetCaster() and power > 0 then
			self.recordsProc[params.record] = power
			return self.damage

			-- if caster:RollPRNG( self:GetTalentSpecialValueFor("assassinate_chance")) and not caster:HasModifier("modifier_sniper_rapid_fire") then
				-- local assassinate = caster:FindAbilityByName("sniper_assassinate_bh")
				-- if assassinate and assassinate:IsTrained() and assassinate:IsCooldownReady() then
					-- caster:SetCursorCastTarget(target)

					-- caster:CastAbilityImmediately( assassinate, caster:GetPlayerOwnerID() )
					-- local cooldown = assassinate:GetCooldownTimeRemaining() * self:GetTalentSpecialValueFor("assassinate_cooldown")/100
					-- assassinate:EndCooldown()
					-- assassinate:StartCooldown(cooldown)
					-- assassinate:RefundManaCost()
				-- end
			-- end
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
	return "particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf"
end

function modifier_sniper_headshot_bh_slow:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_sniper_headshot_bh_slow:IsDebuff()
	return true
end