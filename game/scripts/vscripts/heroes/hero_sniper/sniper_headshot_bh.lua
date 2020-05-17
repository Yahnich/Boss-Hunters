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
end

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
		if caster == self:GetCaster() and caster:RollPRNG(self.chance ) then
			local ability = self:GetAbility()
			if self.talent1 then
				for _, enemy in ipairs( caster:FindEnemyUnitsInCone(CalculateDirection(target, caster), target:GetAbsOrigin(), self.talent1Radius/2, self.talent1Radius ) ) do
					ability:DealDamage( caster, enemy, self.talent1Dmg )
				end
			end

			target:AddNewModifier(caster, self:GetAbility(), "modifier_sniper_headshot_bh_slow", {Duration = self.duration})
			ability:DealDamage(caster, target, self.damage)

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
		
		MODIFIER_PROPERTY_MISS_PERCENTAGE
	}
	return funcs
end

function modifier_sniper_headshot_bh_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetTalentSpecialValueFor("movespeed_slow")
end

function modifier_sniper_headshot_bh_slow:GetModifierAttackSpeedBonus()
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