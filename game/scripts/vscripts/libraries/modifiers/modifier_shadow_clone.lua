modifier_shadow_clone = class({})

function modifier_shadow_clone:OnCreated(table)
	self.incomingdamage = table.incomingdamage or 0
	self.outgoingdamage = table.outgoingdamage or 0
	self.duration = table.duration or 0
	if IsServer() then
		if self:GetParent():IsHero() then
			local casterLevel = self:GetCaster():GetLevel()
			for i=1,casterLevel-1 do
				self:GetParent():HeroLevelUp(false)
			end
		
			self:GetParent():SetAbilityPoints(0)
			for abilitySlot=0,15 do
				local ability = self:GetCaster():GetAbilityByIndex(abilitySlot)
				if ability ~= nil then 
					local abilityLevel = ability:GetLevel()
					local abilityName = ability:GetAbilityName()
					local illusionAbility = self:GetParent():AddAbility(abilityName)
					if illusionAbility then illusionAbility:SetLevel(abilityLevel) end
				end
			end

			-- Recreate the items of the caster
			for itemSlot=0,5 do
				local item = self:GetCaster():GetItemInSlot(itemSlot)
				if item ~= nil then
					local itemName = item:GetName()
					local newItem = CreateItem(itemName, self:GetParent(), self:GetParent())
					self:GetParent():AddItem(newItem)
				end
			end
		end
		self:GetParent():SetAcquisitionRange(self:GetCaster():GetDayTimeVisionRange())
		self:GetParent():SetRenderColor(0, 0, 0)
		-- Set the unit as an illusion
		-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
		local modifier = self:GetParent():AddNewModifier(self:GetCaster(), ability, "modifier_illusion", { duration = self.duration, outgoing_damage = self.outgoingdamage, incoming_damage = self.incomingdamage })
		-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
		self:GetParent():MakeIllusion()
	end
end

function modifier_shadow_clone:DeclareFunctions()
	local funcs = {
   		MODIFIER_PROPERTY_MODEL_SCALE,
	}
	return funcs
end

function modifier_shadow_clone:CheckState()
	local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_UNSELECTABLE] = true,
					[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	 			}
	return state
end

function modifier_shadow_clone:GetModifierModelScale(params)
	return -30
end

function modifier_shadow_clone:GetEffectName()
	return "particles/items2_fx/smoke_of_deceit_buff.vpcf"
end

function modifier_shadow_clone:IsDebuff()
	return true
end

function modifier_shadow_clone:OnDestroy()
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_death_smoke.vpcf", PATTACH_POINT, self:GetParent())
	ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(nfx)
end