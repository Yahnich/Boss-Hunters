boss_greymane_battle_cry = class({})


function boss_greymane_battle_cry:OnSpellStart()
	local caster = self:GetCaster()
	
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do	
		ally:AddNewModifier( caster, self, "modifier_boss_greymane_battle_cry", {})
	end
	
	ParticleManager:FireParticle("particles/units/heroes/hero_lycan/lycan_howl_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
	caster:EmitSound("Hero_Lycan.Howl")
end

modifier_boss_greymane_battle_cry = class({})
LinkLuaModifier( "modifier_boss_greymane_battle_cry", "bosses/boss_greymane/boss_greymane_battle_cry", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_greymane_battle_cry:OnCreated()
	self.bonus_damage = self:GetSpecialValueFor("bonus_damage")
	self.dispel_pct = self:GetSpecialValueFor("dispel_pct")
	if IsServer() then
		self.hPct = self:GetParent():GetHealthPercent()
		self:SetStackCount(1)
	end
end

function modifier_boss_greymane_battle_cry:OnRefresh()
	self.bonus_damage = self:GetSpecialValueFor("bonus_damage")
	self.dispel_pct = self:GetSpecialValueFor("dispel_pct")
	if IsServer() then
		self.hPct = self:GetParent():GetHealthPercent()
		self:IncrementStackCount()
	end
end

function modifier_boss_greymane_battle_cry:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_boss_greymane_battle_cry:OnTakeDamage(params)
	if params.unit == self:GetParent() then
		if self:GetParent():GetHealthPercent() <= self.hPct - self.dispel_pct then
			self:Destroy()
		end
	end
end

function modifier_boss_greymane_battle_cry:GetModifierBaseDamageOutgoing_Percentage()
	return self.bonus_damage * self:GetStackCount()
end

function modifier_boss_greymane_battle_cry:GetEffectName()
	return "particles/units/heroes/hero_lycan/lycan_howl_buff.vpcf"
end