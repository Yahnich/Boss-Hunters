item_meepo_rune_regen = class({})
LinkLuaModifier( "modifier_item_meepo_rune_regen_buff", "items/item_meepo_rune_regen.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_meepo_rune_regen:OnSpellStart()
	local caster = self:GetCaster()

	if caster:IsAlive() then
		EmitSoundOn("Rune.Regen", caster)
		
		local duration = self:GetSpecialValueFor("duration")

		caster:AddNewModifier(caster, self, "modifier_item_meepo_rune_regen_buff", {Duration = duration})
		self:Destroy()
	end
end

modifier_item_meepo_rune_regen_buff = class({})
function modifier_item_meepo_rune_regen_buff:OnCreated(table)
	if IsServer() then
		self.hpRegen = self:GetParent():GetMaxHealth() * self:GetSpecialValueFor("regen")/100 * 0.2
		self.manaRegen = self:GetParent():GetMaxMana() * self:GetSpecialValueFor("regen")/100 * 0.2

		self:StartIntervalThink(0.2)
	end
end

function modifier_item_meepo_rune_regen_buff:OnRefresh(table)
	if IsServer() then
		self.hpRegen = self:GetParent():GetMaxHealth() * self:GetSpecialValueFor("regen")/100 * 0.2
		self.manaRegen = self:GetParent():GetMaxMana() * self:GetSpecialValueFor("regen")/100 * 0.2
	end
end

function modifier_item_meepo_rune_regen_buff:OnIntervalThink()
    self:GetParent():HealEvent(self.hpRegen, self:GetAbility(), self:GetParent(), false)
    self:GetParent():RestoreMana( self.manaRegen )
end

function modifier_item_meepo_rune_regen_buff:GetEffectName()
    return "particles/generic_gameplay/rune_regen_owner.vpcf"
end

function modifier_item_meepo_rune_regen_buff:GetTexture()
    return "rune_regen"
end

function modifier_item_meepo_rune_regen_buff:IsDebuff()
    return false
end

function modifier_item_meepo_rune_regen_buff:IsPurgable()
    return true
end