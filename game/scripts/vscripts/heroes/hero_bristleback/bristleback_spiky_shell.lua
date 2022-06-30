bristleback_spiky_shell = class({})

function bristleback_spiky_shell:GetIntrinsicModifierName()
	return "modifier_spiky_shell"
end

modifier_spiky_shell = class({})
LinkLuaModifier( "modifier_spiky_shell", "heroes/hero_bristleback/bristleback_spiky_shell.lua",LUA_MODIFIER_MOTION_NONE )
function modifier_spiky_shell:OnCreated()
	self:OnRefresh()
end

function modifier_spiky_shell:OnCreated()
	self.backDmgRed = -math.abs(self:GetTalentSpecialValueFor("back_damage_reduction"))
	self.sidesDmgRed = -math.abs(self:GetTalentSpecialValueFor("side_damage_reduction"))
	self.backChance = self:GetTalentSpecialValueFor("back_chance")
	self.sidesChance = self:GetTalentSpecialValueFor("side_chance")
end

function modifier_spiky_shell:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_spiky_shell:OnTakeDamage(params)
	if IsServer() then
		if params.unit == self:GetCaster() then
			local ability = self:GetCaster():FindAbilityByName("bristleback_quills")
			if RollPercentage(self:GetTalentSpecialValueFor("chance")) and ability:IsTrained() then
				ability.procDamage = 100
				ability:CastSpell()
				ability.procDamage = nil
			end
		end
	end
end

function modifier_spiky_shell:OnAttackLanded(params)
	if self:GetParent():HasTalent("special_bonus_unique_bristleback_quills_1") and params.attacker == self:GetParent() then
		local roll = self:RollPRNG( self:GetParent():FindTalentValue("special_bonus_unique_bristleback_quills_1") )
		local ability = self:GetCaster():FindAbilityByName("bristleback_quills")
		if roll and ability then
			ability.procDamage = self:GetCaster():FindTalentValue("special_bonus_unique_bristleback_quills_1", "damage")
			ability:CastSpell()
			ability.procDamage = nil
		end
	end
end

function modifier_spiky_shell:GetModifierIncomingDamage_Percentage(params)
	local back = params.attacker:IsAtAngleWithEntity(params.target, 70)
	local front = params.attacker:IsAtAngleWithEntity(params.target, 70, true)
	local chance = 0
	local reduction = 0
	if back then
		chance = self.backChance
		reduction = self.backDmgRed
	elseif not front then -- if not being hit in the front nor the back, being hit from the sides
		chance = self.sidesChance
		reduction = self.sidesDmgRed
	end
	if chance > 0 and self:GetAbility():IsCooldownReady() then
		local ability = self:GetCaster():FindAbilityByName("bristleback_quills")
		if self:RollPRNG(chance) and ability:IsTrained() then
			ability:Spray()
			self:GetAbility():SetCooldown()
		end
	end
	if reduction < 0 then
		return reduction
	end
end

function modifier_spiky_shell:IsHidden()
	return true
end