relic_ofuda = class(relicBaseClass)

function relic_ofuda:OnCreated()
	local stacks = 3
	if IsServer() then
		for _, modifier in ipairs( self:GetCaster():FindAllModifiers() ) do
			if modifier.IsCurse and modifier:IsCurse() then
				modifier:Destroy()
				stacks = stacks - 1
				if self:GetStackCount() == 0 then
					break
				end
			end
		end
		if stacks > 0 then
			self:SetStackCount( stacks )
		else
			self:OnStackCountChanged()
		end
	end
end

function relic_ofuda:OnStackCountChanged()
	if IsServer() and self:GetStackCount() == 0 then
		local parent = self:GetParent()
		local ability = self:GetAbility()
		parent.ownedRelics[ability:entindex()].name = "relic_ofuda_spent"
		LinkLuaModifier("relic_ofuda_spent", "relics/relic_ofuda", LUA_MODIFIER_MOTION_NONE)
		parent:AddNewModifier( parent, ability, "relic_ofuda_spent", {})
		if parent:GetPlayerOwner() then
			CustomGameEventManager:Send_ServerToAllClients( "dota_player_update_relic_inventory", { hero = parent:entindex(), relics = parent.ownedRelics } )
		end
		self:Destroy()
	end
end

function relic_ofuda:IsHidden()
	return self:GetStackCount() == 0
end

relic_ofuda_spent = class(relicBaseClass)