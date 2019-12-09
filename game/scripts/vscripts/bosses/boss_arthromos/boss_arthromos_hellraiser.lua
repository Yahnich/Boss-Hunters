boss_arthromos_hellraiser = class({})

function boss_arthromos_hellraiser:GetIntrinsicModifierName()
	return "modifier_boss_arthromos_hellraiser"
end

modifier_boss_arthromos_hellraiser = class({})
LinkLuaModifier( "modifier_boss_arthromos_hellraiser", "bosses/boss_arthromos/boss_arthromos_hellraiser", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_arthromos_hellraiser:OnCreated()
	self.incoming = self:GetSpecialValueFor("incoming") - 100
	self.outgoing = self:GetSpecialValueFor("outgoing") - 100
end

function modifier_boss_arthromos_hellraiser:OnRefresh()
	self:OnCreated()
end

function modifier_boss_arthromos_hellraiser:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_boss_arthromos_hellraiser:OnDeath(params)
	if params.attacker == self:GetParent() then
		local callback = (function( illusion, parent, caster, ability )
			illusion:SetHealth( illusion:GetMaxHealth() )
			if not parent:IsRealHero() then
				illusion:SetRenderColor( 125, 125, 255 )
			end
			Timers:CreateTimer(0.5, function()
				illusion:MoveToPositionAggressive( caster:GetAbsOrigin() )
				if caster:IsNull() or not caster:IsAlive() then
					illusion:SetHealth( 1 )
					illusion:ForceKill(false)
					UTIL_Remove( illusion )
				end
			end)
		end)
		params.unit:ConjureImage( params.unit:GetAbsOrigin(), nil, self.outgoing, self.incoming, nil, self:GetAbility(), false, params.attacker, callback )
	end
end

function modifier_boss_arthromos_hellraiser:IsHidden()
	return true
end