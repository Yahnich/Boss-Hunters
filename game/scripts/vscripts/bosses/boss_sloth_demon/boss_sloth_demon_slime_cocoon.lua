boss_sloth_demon_slime_cocoon = class({})

function boss_sloth_demon_slime_cocoon:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetSpecialValueFor("max_heal") / self:GetSpecialValueFor("heal_per_second")
	caster:AddNewModifier( caster, self, "modifier_boss_sloth_demon_slime_cocoon", {duration = duration})
end

modifier_boss_sloth_demon_slime_cocoon = class({})
LinkLuaModifier( "modifier_boss_sloth_demon_slime_cocoon", "bosses/boss_sloth_demon/boss_sloth_demon_slime_cocoon", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_sloth_demon_slime_cocoon:OnCreated()
	self.heal = self:GetSpecialValueFor("heal_per_second")
	if IsServer() then
		self.attacks = self:GetSpecialValueFor("attacks_per_hero") * HeroList:GetActiveHeroCount()
		self:SetStackCount( self.attacks )
	end
end

function modifier_boss_sloth_demon_slime_cocoon:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end

function modifier_boss_sloth_demon_slime_cocoon:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end

function modifier_boss_sloth_demon_slime_cocoon:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_boss_sloth_demon_slime_cocoon:OnAttackLanded(params)
	if params.target == self:GetParent() then
		self.attacks = self.attacks - 1
		self:SetStackCount( self.attacks )
		if self.attacks <= 0 then
			self:Destroy()
		end
	end
end

function modifier_boss_sloth_demon_slime_cocoon:GetModifierHealthRegenPercentage()
	return self.heal
end

function modifier_boss_sloth_demon_slime_cocoon:GetEffectName()
	return "particles/econ/items/winter_wyvern/winter_wyvern_ti7/wyvern_cold_embrace_ti7buff.vpcf"
end