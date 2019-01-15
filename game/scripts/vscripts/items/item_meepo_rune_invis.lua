item_meepo_rune_invis = class({})
LinkLuaModifier( "modifier_item_meepo_rune_invis_buff", "items/item_meepo_rune_invis.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_meepo_rune_invis:OnSpellStart()
	local caster = self:GetCaster()

	if caster:IsAlive() then
        EmitSoundOn("Rune.Invis", caster)
        
		local duration = self:GetSpecialValueFor("duration")

		caster:AddNewModifier(caster, self, "modifier_item_meepo_rune_invis_buff", {Duration = duration})
		self:Destroy()
	end
end

modifier_item_meepo_rune_invis_buff = class({})
function modifier_item_meepo_rune_invis_buff:DeclareFunctions()
    return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
			MODIFIER_EVENT_ON_ATTACK,
			MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end

function modifier_item_meepo_rune_invis_buff:GetModifierInvisibilityLevel()
    return 1
end

function modifier_item_meepo_rune_invis_buff:OnAttack(params)
    if IsServer() then
    	if params.attacker == self:GetParent() then
    		self:Destroy()
    	end
    end
end

function modifier_item_meepo_rune_invis_buff:OnAbilityExecuted(params)
    if IsServer() then
    	if params.unit == self:GetParent() then
    		self:Destroy()
    	end
    end
end

function modifier_item_meepo_rune_invis_buff:CheckState()
	local state = { [MODIFIER_STATE_INVISIBLE] = true}
	return state
end

function modifier_item_meepo_rune_invis_buff:GetTexture()
    return "rune_invis"
end

function modifier_item_meepo_rune_invis_buff:IsDebuff()
    return false
end

function modifier_item_meepo_rune_invis_buff:IsPurgable()
    return true
end