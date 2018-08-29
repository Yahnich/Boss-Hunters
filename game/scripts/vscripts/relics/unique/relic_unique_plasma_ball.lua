relic_unique_plasma_ball = class(relicBaseClass)

if IsServer() then
	function relic_unique_plasma_ball:OnCreated()
		self.charge = 0
		self.lastPos = self:GetParent():GetAbsOrigin()
		self:StartIntervalThink(0.1)
		self:SetDuration(6, true)
	end
	
	function relic_unique_plasma_ball:OnIntervalThink()
		local parent = self:GetParent()
		if self:GetRemainingTime() <= 0 and self:GetDuration() ~= -1 then
			self:SetDuration(-1, true)
		end
		self.charge = self.charge + math.min( CalculateDistance( parent, self.lastPos ), math.max( parent:GetIdealSpeed(), 700 ) * 0.1 )
		self.lastPos = parent:GetAbsOrigin()
		if self:GetDuration() == - 1 then
			local enemies = parent:FindEnemyUnitsInRadius( self.lastPos, self.charge )
			if #enemies > 0 then
				local ability = self:GetAbility()
				for _, enemy in ipairs( enemies ) do
					ability:DealDamage( parent, enemy, 225, {damage_type = DAMAGE_TYPE_MAGICAL} )
					ParticleManager:FireRopeParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_POINT_FOLLOW, parent, enemy)
				end
				self.charge = 0
				self:SetDuration(6, true)
			end
		end
	end
end