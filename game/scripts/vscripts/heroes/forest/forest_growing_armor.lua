forest_growing_armor = class({})
LinkLuaModifier( "modifier_forest_growing_armor_buff", "heroes/forest/forest_growing_armor.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function forest_growing_armor:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()

	self.duration = self:GetSpecialValueFor( "duration" )
	self.stack_count = self:GetSpecialValueFor( "damage_count" )

	if hCaster == nil then
		return
	end
	EmitSoundOn("Hero_Treant.LivingArmor.Cast", caster)
	if not hTarget then
		local units = hCaster:FindFriendlyUnitsInRadius(self:GetCursorPosition(), FIND_UNITS_EVERYWHERE, {order = FIND_CLOSEST})
		for _,unit in pairs(units) do
			if unit then
				hTarget = unit
				break
			end
		end
	end
	
	hTarget:AddNewModifier(hCaster, self, "modifier_forest_growing_armor_buff", {duration=self.duration}):SetStackCount(self.stack_count)
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
modifier_forest_growing_armor_buff = class({})

function modifier_forest_growing_armor_buff:OnCreated()
	self.regen = self:GetAbility():GetSpecialValueFor( "regen_bonus" )
	self.damage_block = self:GetAbility():GetSpecialValueFor( "damage_block" )
	self.caster = self:GetCaster()
	
	self.talentregen =  self.caster:FindTalentValue("forest_growing_armor_talent_1")
	if IsServer() then
		local target = self:GetParent()
		local treeFX = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_livingarmor.vpcf", PATTACH_POINT_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(treeFX, 0, target, PATTACH_POINT_FOLLOW, "attach_feet", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(treeFX, 1, target, PATTACH_POINT_FOLLOW, "attach_feet", target:GetAbsOrigin(), true)
		self:AddEffect(treeFX)
		
		EmitSoundOn( "Hero_Treant.LivingArmor.Target", self:GetParent() )
	end
	
end

function modifier_forest_growing_armor_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
		MODIFIER_EVENT_ON_ATTACKED,
	}
	return funcs
end

function modifier_forest_growing_armor_buff:GetModifierHealthRegenPercentage( params )
	return self.talentregen
end

function modifier_forest_growing_armor_buff:GetModifierConstantHealthRegen( params )
	return self.regen
end

function modifier_forest_growing_armor_buff:GetModifierTotal_ConstantBlock( params )
	self.damage_block = self:GetAbility():GetSpecialValueFor( "damage_block" )
	local damageTaken = params.damage
	--print("Damage Taken: " .. damageTaken)
	if self:GetStackCount() > 1 and damageTaken > self.damage_block / 10 then
		self:DecrementStackCount()
	elseif self:GetStackCount() < 2 and damageTaken > self.damage_block then
		self:Destroy()
	end
	return self.damage_block
end