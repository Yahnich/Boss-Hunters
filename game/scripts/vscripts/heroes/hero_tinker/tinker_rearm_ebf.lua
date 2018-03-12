tinker_rearm_ebf = class({})
LinkLuaModifier( "modifier_tinker_rearm_ebf", "heroes/hero_tinker/tinker_rearm_ebf.lua", LUA_MODIFIER_MOTION_NONE )

function tinker_rearm_ebf:OnAbilityPhaseStart()
	EmitSoundOn("Hero_Tinker.RearmStart", self:GetCaster())
    return true
end

function tinker_rearm_ebf:OnAbilityPhaseInterrupted()
	StopSoundOn("Hero_Tinker.RearmStart", self:GetCaster())
end

function tinker_rearm_ebf:GetManaCost()
    local manaCost = self:GetCaster():GetMaxMana()*self:GetTalentSpecialValueFor("mana_cost")/100
    return manaCost
end

function tinker_rearm_ebf:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Tinker.Rearm", caster)
	caster:AddNewModifier(caster, self, "modifier_tinker_rearm_ebf", {Duration = self:GetChannelTime()})

	if caster:HasTalent("special_bonus_unique_tinker_rearm_ebf_2") and not caster:HasModifier("modifier_generic_barrier") then
		local manaCost = self:GetCaster():GetMaxMana()*caster:FindTalentValue("special_bonus_unique_tinker_rearm_ebf_2", "amount")/100
		caster:AddBarrier(manaCost, caster, self, caster:FindTalentValue("special_bonus_unique_tinker_rearm_ebf_2"))
	end
end

function tinker_rearm_ebf:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Tinker.Rearm", caster)

	-- Reset cooldown for abilities
    for i = 0, caster:GetAbilityCount() - 1 do
        local ability = caster:GetAbilityByIndex( i )
        if ability and ability ~= self then
            ability:Refresh()
        end
    end

    local no_refresh_item = {["item_ressurection_stone"] = true,
							 ["item_refresher"] = true,
							 ["item_bahamut_chest"]= true,
							 ["item_asura_plate"]= true,
							 ["item_octarine_core4"] = true,
							 ["item_octarine_core5"] = true,
							 ["item_asura_core"] = true,
							 ["item_lifesteal2"] = true,
							 ["item_lifesteal3"] = true,
							 ["item_lifesteal4"] = true,}
	local half_refresh_item = {["item_chronos_shard"] = true, 
							   ["item_blade_mail"] = true,
							   ["item_blade_mail2"] = true,
							   ["item_blade_mail3"] = true,
							   ["item_blade_mail4"] = true,
							   ["item_pixels_guard"] = true,
							   ["item_sheepstick"] = true,}
	
    for i = 0, 5 do
        local item = caster:GetItemInSlot( i )
		if item then
			local cd = item:GetCooldownTimeRemaining()
			if not no_refresh_item[ item:GetAbilityName() ] then
				item:Refresh()
			end
			if cd > 1 and half_refresh_item[ item:GetAbilityName() ] then
				item:StartCooldown(cd/2)
			end
		end
    end
end

modifier_tinker_rearm_ebf = class({})
function modifier_tinker_rearm_ebf:OnCreated(table)
	if IsServer() then
		if self:GetAbility():GetLevel() <= 3 then
			self:GetParent():StartGesture(ACT_DOTA_TINKER_REARM1)
		elseif self:GetAbility():GetLevel() <= 5 then
			self:GetParent():StartGesture(ACT_DOTA_TINKER_REARM2)
		else
			self:GetParent():StartGesture(ACT_DOTA_TINKER_REARM3)
		end
	end
end

function modifier_tinker_rearm_ebf:GetEffectName()
	return "particles/units/heroes/hero_tinker/tinker_rearm.vpcf"
end

function modifier_tinker_rearm_ebf:IsHidden()
	return true
end