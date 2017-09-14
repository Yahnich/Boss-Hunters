fg_growing_armor = class({})
LinkLuaModifier( "modifier_fg_growing_armor_lua", "heroes/hero_fg/fg_growing_armor.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function fg_growing_armor:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()

	self.duration = self:GetSpecialValueFor( "duration" )
	self.stack_count = self:GetSpecialValueFor( "damage_count" )

	if hCaster == nil then
		return
	end

	if not hTarget then
		local units = FindUnitsInRadius(hCaster:GetTeam(),self:GetCursorPosition(),nil,150,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		for _,unit in pairs(units) do
			if unit then
				hTarget = unit
  				hTarget:AddNewModifier(hCaster,self,"modifier_fg_growing_armor_lua",{Duration=self.duration})
				hTarget:SetModifierStackCount("modifier_fg_growing_armor_lua",hCaster,self.stack_count)
				break
			end
		end
	else
		hTarget:AddNewModifier(hCaster,self,"modifier_fg_growing_armor_lua",{Duration=self.duration})
		hTarget:SetModifierStackCount("modifier_fg_growing_armor_lua",hCaster,self.stack_count)
	end
end

modifier_fg_growing_armor_lua = class({})

function modifier_fg_growing_armor_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
		MODIFIER_EVENT_ON_ATTACKED,
		--MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}
	return funcs
end

function modifier_fg_growing_armor_lua:GetModifierConstantHealthRegen( params )
	return self:GetAbility():GetSpecialValueFor( "regen_bonus" )
end

function modifier_fg_growing_armor_lua:GetModifierTotal_ConstantBlock( params )
	return self:GetAbility():GetSpecialValueFor( "damage_block" )
end

--[[function modifier_fg_growing_armor_lua:GetModifierHealthRegenPercentage( params )
	--if self:GetCaster():HasTalent("special_bonus_unique_treant") then
		return self:GetCaster():FindTalentValue("special_bonus_unique_treant")
	--end
end]]

function modifier_fg_growing_armor_lua:OnCreated( kv )
	if IsServer() then
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_treant/treant_livingarmor.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() );
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), false )
		ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), false )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
	end
end

function modifier_fg_growing_armor_lua:OnAttacked( params )
	self.damage_block = self:GetAbility():GetSpecialValueFor( "damage_block" )
	local damageTaken = params.damage
	--print("Damage Taken: " .. damageTaken)
	if self:GetStackCount() > 1 and damageTaken > self.damage_block then
		self:DecrementStackCount()
	elseif self:GetStackCount() < 2 and damageTaken > self.damage_block then
		self:Destroy()
	end
end
