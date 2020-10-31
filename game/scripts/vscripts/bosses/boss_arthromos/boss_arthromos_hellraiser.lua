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
	if params.attacker == self:GetParent() and not params.unit:IsSameTeam(params.attacker) and not params.unit:IsIllusion() then
		local illusions = params.unit:ConjureImage( {outgoing_damage = self.outgoing, incoming_damage = self.incoming}, -1, params.attacker, 1 )
		illusions[1]:SetHealth( illusions[1]:GetMaxHealth() )
		Timers:CreateTimer(0.5, function()
			if not illusions[1] or illusions[1]:IsNull() then return end
			if not params.attacker or params.attacker:IsNull() or not params.attacker:IsAlive() then
				illusions[1]:ForceKill(false)
			else
				illusions[1]:MoveToPositionAggressive( params.attacker:GetAbsOrigin() + RandomVector( 600 ) )
			end
			return 0.5
		end)
	end
end

function modifier_boss_arthromos_hellraiser:IsHidden()
	return true
end