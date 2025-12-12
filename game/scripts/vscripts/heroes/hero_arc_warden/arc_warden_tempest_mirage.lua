arc_warden_tempest_mirage = class({})
LinkLuaModifier("modifier_arc_warden_tempest_mirage_clone", "heroes/hero_arc_warden/arc_warden_tempest_mirage", LUA_MODIFIER_MOTION_NONE)

function arc_warden_tempest_mirage:GetIntrinsicModifierName()
	return "modifier_arc_warden_tempest_mirage"
end

function arc_warden_tempest_mirage:GetManaCost(iLvl)
	return self:GetCaster():GetMana() * self:GetSpecialValueFor("pct_cost") / 100
end

function arc_warden_tempest_mirage:OnSpellStart()
	local caster = self:GetCaster()
	self:DealDamage( caster, caster, caster:GetMaxHealth() * self:GetSpecialValueFor("pct_cost") / 100, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_REFLECTION +DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_NON_LETHAL } )
	if caster.currentMirage and not caster.currentMirage:IsNull() then
		caster.currentMirage:ForceKill(false)
	end
	
	local mirage
	if self.mirageIndex then
		mirage = EntIndexToHScript( self.mirageIndex )
	end
	if not mirage or mirage:IsNull() then
		self.mirageIndex = CreateUnitByNameAsync("npc_dota_arc_warden_tempest_mirage", caster:GetAbsOrigin() + caster:GetForwardVector() * 128, true, caster, caster, caster:GetTeamNumber(), function( mirage )
			local player = caster:GetPlayerID()
			local duration = self:GetSpecialValueFor("duration")
			mirage:SetControllableByPlayer(player, true)
			mirage:SetUnitCanRespawn(true)
			for abilitySlot=0,24 do
				local ogAbility = caster:GetAbilityByIndex(abilitySlot)
				if ogAbility ~= nil and not ogAbility:IsInnateAbility() then
					local abilityLevel = ogAbility:GetLevel()
					local abilityName = ogAbility:GetAbilityName()
					local illusionAbility = mirage:FindAbilityByName(abilityName)
					if not illusionAbility then
						illusionAbility = mirage:AddAbility(abilityName)
					end
					if illusionAbility then
						illusionAbility:SetLevel( abilityLevel )
						if not caster:HasScepter() then
							illusionAbility:SetCooldown( ogAbility:GetCooldownTimeRemaining() )
						end
					end
				end
			end
			
			mirage:SetBaseDamageMax( caster:GetBaseDamageMax() - 10 )
			mirage:SetBaseDamageMin( caster:GetBaseDamageMin() - 10 )
			mirage:SetBaseHealthRegen( caster:GetBaseHealthRegen() )
			mirage:SetBaseManaRegen( caster:GetBaseManaRegen() )
			mirage:SetPhysicalArmorBaseValue( caster:GetPhysicalArmorBaseValue() )
			mirage:SetBaseMoveSpeed( caster:GetBaseMoveSpeed() )
			
			-- Recreate the items of the caster
			for itemSlot=0,5 do
				local item = caster:GetItemInSlot(itemSlot)
				if item ~= nil and not ( item.IsConsumable and item:IsConsumable() ) then
					local itemName = item:GetName()
					local newItem = mirage:AddItemByName(itemName)
					if newItem then
						if not caster:HasScepter() then
							newItem:SetCooldown( item:GetCooldownTimeRemaining() )
						end
						newItem:SetSellable(false)
						newItem:SetDroppable(false)
						newItem:SetShareability( ITEM_FULLY_SHAREABLE )
						newItem:SetPurchaser( nil )
					end
				end
			end
			mirage.wearableList = {}
			mirage:AddNewModifier(caster, ability, "modifier_arc_warden_tempest_mirage_clone", { duration = duration })
			mirage:AddNewModifier(caster, ability, "modifier_kill", { duration = duration })
			local illuBonus = mirage:AddNewModifier( caster, nil, "modifier_illusion_bonuses", {})
			if illuBonus then illuBonus.GetDisableHealing = function() return 0 end end
			mirage:AddNewModifier( caster, nil, "modifier_stats_system_handler", {})
			for _, modifier in ipairs( caster:FindAllModifiers() ) do
				if modifier:GetName() ~= "modifier_stats_system_handler" and not (modifier.IsRelicModifier and modifier:IsRelicModifier()) then
					local modCaster = modifier:GetCaster()
					if modCaster == caster then
						modCaster = mirage
					end
					local newMod = mirage:AddNewModifier( modCaster, modifier:GetAbility(), modifier:GetName(), { duration = math.max( modifier:GetRemainingTime(), -1 ) })
					if newMod then
						newMod:SetStackCount( modifier:GetStackCount() )
					end
				end
			end
			local wearableWorker = {}
			for _, wearable in ipairs( caster:GetChildren() ) do
				if wearable:GetClassname() == "dota_item_wearable" and wearable:GetModelName() ~= "" then
					CreateUnitByNameAsync("wearable_dummy", mirage:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber(), function( newWearable )
						newWearable:SetOriginalModel(wearable:GetModelName())
						newWearable:SetModel(wearable:GetModelName())
						newWearable:AddNewModifier(caster, ability, "modifier_wearable", {})
						newWearable:AddNewModifier(caster, ability, "modifier_arc_warden_tempest_mirage_clone", {})
						newWearable:AddNewModifier(caster, ability, "modifier_kill", { duration = duration })
						newWearable:SetParent(mirage, nil)
						newWearable:FollowEntity(mirage, true)
						newWearable:SetRenderColor(100,100,255)
						table.insert( mirage.wearableList, newWearable )
					end)
				end
			end
			
			-- Make mirage look like caster
			mirage:SetBaseMaxHealth( caster:GetBaseMaxHealth() )
			mirage:SetThreat( caster:GetThreat() )
			caster.currentMirage = mirage
			ResolveNPCPositions( mirage:GetAbsOrigin(), 128 )
			ParticleManager:FireParticle("particles/units/heroes/hero_arc_warden/arc_warden_tempest_cast.vpcf", PATTACH_ABSORIGIN, mirage)
			mirage:EmitSound("Hero_ArcWarden.TempestDouble")
		end )
	else
		local player = caster:GetPlayerID()
		local duration = self:GetSpecialValueFor("duration")
		mirage:SetControllableByPlayer(player, true)
		mirage:RespawnUnit()
		for abilitySlot=0,24 do
			local ogAbility = caster:GetAbilityByIndex(abilitySlot)
			if ogAbility ~= nil and not ogAbility:IsInnateAbility() then
				local abilityLevel = ogAbility:GetLevel()
				local abilityName = ogAbility:GetAbilityName()
				local illusionAbility = mirage:FindAbilityByName(abilityName)
				if not illusionAbility then
					illusionAbility = mirage:AddAbility(abilityName)
				end
				if illusionAbility then
					illusionAbility:SetLevel( abilityLevel )
					if not caster:HasScepter() then
						illusionAbility:SetCooldown( ogAbility:GetCooldownTimeRemaining() )
					end
				end
			end
		end
		
		mirage:SetBaseDamageMax( caster:GetBaseDamageMax() - 10 )
		mirage:SetBaseDamageMin( caster:GetBaseDamageMin() - 10 )
		mirage:SetBaseHealthRegen( caster:GetBaseHealthRegen() )
		mirage:SetBaseManaRegen( caster:GetBaseManaRegen() )
		mirage:SetPhysicalArmorBaseValue( caster:GetPhysicalArmorBaseValue() )
		mirage:SetBaseMoveSpeed( caster:GetBaseMoveSpeed() )
		
		-- Recreate the items of the caster
		for itemSlot=0,5 do
			local item = caster:GetItemInSlot(itemSlot)
			if item ~= nil and not ( item.IsConsumable and item:IsConsumable() ) then
				local itemName = item:GetName()
				local newItem = mirage:AddItemByName(itemName)
				if newItem then
					if not caster:HasScepter() then
						newItem:SetCooldown( item:GetCooldownTimeRemaining() )
					end
					newItem:SetSellable(false)
					newItem:SetDroppable(false)
					newItem:SetShareability( ITEM_FULLY_SHAREABLE )
					newItem:SetPurchaser( nil )
				end
			end
		end
		mirage.wearableList = {}
		mirage:AddNewModifier(caster, ability, "modifier_arc_warden_tempest_mirage_clone", { duration = duration })
		mirage:AddNewModifier(caster, ability, "modifier_kill", { duration = duration })
		if illuBonus then illuBonus.GetDisableHealing = function() return 0 end end
		mirage:AddNewModifier( caster, nil, "modifier_stats_system_handler", {})
		for _, modifier in ipairs( caster:FindAllModifiers() ) do
			if modifier:GetName() ~= "modifier_stats_system_handler" and not (modifier.IsRelicModifier and modifier:IsRelicModifier()) then
				local modCaster = modifier:GetCaster()
				if modCaster == caster then
					modCaster = mirage
				end
				local newMod = mirage:AddNewModifier( modCaster, modifier:GetAbility(), modifier:GetName(), { duration = math.max( modifier:GetRemainingTime(), -1 ) })
				if newMod then
					newMod:SetStackCount( modifier:GetStackCount() )
				end
			end
		end
		
		-- Make mirage look like caster
		mirage:SetBaseMaxHealth( caster:GetBaseMaxHealth() )
		mirage:SetThreat( caster:GetThreat() )
		caster.currentMirage = mirage
		ResolveNPCPositions( mirage:GetAbsOrigin(), 128 )
		ParticleManager:FireParticle("particles/units/heroes/hero_arc_warden/arc_warden_tempest_cast.vpcf", PATTACH_ABSORIGIN, mirage)
		mirage:EmitSound("Hero_ArcWarden.TempestDouble")
	end
end


modifier_arc_warden_tempest_mirage_clone = class({})

function modifier_arc_warden_tempest_mirage_clone:OnCreated()
	self.unitOwnerEntity = self:GetCaster()
	if IsServer() then
		local eyes = ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_tempest_eyes.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		local body = ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_tempest_buff.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(eyes, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_head", self:GetParent():GetAbsOrigin(), true)
		
		self:AddEffect( eyes )
		self:AddEffect( body )
	end
end

function modifier_arc_warden_tempest_mirage_clone:OnDestroy()
	if IsServer() then
		for itemSlot=0,5 do
			local item = self:GetParent():GetItemInSlot(itemSlot)
			if item ~= nil then
				item:Destroy()
				UTIL_Remove(item)
			end
		end
	end
end

function modifier_arc_warden_tempest_mirage_clone:GetStatusEffectName()
	return "particles/status_fx/status_effect_arc_warden_tempest.vpcf"
end

function modifier_arc_warden_tempest_mirage_clone:StatusEffectPriority()
	return 2
end