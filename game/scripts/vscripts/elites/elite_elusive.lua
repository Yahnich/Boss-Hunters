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
		self:StartIntervalThink( 0.1 )
	end
	
	function modifier_elite_elusive:OnIntervalThink()
		local parent = self:GetParent()
		local enemies = parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.searchRadius )
		if parent:HasModifier("modifier_invisible") then
			if #enemies > 0 then
				parent:RemoveModifierByName("modifier_invisible")
			end
		elseif #enemies == 0 then
			self:StartIntervalThink(-1)
			parent:AddNewModifier( parent, nil, "modifier_item_shadow_amulet_fade", {duration = self.fadeTime} )
			Timers:CreateTimer( self.fadeTime, function()
				parent:AddNewModifier( parent, nil, "modifier_invisible", {} )
				self:StartIntervalThink( 0.1 )
			end)
		end
	end
end

