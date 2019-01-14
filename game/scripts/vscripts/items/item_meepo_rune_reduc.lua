item_meepo_rune_reduc = class({})
LinkLuaModifier( "modifier_item_meepo_rune_reduc_buff", "items/item_meepo_rune_reduc.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_meepo_rune_reduc:OnSpellStart()
	local caster = self:GetCaster()

	if caster:IsAlive() then
		EmitSoundOn("Rune.DD", caster)
		
		local duration = self:GetSpecialValueFor("duration")

		caster:AddNewModifier(caster, self, "modifier_item_meepo_rune_reduc_buff", {Duration = duration})
		self:Destroy()
	end
end

modifier_item_meepo_rune_reduc_buff = class({})
function modifier_item_meepo_rune_reduc_buff:OnCreated(table)
	self.damage_reduc = self:GetSpecialValueFor("damage_reduc")

	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_mana_shield_shell_add.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)

		self:AttachEffect(nfx)
	end
end

function modifier_item_meepo_rune_reduc_buff:OnRefresh(table)
	self.damage_reduc = self:GetSpecialValueFor("damage_reduc")
end

function modifier_item_meepo_rune_reduc_buff:DeclareFunctions()
    return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_item_meepo_rune_reduc_buff:GetModifierIncomingDamage_Percentage()
    return self.damage_reduc
end

function modifier_item_meepo_rune_reduc_buff:GetTexture()
    return "item_refresher_shard"
end

function modifier_item_meepo_rune_reduc_buff:IsDebuff()
    return false
end

function modifier_item_meepo_rune_reduc_buff:IsPurgable()
    return true
end