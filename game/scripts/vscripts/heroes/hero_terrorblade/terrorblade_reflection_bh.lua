terrorblade_reflection_bh = class({})

function terrorblade_reflection_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function terrorblade_reflection_bh:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local radius = self:GetTalentSpecialValueFor("radius")
	local outgoing = self:GetTalentSpecialValueFor("illusion_outgoing_damage")
	local illusions = self:GetTalentSpecialValueFor("illusion_count")
	local duration = self:GetTalentSpecialValueFor("duration")
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
		enemy:AddNewModifier( caster, self, "modifier_terrorblade_reflection_bh_slow", {duration = duration})
	end
	local heroes = HeroList:GetRealHeroes()
	local maxHeroes = #heroes
	local i = 1
	Timers:CreateTimer(function()
		local hero = heroes[i]
		if hero then
			self:CreateReflection( heroes[i], position + ActualRandomVector( radius, 125 ), duration, outgoing, caster )
			i = i + 1
			if i <= maxHeroes then
				return 0.06
			end
		end
	end)
end

function terrorblade_reflection_bh:CreateReflection( hero, position, duration, outgoing, caster)
	local callback = (function(illusion)
		illusion:AddNewModifier(caster, self, "modifier_terrorblade_reflection_bh_illusion", {})
		illusion:MoveToPositionAggressive( position )
		if not illusion:HasAbility("terrorblade_zeal") then illusion:AddAbility("terrorblade_zeal") end
	end)
	
	local illusions = hero:ConjureImage( {outgoing_damage = outgoing, -999, position = position, illusion_modifier = "modifier_terrorblade_conjureimage", scramble = false, ability = self}, duration, caster )
	illusions[1]:AddNewModifier(caster, self, "modifier_terrorblade_reflection_bh_illusion", {})
	illusions[1]:MoveToPositionAggressive( position )
	if not illusions[1]:HasAbility("terrorblade_zeal") then illusions[1]:AddAbility("terrorblade_zeal") end
	return illusions[1]
end

modifier_terrorblade_reflection_bh_illusion = class({})
LinkLuaModifier( "modifier_terrorblade_reflection_bh_illusion", "heroes/hero_terrorblade/terrorblade_reflection_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_terrorblade_reflection_bh_illusion:CheckState()
	return {[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
			[MODIFIER_STATE_UNTARGETABLE] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,}
end

function modifier_terrorblade_reflection_bh_illusion:IsHidden()
	return true
end

modifier_terrorblade_reflection_bh_slow = class({})
LinkLuaModifier( "modifier_terrorblade_reflection_bh_slow", "heroes/hero_terrorblade/terrorblade_reflection_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_terrorblade_reflection_bh_slow:OnCreated()
	self.slow = self:GetTalentSpecialValueFor("slow")
end

function modifier_terrorblade_reflection_bh_slow:OnRefresh()
	self.slow = self:GetTalentSpecialValueFor("slow")
end

function modifier_terrorblade_reflection_bh_slow:CheckState()
	if self:GetCaster():HasTalent("special_bonus_unique_terrorblade_reflection_2") then
		return {[MODIFIER_STATE_ROOTED] = true,
				[MODIFIER_STATE_INVISIBLE] = false}
	end
end

function modifier_terrorblade_reflection_bh_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_terrorblade_reflection_bh_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end