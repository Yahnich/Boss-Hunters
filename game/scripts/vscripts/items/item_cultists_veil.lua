item_cultists_veil = class({})

LinkLuaModifier( "modifier_item_cultists_veil", "items/item_cultists_veil.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_cultists_veil:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")
	
	EmitSoundOn( "DOTA_Item.VeilofDiscord.Activate", self:GetCaster() )
	ParticleManager:FireParticle("particles/items2_fx/veil_of_discord.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = point, [1] = Vector(radius,1,1)})
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( point, radius ) ) do
		enemy:AddNewModifier(caster, self, "modifier_cultists_veil_debuff", {duration = duration})
	end
end

LinkLuaModifier( "modifier_cultists_veil_debuff", "items/item_cultists_veil.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_cultists_veil_debuff = class({})

function modifier_cultists_veil_debuff:OnCreated()
	self.mr = (-1) * self:GetAbility():GetSpecialValueFor("bonus_magic_damage")
end

function modifier_cultists_veil_debuff:OnRefresh()
	self.mr = math.min(self.mr, (-1) * self:GetAbility():GetSpecialValueFor("bonus_magic_damage"))
end

function modifier_cultists_veil_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_cultists_veil_debuff:GetModifierMagicalResistanceBonus()
	return self.mr
end