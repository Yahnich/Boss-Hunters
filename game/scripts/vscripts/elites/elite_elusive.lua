elite_elusive = class({})

function elite_elusive:GetIntrinsicModifierName()
	return "modifier_elite_elusive"
end

modifier_elite_elusive = class(relicBaseClass)
LinkLuaModifier("modifier_elite_elusive", "elites/elite_elusive", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_elite_elusive:OnCreated()
		self.fadeTime = self:GetSpecialValueFor("fade_time")
		self.searchRadius = self:GetSpecialValueFor("detection_radius")
		self:StartIntervalThink( 1 )
	end
	
	function modifier_elite_elusive:OnIntervalThink()
		local parent = self:GetParent()
		self.fadeTime = self:GetSpecialValueFor("fade_time")
		self.searchRadius = self:GetSpecialValueFor("detection_radius")
		local enemies = parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.searchRadius, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE} )
		
		self:StartIntervalThink( 0.25 )
		if not parent:HasModifier("modifier_elite_elusive_fade") then
			if #enemies > 0 then
				parent:RemoveModifierByName("modifier_invisible")
			else
				self:StartIntervalThink(self.fadeTime)
				parent:AddNewModifier( parent, nil, "modifier_elite_elusive_fade", {duration = self.fadeTime} )
				Timers:CreateTimer( self.fadeTime, function()
					if parent:IsNull() then return end
					parent:RemoveModifierByName( "modifier_elite_elusive_fade" )
					parent:AddNewModifier( parent, nil, "modifier_invisible", {} )
				end)
			end
		end
	end
end

function modifier_elite_elusive:GetEffectName()
	return "particles/units/elite_warning_special_overhead.vpcf"
end

function modifier_elite_elusive:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

modifier_elite_elusive_fade = class({})
LinkLuaModifier("modifier_elite_elusive_fade", "elites/elite_elusive", LUA_MODIFIER_MOTION_NONE)


function modifier_elite_elusive_fade:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
    }

    return funcs
end

function modifier_elite_elusive_fade:GetModifierInvisibilityLevel( params )
    return 0.45
end
