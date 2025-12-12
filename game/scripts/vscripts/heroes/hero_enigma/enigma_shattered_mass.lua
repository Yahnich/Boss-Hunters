enigma_shattered_mass = class({})

function enigma_shattered_mass:GetIntrinsicModifierName()
	return "modifier_enigma_shattered_mass"
end

function enigma_shattered_mass:CreateEidolon( position, tier )
	local caster = self:GetCaster()
	CreateUnitByNameAsync("npc_dota_"..tier.."eidolon", position, true, caster, caster, caster:GetTeamNumber(), function( eidolon )
		eidolon:AddNewModifier( caster, self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")} )
		eidolon:SetControllableByPlayer( caster:GetPlayerID(),  true )
		eidolon:SetOwner(caster)
		if eidolon:GetUnitName() ~= "npc_dota_dire_eidolon" then
			eidolon:AddNewModifier( caster, self, "modifier_enigma_shattered_mass_eidolon", {} )
			eidolon:SetCoreHealth( self:GetSpecialValueFor(tier.."eidolon_hp") )
			eidolon:SetAverageBaseDamage( self:GetOwnerEntity():GetAverageBaseDamage() * self:GetSpecialValueFor(tier.."eidolon_dmg") / 100, 15 )
		else
			eidolon:SetCoreHealth( self:GetSpecialValueFor("dire_eidolon_hp") )
			eidolon:SetAverageBaseDamage( self:GetOwnerEntity():GetAverageBaseDamage() * self:GetSpecialValueFor("dire_eidolon_dmg") / 100, 15 )
		end
		FindClearSpaceForUnit( eidolon, eidolon:GetAbsOrigin(), true )
	end)
end

modifier_enigma_shattered_mass = class({})
LinkLuaModifier("modifier_enigma_shattered_mass", "heroes/hero_enigma/enigma_shattered_mass", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_enigma_shattered_mass:OnCreated()
		self.attacks = 0
		self.attacks_to_split = self:GetSpecialValueFor("split_attack_count")
	end
	
	function modifier_enigma_shattered_mass:OnRefresh()
		self.attacks = 0
		self.attacks_to_split = self:GetSpecialValueFor("split_attack_count")
	end
end

function modifier_enigma_shattered_mass:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_enigma_shattered_mass:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		self.attacks = self.attacks + 1
		if self.attacks >= self.attacks_to_split then
			self.attacks = 0
			self:GetAbility():CreateEidolon( self:GetParent():GetAbsOrigin(), "lesser_")
		end
		self:SetStackCount(self.attacks)
	end
end

modifier_enigma_shattered_mass_eidolon = class({})
LinkLuaModifier("modifier_enigma_shattered_mass_eidolon", "heroes/hero_enigma/enigma_shattered_mass", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_enigma_shattered_mass_eidolon:OnCreated()
		self.attacks = 0
		self.attacks_to_split = self:GetSpecialValueFor("evolve_attack_count")
	end
	
	function modifier_enigma_shattered_mass_eidolon:OnRefresh()
		self.attacks = 0
		self.attacks_to_split = self:GetSpecialValueFor("evolve_attack_count")
	end
end

function modifier_enigma_shattered_mass_eidolon:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_enigma_shattered_mass_eidolon:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		self.attacks = self.attacks + 1
		self:SetStackCount(self.attacks)
		if self.attacks >= self.attacks_to_split then
			self.attacks = 0
			if params.attacker:GetUnitName() == "npc_dota_lesser_eidolon" then
				self:GetAbility():CreateEidolon( self:GetParent():GetAbsOrigin(), "")
			elseif params.attacker:GetUnitName() == "npc_dota_eidolon" then
				self:GetAbility():CreateEidolon( self:GetParent():GetAbsOrigin(), "greater_")
			elseif params.attacker:GetUnitName() == "npc_dota_greater_eidolon" then
				self:GetAbility():CreateEidolon( self:GetParent():GetAbsOrigin(), "dire_")
			end
			params.attacker:ForceKill( false )
			UTIL_Remove( params.attacker )
		end
	end
end