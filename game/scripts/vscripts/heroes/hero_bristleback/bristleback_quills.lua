bristleback_quills = class({})

function bristleback_quills:GetIntrinsicModifierName()
	return "modifier_quills"
end

function bristleback_quills:IsStealable()
	return true
end

function bristleback_quills:IsHiddenWhenStolen()
	return false
end

function bristleback_quills:GetCooldown( iLvl )
	if self.procDamage then
		return 0
	end
	local cd = self.BaseClass.GetCooldown( self, iLvl )
	-- if self:GetCaster():HasModifier("modifier_quills_buff") then
		-- cd = cd - self:GetSpecialValueFor("cdr_per_stack") * self:GetCaster():GetModifierStackCount( "modifier_quills_buff", self:GetCaster() )
	-- end
	return cd
end

function bristleback_quills:GetManaCost( iLvl )
	if self.procDamage then
		return 0
	end
	return self.BaseClass.GetManaCost( self, iLvl )
end

function bristleback_quills:OnSpellStart()
	local dmgModifier = 100
	if self.procDamage then
		dmgModifier = self.procDamage
	end
	self:Spray(dmgModifier)
end

function bristleback_quills:Spray(dmgModifier, flRadius, target)
	local caster = self:GetCaster()
	local target = target or caster
	local radius = flRadius or self:GetSpecialValueFor("radius")
	
	local dmgMod = (dmgModifier or 100)/100
	local baseDamage = self:GetSpecialValueFor("quill_base_damage")
	local stackDamage = self:GetSpecialValueFor("quill_stack_damage")
	local maxDamage = self:GetSpecialValueFor("quill_max_dmg")
	local duration = self:GetSpecialValueFor("quill_stack_duration")
	
	EmitSoundOn("Hero_Bristleback.QuillSpray.Cast", target)
	ParticleManager:FireParticle("particles/units/heroes/hero_bristleback/bristleback_quill_spray.vpcf", PATTACH_POINT, target)
	
	local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), radius)
	for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb( self ) then
			EmitSoundOn("Hero_Bristleback.QuillSpray.Target", enemy)
			local stacks = enemy:GetModifierStackCount( "modifier_quills_debuff", caster )
			local damage = math.min( maxDamage, baseDamage + stackDamage * stacks )
			self:DealDamage(caster, enemy, damage * dmgMod)
			enemy:AddNewModifier(caster, self, "modifier_quills_debuff", {duration = duration})
		end
	end
end

modifier_quills = class({})
LinkLuaModifier( "modifier_quills", "heroes/hero_bristleback/bristleback_quills.lua",LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_quills:OnCreated(kv)
		-- self:GetAbility():Spray()
		self:StartIntervalThink(0.1)
	end

	function modifier_quills:OnRemoved()
		StopSoundOn("Hero_Bristleback.QuillSpray.Cast", self:GetCaster())
	end

	function modifier_quills:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if ability:GetAutoCastState() and caster:IsRealHero() and caster:IsAlive() and ability:IsFullyCastable() and ability:IsOwnersManaEnough() and not caster:HasActiveAbility() then
			ability:CastSpell()
		elseif not ability:IsOwnersManaEnough() and ability:GetAutoCastState() then
			ability:ToggleAutoCast()
		end
	end
end

function modifier_quills:IsHidden() return true end

modifier_quills_buff = class({})
LinkLuaModifier( "modifier_quills_buff", "heroes/hero_bristleback/bristleback_quills.lua",LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_quills_buff:OnCreated(kv)
		self:SetStackCount(1)
	end
	
	function modifier_quills_buff:OnRefresh(kv)
		self:SetStackCount( math.min( self:GetStackCount() + 1, self:GetSpecialValueFor("quill_max_stacks") ) )
	end
end

modifier_quills_debuff = class({})
LinkLuaModifier( "modifier_quills_debuff", "heroes/hero_bristleback/bristleback_quills.lua",LUA_MODIFIER_MOTION_NONE )


function modifier_quills_debuff:OnCreated(kv)
	self:OnRefresh()
end

function modifier_quills_debuff:OnRefresh(kv)
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_bristleback_quills_2")
	self.evasionLoss = -self:GetCaster():FindTalentValue("special_bonus_unique_bristleback_quills_2")
	self.talent3 = self:GetCaster():HasTalent("special_bonus_unique_bristleback_quills_3")
	self.talent_radius = self:GetCaster():FindTalentValue("special_bonus_unique_bristleback_quills_3")
	self.minion_radius = self:GetCaster():FindTalentValue("special_bonus_unique_bristleback_quills_3", "minion_radius")
	self.minion_dmg = self:GetCaster():FindTalentValue("special_bonus_unique_bristleback_quills_3", "minion_dmg")
	if IsServer() then
		self:SetStackCount( self:GetStackCount() + 1 )
	end
end

function modifier_quills_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_EVENT_ON_DEATH }
end

function modifier_quills_debuff:GetModifierEvasion_Constant()
	if self.talent2 then
		return self.evasionLoss * self:GetStackCount()
	end
end

function modifier_quills_debuff:OnDeath(params)
	if params.unit == self:GetParent() and self.talent3 then
		local caster = self:GetCaster()
		local damage = TernaryOperator( self.minion_dmg, params.unit:IsMinion(), 100 )
		local radius = TernaryOperator( self.minion_radius, params.unit:IsMinion(), self.talent_radius )
		self:GetAbility():Spray( damage, radius, params.unit )
		local snot = self:GetCaster():FindAbilityByName("bristleback_snot")
		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius)
		for _,enemy in pairs(enemies) do
			snot:FireSnot(enemy, params.unit)
		end
	end
end