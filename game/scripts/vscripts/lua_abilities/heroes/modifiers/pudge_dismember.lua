pudge_dismember = class({})

--------------------------------------------------------------------------------

function pudge_dismember:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function pudge_dismember:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function pudge_dismember:OnCreated( kv )
	self.dismember_damage = self:GetAbility():GetSpecialValueFor( "dismember_damage" )
	self.tick_rate = self:GetAbility():GetSpecialValueFor( "tick_rate" )
	self.strength_damage = self:GetAbility():GetSpecialValueFor( "strength_damage" )
	self.stacks = self:GetAbility():GetSpecialValueFor( "scepter_flesh_stacks" )

	if IsServer() then
		self:GetParent():InterruptChannel()
		self:OnIntervalThink()
		self:StartIntervalThink( self.tick_rate )
	end
end

--------------------------------------------------------------------------------

function pudge_dismember:OnDestroy()
	if IsServer() then
		self:GetCaster():InterruptChannel()
	end
end

--------------------------------------------------------------------------------

function pudge_dismember:OnIntervalThink()
	if IsServer() then
		if self:GetCaster():HasScepter() then
			local fleshheap = self:GetCaster():FindAbilityByName("pudge_flesh_heap_datadriven")
			if self:GetAbility():IsStolen() then
				local pudge = self:GetCaster().target
				fleshheap = pudge:FindAbilityByName("pudge_flesh_heap_datadriven")
				if fleshheap then
					local stacks = self:GetCaster():GetModifierStackCount( "modifier_hp_shift_datadriven_buff_counter" , fleshheap )
					local duration = fleshheap:GetSpecialValueFor("duration")
					for i=0, self.stacks do
						fleshheap:ApplyDataDrivenModifier(pudge, self:GetCaster(), "modifier_hp_shift_datadriven_buff", {duration = duration})
					end
					self:GetCaster():RemoveModifierByName("modifier_hp_shift_datadriven_buff_counter")
					fleshheap:ApplyDataDrivenModifier(pudge, self:GetCaster(), "modifier_hp_shift_datadriven_buff_counter", {duration = duration})
					self:GetCaster():SetModifierStackCount( "modifier_hp_shift_datadriven_buff_counter" , fleshheap, stacks + self.stacks )
				end
			elseif fleshheap then
				local stacks = self:GetCaster():GetModifierStackCount( "modifier_hp_shift_datadriven_buff_counter" , fleshheap )
				local duration = fleshheap:GetSpecialValueFor("duration")
				for i=0, self.stacks do
					fleshheap:ApplyDataDrivenModifier(self:GetCaster(), self:GetCaster(), "modifier_hp_shift_datadriven_buff", {duration = duration})
				end
				self:GetCaster():RemoveModifierByName("modifier_hp_shift_datadriven_buff_counter")
				fleshheap:ApplyDataDrivenModifier(self:GetCaster(), self:GetCaster(), "modifier_hp_shift_datadriven_buff_counter", {duration = duration})
				self:GetCaster():SetModifierStackCount( "modifier_hp_shift_datadriven_buff_counter" , fleshheap, stacks + self.stacks )
			end
			self:GetCaster():CalculateStatBonus()
		end
		local flDamage = self.dismember_damage
		flDamage = flDamage + ( self:GetCaster():GetStrength() * self.strength_damage )
		self:GetCaster():Heal( flDamage, self:GetAbility() )
		local damage = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = flDamage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility()
		}
		ApplyDamage( damage )
		EmitSoundOn( "Hero_Pudge.Dismember", self:GetParent() )
	end
end

--------------------------------------------------------------------------------

function pudge_dismember:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}

	return state
end

--------------------------------------------------------------------------------

function pudge_dismember:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

--------------------------------------------------------------------------------

function pudge_dismember:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

------------------------------------------------------------------------------