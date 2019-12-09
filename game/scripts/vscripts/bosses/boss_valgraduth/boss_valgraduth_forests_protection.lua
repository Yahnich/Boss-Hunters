boss_valgraduth_forests_protection = class({})

function boss_valgraduth_forests_protection:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn( "Hero_Treant.LivingArmor.Cast", caster )
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
		ally:AddNewModifier( caster, self, "modifier_boss_valgraduth_forests_protection", {})
		EmitSoundOn( "Hero_Treant.LivingArmor.Target", ally )
	end
end

modifier_boss_valgraduth_forests_protection = class({})
LinkLuaModifier( "modifier_boss_valgraduth_forests_protection", "bosses/boss_valgraduth/boss_valgraduth_forests_protection", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_valgraduth_forests_protection:OnCreated()
	self.instances = self:GetSpecialValueFor("block_count")
	if self:GetParent() == self:GetCaster() then
		self.instances = self.instances * 2
	end
	self.block = self:GetSpecialValueFor("block_amount")
	if IsServer() then
		self:SetStackCount( self.instances )
		
		local target = self:GetParent()
		local treeFX = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_livingarmor.vpcf", PATTACH_POINT_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(treeFX, 0, target, PATTACH_POINT_FOLLOW, "attach_feet", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(treeFX, 1, target, PATTACH_POINT_FOLLOW, "attach_feet", target:GetAbsOrigin(), true)
		self:AddEffect(treeFX)
	end
end

function modifier_boss_valgraduth_forests_protection:OnRefresh()
	self.instances = self:GetSpecialValueFor("block_count")
	if self:GetParent() == self:GetCaster() then
		self.instances = self.instances * 2
	end
	self.block = self:GetSpecialValueFor("block_amount")
	if IsServer() then
		self:SetStackCount( self.instances )
	end
end

function modifier_boss_valgraduth_forests_protection:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK}
end

function modifier_boss_valgraduth_forests_protection:GetModifierTotal_ConstantBlock(params)
	self:SetStackCount( self:GetStackCount() - 1)
	if self:GetStackCount() <= 0 then
		self:Destroy()
	end
	return self.block
end