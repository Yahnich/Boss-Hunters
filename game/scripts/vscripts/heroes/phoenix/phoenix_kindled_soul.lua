phoenix_kindled_soul = class({})

LinkLuaModifier( "modifier_phoenix_kindled_soul_passive", "heroes/phoenix/phoenix_kindled_soul.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_phoenix_kindled_soul_active", "heroes/phoenix/phoenix_kindled_soul.lua" ,LUA_MODIFIER_MOTION_NONE )

function phoenix_kindled_soul:GetIntrinsicModifierName()
	return "modifier_phoenix_kindled_soul_passive"
end

function phoenix_kindled_soul:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_phoenix_kindled_soul_active") then
		return "custom/phoenix_kindled_soul_kindled"
	else
		return "custom/phoenix_kindled_soul"
	end
end

modifier_phoenix_kindled_soul_passive = class({})

function modifier_phoenix_kindled_soul_passive:OnCreated()
	self.stacks = self:GetAbility():GetSpecialValueFor("spell_cast_requirement")
	self:SetStackCount(0)
end

function modifier_phoenix_kindled_soul_passive:OnRefresh()
	self.stacks = self:GetAbility():GetSpecialValueFor("spell_cast_requirement")
end

function modifier_phoenix_kindled_soul_passive:IsPurgable()
	return false
end

function modifier_phoenix_kindled_soul_passive:GetTexture()
	return "custom/phoenix_kindled_soul"
end

function modifier_phoenix_kindled_soul_passive:IsHidden()
	if self:GetParent():HasModifier("modifier_phoenix_kindled_soul_active") then
		return true
	else
		return false
	end
end

function modifier_phoenix_kindled_soul_passive:RemoveOnDeath()
	return false
end

function modifier_phoenix_kindled_soul_passive:IsPassive()
	return true
end

function modifier_phoenix_kindled_soul_passive:DeclareFunctions()
	return 
	{ 
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
end

function modifier_phoenix_kindled_soul_passive:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() and self:GetParent():HasAbility( params.ability:GetName() ) and not self:IsHidden() then
		self:IncrementStackCount()
		if self:GetStackCount() >= self.stacks then
			local stacks = self:GetAbility():GetTalentSpecialValueFor("active_stacks")
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_phoenix_kindled_soul_active", {}):SetStackCount(stacks)
			self:SetStackCount(0)
		end
	end
end

modifier_phoenix_kindled_soul_active = class({})

if IsServer() then
	function modifier_phoenix_kindled_soul_active:OnCreated()
		EmitSoundOn("Hero_DragonKnight.ElderDragonForm", self:GetParent())
		self.fireHair = ParticleManager:CreateParticle("particles/econ/wards/lina/lina_ward/lina_ward_ambient.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(self.fireHair, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_head", self:GetParent():GetAbsOrigin(), true)
		
		
		local flamePoof = ParticleManager:CreateParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(flamePoof, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(flamePoof)
	end

	function modifier_phoenix_kindled_soul_active:OnRefresh()
		local flamePoof = ParticleManager:CreateParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(flamePoof, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(flamePoof)
	end
	
	function modifier_phoenix_kindled_soul_active:OnDestroy()
		ParticleManager:DestroyParticle(self.fireHair, false)
		ParticleManager:ReleaseParticleIndex(self.fireHair)
	end
end


function modifier_phoenix_kindled_soul_active:IsPurgable()
	return false
end

function modifier_phoenix_kindled_soul_active:IsHidden()
	return false
end

function modifier_phoenix_kindled_soul_active:GetTexture()
	return "custom/phoenix_kindled_soul_kindled"
end

function modifier_phoenix_kindled_soul_active:DeclareFunctions()
	return 
	{ 
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
end

function modifier_phoenix_kindled_soul_active:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() and self:GetParent():HasAbility( params.ability:GetName() ) then
		self:DecrementStackCount()
		if self:GetStackCount() < 1 then
			self:Destroy()
		end
	end
end

function modifier_phoenix_kindled_soul_active:GetStatusEffectName()
	return "particles/status_effect_lina_enkindled.vpcf"
end

function modifier_phoenix_kindled_soul_active:StatusEffectPriority()
	return 20
end