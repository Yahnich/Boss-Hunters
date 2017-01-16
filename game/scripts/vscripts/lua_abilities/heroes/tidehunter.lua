tidehunter_kraken_shell_ebf = class({})

function tidehunter_kraken_shell_ebf:GetIntrinsicModifierName()
	return "modifier_tidehunter_kraken_shell_passive"
end

LinkLuaModifier( "modifier_tidehunter_kraken_shell_passive", "lua_abilities/heroes/tidehunter.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_tidehunter_kraken_shell_passive = class({})

function modifier_tidehunter_kraken_shell_passive:OnCreated()
	self.block = self:GetAbility():GetSpecialValueFor("damage_reduction")
	self.blockPct = self:GetAbility():GetSpecialValueFor("damage_reduction_pct") / 100
	self.crit = self:GetAbility():GetSpecialValueFor("critical_chance")
	self.heal = self:GetAbility():GetSpecialValueFor("critical_heal") / 100
	self.currBlock = self.block
end

function modifier_tidehunter_kraken_shell_passive:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
			}
	return funcs
end

function modifier_tidehunter_kraken_shell_passive:IsHidden()
	return true
end

function modifier_tidehunter_kraken_shell_passive:GetModifierPhysical_ConstantBlock(params)
	if IsServer() then
		self.currBlock = self.block
		if params.damage * self.blockPct > self.currBlock then self.currBlock = params.damage * self.blockPct end
		if RollPercentage(self.crit) then 
			self.currBlock = self.currBlock * 2
			self:GetParent():Heal(self:GetParent():GetMaxHealth() * self.heal, self:GetParent())
			local FXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_tidehunter/tidehunter_krakenshell_purge.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
				ParticleManager:SetParticleControl( FXIndex, 0, self:GetParent():GetOrigin() )
			ParticleManager:ReleaseParticleIndex(FXIndex)
			EmitSoundOn("Hero_Tidehunter.KrakenShell", self:GetParent())
			self:GetParent():Purge(false, true, false, true, true)
		end
		return self.currBlock
	end
end