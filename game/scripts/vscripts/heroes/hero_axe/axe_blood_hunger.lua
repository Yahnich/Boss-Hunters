axe_blood_hunger = class({})

function axe_blood_hunger:IsStealable()
	return true
end

function axe_blood_hunger:IsHiddenWhenStolen()
	return false
end

function axe_blood_hunger:GetIntrinsicModifierName()
	return "modifier_blood_hunger_handler"
end

function axe_blood_hunger:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	EmitSoundOn("Hero_Axe.Battle_Hunger", target)
	target:AddNewModifier(caster, self, "modifier_blood_hunger", {Duration = self:GetTalentSpecialValueFor("duration")})

	-- if caster:HasTalent("special_bonus_unique_axe_blood_hunger_2") then
		-- local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), {})
		-- for _,ally in pairs(allies) do
			-- if ally ~= caster then
				-- EmitSoundOn("Hero_Axe.Battle_Hunger", ally)
				-- ally:AddNewModifier(caster, self, "modifier_blood_hunger", {Duration = self:GetTalentSpecialValueFor("duration")})
				-- caster:AddNewModifier(caster, self, "modifier_blood_hunger_strength", {Duration = self:GetTalentSpecialValueFor("duration")}):AddIndependentStack()
			-- end
			-- break
		-- end
	-- end
end

modifier_blood_hunger_handler = class({})
LinkLuaModifier( "modifier_blood_hunger_handler", "heroes/hero_axe/axe_blood_hunger.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_blood_hunger_handler:OnCreated()
	self:OnRefresh()
	
	if IsServer() then 
		self:StartIntervalThink(0.25)
	end
end

function modifier_blood_hunger_handler:OnRefresh()
	local multiplier = self:GetTalentSpecialValueFor("minion_multiplier")
	self.movespeed = self:GetTalentSpecialValueFor("move_slow") * multiplier
	self.armor = self:GetTalentSpecialValueFor("armor") * multiplier
	
	self.talent1Val = self:GetCaster():FindTalentValue("special_bonus_unique_axe_blood_hunger_1") * multiplier
	self.talent2Val = self:GetCaster():FindTalentValue("special_bonus_unique_axe_blood_hunger_3") * multiplier
end

function modifier_blood_hunger_handler:OnIntervalThink()
	local ability = self:GetAbility()
	if ability:IsFullyCastable() and ability:GetAutoCastState( ) then
		local caster = self:GetCaster()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), ability:GetTrueCastRange() ) ) do
			if not enemy:HasModifier("modifier_blood_hunger") then
				ability:CastSpell(enemy)
			end
		end
	end
end

function modifier_blood_hunger_handler:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
	}
	return funcs
end

function modifier_blood_hunger_handler:GetModifierMoveSpeedBonus_Percentage()
	return math.max( 0, self.movespeed * self:GetStackCount() )
end

function modifier_blood_hunger_handler:GetModifierPhysicalArmorBonus()
	return math.max( 0, self.armor * self:GetStackCount() )
end

function modifier_blood_hunger_handler:GetModifierAttackSpeedBonus_Constant()
	return math.max( 0, self.talent1Val * self:GetStackCount() )
end

function modifier_blood_hunger_handler:GetModifierHPRegenAmplify_Percentage()
	return math.max( 0, self.talent2Val * self:GetStackCount() )
end

function modifier_blood_hunger_handler:GetModifierLifestealRegenAmplify_Percentage()
	return math.max( 0, self.talent2Val * self:GetStackCount() )
end

function modifier_blood_hunger_handler:GetModifierHealAmplify_Percentage()
	return math.max( 0, self.talent2Val * self:GetStackCount() )
end

function modifier_blood_hunger_handler:IsHidden()
	return self:GetStackCount() <= 0
end

modifier_blood_hunger = class({})
LinkLuaModifier( "modifier_blood_hunger", "heroes/hero_axe/axe_blood_hunger.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_blood_hunger:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:StartIntervalThink(1)
		self.stacks = 1
		if not self:GetParent():IsMinion() then
			self.stacks = math.floor( self.stacks / self:GetTalentSpecialValueFor("minion_multiplier") + 0.5 )
		end
		local modifier = self:GetCaster():FindModifierByName("modifier_blood_hunger_handler")
		modifier:SetStackCount( math.max( modifier:GetStackCount() + self.stacks, 0 ) )
		modifier:ForceRefresh()
	end
end

function modifier_blood_hunger:OnRefresh()
	self.movespeed = -self:GetTalentSpecialValueFor("move_slow")
	self.armor = -self:GetTalentSpecialValueFor("armor")
	self.chance = self:GetTalentSpecialValueFor("chance")
	self.damage = self:GetTalentSpecialValueFor("damage")
	self.duration = self:GetTalentSpecialValueFor("duration")
	
	self.talent1Val = -self:GetCaster():FindTalentValue("special_bonus_unique_axe_blood_hunger_1")
	self.talent2Val = -self:GetCaster():FindTalentValue("special_bonus_unique_axe_blood_hunger_3")
end

function modifier_blood_hunger:OnDestroy()
	if IsServer() then
		local modifier = self:GetCaster():FindModifierByName("modifier_blood_hunger_handler")
		modifier:SetStackCount( math.max( 0, modifier:GetStackCount() - self.stacks ) )
		modifier:ForceRefresh()
	end
end

function modifier_blood_hunger:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	ability:DealDamage(caster, parent, self.damage, nil, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
	if parent:IsTaunted() then
		if self:RollPRNG(self.chance) then
			local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), ability:GetTrueCastRange(), {})
			for _,enemy in pairs(enemies) do
				if enemy ~= parent and not enemy:HasModifier("modifier_blood_hunger") then
					EmitSoundOn("Hero_Axe.Battle_Hunger", enemy)
					if not enemy:TriggerSpellAbsorb(self:GetAbility()) then
						enemy:AddNewModifier(caster, ability, "modifier_blood_hunger", {Duration = self.duration})
					end
					break
				end
			end
		end
	end
end

function modifier_blood_hunger:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
	}
	return funcs
end

function modifier_blood_hunger:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_blood_hunger:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_blood_hunger:GetModifierAttackSpeedBonus_Constant()
	return self.talent1Val
end

function modifier_blood_hunger:GetModifierHPRegenAmplify_Percentage()
	return self.talent2Val
end

function modifier_blood_hunger:GetModifierLifestealRegenAmplify_Percentage()
	return self.talent2Val
end

function modifier_blood_hunger:GetModifierHealAmplify_Percentage()
	return self.talent2Val
end

function modifier_blood_hunger:GetEffectName()
	return "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf"
end

function modifier_blood_hunger:GetStatusEffectName()
	return "particles/status_fx/status_effect_battle_hunger.vpcf"
end

function modifier_blood_hunger:StatusEffectPriority()
	return 12
end

function modifier_blood_hunger:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_blood_hunger:IsDebuff()
	return true
end