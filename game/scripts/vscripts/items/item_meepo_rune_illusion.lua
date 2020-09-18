item_meepo_rune_illusion = class({})

function item_meepo_rune_illusion:OnSpellStart()
	local caster = self:GetCaster()

	if caster:IsAlive() then
		EmitSoundOn("Rune.Illusion", caster)
		
		local duration = self:GetSpecialValueFor("duration")
		local max_images = self:GetSpecialValueFor("max_images")
		local incoming = self:GetSpecialValueFor("incoming")
		local outgoing = self:GetSpecialValueFor("outgoing")
		local illusionTable = caster:ConjureImage( {outgoing_damage = outgoing, incoming = inDmg}, duration, caster, max_images )
		
		self:Destroy()
	end
end