treant_living_armor_bh = class({})

function treant_living_armor_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if not target then
		target = caster:FindFriendlyUnitsInRadius( self:GetCursorPosition(), -1, {order = FIND_CLOSEST} )[1]
	end
	if target then
		self:ApplyLivingArmor(target)
	end
	caster:EmitSound("Hero_Treant.LivingArmor.Cast")
end

function treant_living_armor_bh:ApplyLivingArmor(target, duration)
	local caster = self:GetCaster()
	local bDur = duration or self:GetTalentSpecialValueFor("duration")
	target:AddNewModifier( caster, self, "modifier_treant_living_armor_bh", {duration = bDur})
	target:EmitSound("Hero_Treant.LivingArmor.Target")
end

modifier_treant_living_armor_bh = class({})
LinkLuaModifier( "modifier_treant_living_armor_bh", "heroes/hero_treant_protector/treant_living_armor_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_treant_living_armor_bh:OnCreated()
	self.instances = self:GetTalentSpecialValueFor("damage_count")
	self.block = self:GetTalentSpecialValueFor("damage_block")
	self.regen = self:GetTalentSpecialValueFor("health_regen")
	self.armor = self:GetCaster():FindTalentValue("special_bonus_unique_treant_living_armor_1")
	self.healAmp = self:GetCaster():FindTalentValue("special_bonus_unique_treant_living_armor_2")
	if IsServer() then
		self:SetStackCount( self.instances )
		
		local target = self:GetParent()
		local treeFX = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_livingarmor.vpcf", PATTACH_POINT_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(treeFX, 0, target, PATTACH_POINT_FOLLOW, "attach_feet", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(treeFX, 1, target, PATTACH_POINT_FOLLOW, "attach_feet", target:GetAbsOrigin(), true)
		self:AddEffect(treeFX)
	end
end

function modifier_treant_living_armor_bh:OnRefresh()
	self.instances = self:GetTalentSpecialValueFor("damage_count")
	self.block = self:GetTalentSpecialValueFor("damage_block")
	self.regen = self:GetTalentSpecialValueFor("health_regen")
	self.armor = self:GetCaster():FindTalentValue("special_bonus_unique_treant_living_armor_1")
	self.healAmp = self:GetCaster():FindTalentValue("special_bonus_unique_treant_living_armor_2")
	if IsServer() then
		self:SetStackCount( self.instances )
	end
end

function modifier_treant_living_armor_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_treant_living_armor_bh:GetModifierTotal_ConstantBlock(params)
	if HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS ) then return end
	self:SetStackCount( self:GetStackCount() - 1)
	if self:GetStackCount() <= 0 then
		self:Destroy()
	end
	return self.block
end

function modifier_treant_living_armor_bh:GetModifierConstantHealthRegen()
	return self.regen
end

function modifier_treant_living_armor_bh:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_treant_living_armor_bh:GetModifierHealAmplify_Percentage()
	return self.healAmp
end