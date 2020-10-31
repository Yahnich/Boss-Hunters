modifier_lives_handler = class({})

function modifier_lives_handler:OnCreated()
	if IsServer() then
		self.limit = 3 + (5 - PlayerResource:GetActivePlayerCount() ) + (self:GetParent().bonusLivesProvided or 0)
		self:SetStackCount(self.limit - 1)
	end
	self:GetParent():HookInModifier("GetReincarnationDelay", self)
end

function modifier_lives_handler:OnRefresh()
	if IsServer() then
		self.limit = 3 + (5 - PlayerResource:GetActivePlayerCount() ) + (self:GetParent().bonusLivesProvided or 0)
		self:SetStackCount( math.min( self.limit, self:GetStackCount() ) )
	end
end

function modifier_lives_handler:GetReincarnationDelay(params)
	if IsServer() then
		if self:GetStackCount() > 0 then
			self.unitWillResurrect = true
			ParticleManager:FireParticle("particles/items_fx/aegis_respawn_timer.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = self:GetParent():GetAbsOrigin(), [1] = Vector(8,0,0)})
			AddFOWViewer( self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), 600, 8, true )
			self:DecrementStackCount()
			self:OnRefresh()
			return 8
		end
	end
end

function modifier_lives_handler:IsHidden()
	return true
end

function modifier_lives_handler:IsPermanent()
	return true
end

function modifier_lives_handler:DestroyOnExpire()
	return false
end

function modifier_lives_handler:IsPermanent()
	return true
end
