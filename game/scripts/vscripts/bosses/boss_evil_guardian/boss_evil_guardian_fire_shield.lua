boss_evil_guardian_fire_shield = class({})

function boss_evil_guardian_fire_shield:GetIntrinsicModifierName()
	return "modifier_boss_evil_guardian_fire_shield_handler"
end

modifier_boss_evil_guardian_fire_shield_handler = class({})
LinkLuaModifier("modifier_boss_evil_guardian_fire_shield_handler", "bosses/boss_evil_guardian/boss_evil_guardian_fire_shield", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_boss_evil_guardian_fire_shield_handler:OnCreated()
		self.isActive = self:GetParent():HasModifier("modifier_boss_evil_guardian_fire_shield_active")
		local parent = self:GetParent()
		parent.manaCharge = parent:GetMaxMana()
		self.manaChargeDecrease = ( parent.manaCharge / self:GetTalentSpecialValueFor("time_to_lose_shield") ) * 0.2
		self.manaChargeIncrease = ( parent.manaCharge / self:GetTalentSpecialValueFor("recharge_time") ) * 0.2
		self:StartIntervalThink(0.2)
	end
	
	function modifier_boss_evil_guardian_fire_shield_handler:OnIntervalThink()
		local parent = self:GetParent()
		parent:SetMana(parent.manaCharge)
		if not self.isActive then
			if parent.manaCharge == parent:GetMaxMana() then
				parent:AddNewModifier(parent, self:GetAbility(), "modifier_boss_evil_guardian_fire_shield_active", {})
			else
				parent.manaCharge = math.min(parent:GetMaxMana(), parent.manaCharge + self.manaChargeIncrease)
			end
		else
			if parent.manaCharge == 0 then
				parent:RemoveModifierByName("modifier_boss_evil_guardian_fire_shield_active")
			else
				parent.manaCharge = math.max(0, parent.manaCharge - self.manaChargeDecrease)
			end
		end
		self.isActive = parent:HasModifier("modifier_boss_evil_guardian_fire_shield_active")
	end
end

function modifier_boss_evil_guardian_fire_shield_handler:IsHidden()
	return true
end

modifier_boss_evil_guardian_fire_shield_active = class({})
LinkLuaModifier("modifier_boss_evil_guardian_fire_shield_active", "bosses/boss_evil_guardian/boss_evil_guardian_fire_shield", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_boss_evil_guardian_fire_shield_active:OnCreated()
		self.damageTaken = self:GetTalentSpecialValueFor("damage_to_mana_loss") / 100
		self.damageTaken = self.damageTaken / HeroList:GetActiveHeroCount()
		fireFX = ParticleManager:CreateParticle("particles/demon_shield.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		local size = Vector(300,300,0)
		ParticleManager:SetParticleControl(fireFX, 1, size)
		self:AddEffect(fireFX)
	end
end

function modifier_boss_evil_guardian_fire_shield_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_boss_evil_guardian_fire_shield_active:GetModifierIncomingDamage_Percentage( params )
	local parent = self:GetParent()
	
	local damage = params.damage * self.damageTaken
	parent.manaCharge = math.max( 0, parent.manaCharge - damage )
	return -999
end