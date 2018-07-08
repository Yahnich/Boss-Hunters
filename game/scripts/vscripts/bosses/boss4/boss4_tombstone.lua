boss4_tombstone = class({})

function boss4_tombstone:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local tombstone = CreateUnitByName("npc_dota_boss4_tomb", position, true, caster, caster, caster:GetTeamNumber())
	tombstone:AddNewModifier(caster, self, "modifier_boss4_tombstone_tomb", {})
	tombstone.hasBeenInitialized = true
	tombstone:StartGesture(ACT_DOTA_SPAWN)
	caster:AddNewModifier(tombstone, self, "modifier_boss4_tombstone_caster", {})
	
	ParticleManager:FireParticle("particles/units/heroes/hero_undying/undying_tombstone.vpcf", PATTACH_ABSORIGIN, tombstone)
	EmitSoundOn("Hero_Undying.Tombstone", tombstone)
end

modifier_boss4_tombstone_caster = class({})
LinkLuaModifier("modifier_boss4_tombstone_caster", "bosses/boss4/boss4_tombstone.lua", 0)

function modifier_boss4_tombstone_caster:OnCreated()
	self.reduction = self:GetSpecialValueFor("damage_reduction")
	if IsServer() then
		FX = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_life_drain_beam.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControlEnt(FX, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(FX, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		self:AddEffect(FX)
	end
end

function modifier_boss4_tombstone_caster:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_boss4_tombstone_caster:GetModifierIncomingDamage_Percentage()
	return self.reduction
end


modifier_boss4_tombstone_tomb = class({})
LinkLuaModifier("modifier_boss4_tombstone_tomb", "bosses/boss4/boss4_tombstone.lua", 0)


function modifier_boss4_tombstone_tomb:OnCreated()
	self.breakDist = self:GetSpecialValueFor("break_distance")
	if IsServer() then self:StartIntervalThink(0) end
end
	

function modifier_boss4_tombstone_tomb:OnIntervalThink()
	if not self:GetCaster():IsAlive() or CalculateDistance(self:GetCaster(), self:GetParent()) > self.breakDist then 
		self:GetParent():StartGesture(ACT_DOTA_DIE)
		self:GetParent():Kill(self:GetAbility(), self:GetParent()) 
	end
end
	
function modifier_boss4_tombstone_tomb:OnRemoved()
	if IsServer() then
		self:GetCaster():RemoveModifierByName("modifier_boss4_tombstone_caster")
	end
end


function modifier_boss4_tombstone_tomb:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_DISABLE_HEALING}
end

function modifier_boss4_tombstone_tomb:GetModifierIncomingDamage_Percentage(params)
	local parent = self:GetParent()
	if not params.attacker:IsSameTeam(parent) then params.attacker:ModifyThreat( 100 / parent:GetMaxHealth() ) end
	if params.inflictor then
		return -999
	else
		local hp = parent:GetHealth()
		local damage = 4
		if not params.attacker:IsRealHero() then damage = 1 end
		if damage < hp and params.inflictor ~= self:GetAbility() then
			parent:SetHealth( hp - damage )
			return -999
		elseif hp <= 1 then
			self:GetParent():StartGesture(ACT_DOTA_DIE)
			parent:Kill(params.inflictor, params.attacker)
		end
	end
end

function modifier_boss4_tombstone_tomb:GetDisableHealing()
	return 1
end