bristleback_quills = class({})
LinkLuaModifier( "modifier_quills", "heroes/hero_bristleback/bristleback_quills.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_quills_buff", "heroes/hero_bristleback/bristleback_quills.lua",LUA_MODIFIER_MOTION_NONE )

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
	local cd = self.BaseClass.GetCooldown( self, iLvl )
	if self:GetCaster():HasModifier("modifier_quills_buff") then
		cd = cd - self:GetTalentSpecialValueFor("cdr_per_stack") * self:GetCaster():GetModifierStackCount( "modifier_quills_buff", self:GetCaster() )
	end
	return cd
end

function bristleback_quills:OnSpellStart()
	self:Spray()
end

function bristleback_quills:Spray(bProc, buttonPress)
	local caster = self:GetCaster()
	
	EmitSoundOn("Hero_Bristleback.QuillSpray.Cast", self:GetCaster())
	ParticleManager:FireParticle("particles/units/heroes/hero_bristleback/bristleback_quill_spray.vpcf", PATTACH_POINT, caster)
	
	local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetCaster():GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
	for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb( self ) then
			EmitSoundOn("Hero_Bristleback.QuillSpray.Target", enemy)
			local damage = self:GetTalentSpecialValueFor("quill_base_damage")
			self:DealDamage(caster, enemy, damage)
		end
	end
	caster:AddNewModifier(caster, self, "modifier_quills_buff", {duration = self:GetTalentSpecialValueFor("quill_stack_duration")})
end

modifier_quills = class({})

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
		if ability:GetAutoCastState() and caster:IsAlive() and ability:IsFullyCastable() and ability:IsOwnersManaEnough() and not caster:HasActiveAbility() then
			ability:CastSpell()
		elseif not ability:IsOwnersManaEnough() and ability:GetAutoCastState() then
			ability:ToggleAutoCast()
		end
	end
end

function modifier_quills:IsHidden() return true end

modifier_quills_buff = class({})

if IsServer() then
	function modifier_quills_buff:OnCreated(kv)
		self:SetStackCount(1)
	end
	
	function modifier_quills_buff:OnRefresh(kv)
		self:SetStackCount( math.min( self:GetStackCount() + 1, self:GetTalentSpecialValueFor("quill_max_stacks") ) )
	end
end