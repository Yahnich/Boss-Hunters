timbersaw_hylophobia = class({})

function timbersaw_hylophobia:GetIntrinsicModifierName()
	return "modifier_timbersaw_hylophobia"
end

LinkLuaModifier( "modifier_timbersaw_hylophobia", "heroes/hero_timbersaw/timbersaw_hylophobia.lua" ,LUA_MODIFIER_MOTION_NONE )

modifier_timbersaw_hylophobia = class({})
function modifier_timbersaw_hylophobia:OnCreated()
	self:OnRefresh()
end

function modifier_timbersaw_hylophobia:OnRefresh()
	self.amp = self:GetTalentSpecialValueFor("bonus_spell_amp")
	self.duration = self:GetTalentSpecialValueFor("duration")
end

function modifier_timbersaw_hylophobia:OnIntervalThink()
	self:SetDuration( -1, true )
	self:StartIntervalThink( -1 )
end

function modifier_timbersaw_hylophobia:DeclareFunctions()
    funcs = { MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
    return funcs
end

function modifier_timbersaw_hylophobia:GetModifierSpellAmplify_Percentage()
    return self.amp * self:GetStackCount()
end

function modifier_timbersaw_hylophobia:OnTreesCutDown( params )
	if params.unit == self:GetParent() then
		self:AddIndependentStack(self.duration, nil, nil, {stacks = params.trees})
		self:SetDuration( self.duration + 0.1, true )
		self:StartIntervalThink( self.duration )
	end
end

function modifier_timbersaw_hylophobia:IsPurgable()
    return false
end

function modifier_timbersaw_hylophobia:DestroyOnExpire()
    return false
end

function modifier_timbersaw_hylophobia:IsHidden()
	return self:GetStackCount() == 0
end