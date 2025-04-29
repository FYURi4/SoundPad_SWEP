if SERVER then
    AddCSLuaFile()
end

SWEP.Base = "weapon_base"

SWEP.Type = "anim"
SWEP.Category = "3DEMC_SWEP"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ClassName = "X"
SWEP.PrintName = "X"
SWEP.Author = "FURA"
SWEP.Contact = "Discord: fyurl4, Furushka: FurichF"
SWEP.Instructions = "R - Open Menu. ЛКМ - Play"

SWEP.ViewModel = "" 
SWEP.WorldModel = "" 
SWEP.ViewModelFOV = 0 
SWEP.UseHands = false  

SWEP.Primary.ClipSize = -1 
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.SoundList = {
    "путь к звуку "
}

function SWEP:Initialize()
    self:SetHoldType("normal")
    self.SoundMenuOpen = false
    self.CurrentSoundIndex = nil
    self.CurrentSoundPath = nil
end

function SWEP:SecondaryAttack()
    return false
end

function SWEP:Reload()
    if CLIENT then
        self:OpenSoundMenu()
    end
    return false
end

function SWEP:Think()
    if CLIENT then
        local owner = self:GetOwner()
        if IsValid(owner) and owner:KeyPressed(IN_RELOAD) then
            self:OpenSoundMenu()
        end
    end
end

function SWEP:OpenSoundMenu()
    if not CLIENT then return end
    if self.SoundMenuOpen then return end
    self.SoundMenuOpen = true
    
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Выберите звук")
    frame:SetSize(350, 500)
    frame:Center()
    frame:MakePopup()
    
    frame.OnClose = function()
        self.SoundMenuOpen = false
    end
    
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    
    for index, path in ipairs(self.SoundList) do
        local btn = vgui.Create("DButton", scroll)
        btn:Dock(TOP)
        btn:DockMargin(5, 5, 5, 0)
        btn:SetText(path:match("([^/]+)%.%w+$") or path)
        btn.DoClick = function()
            self.CurrentSoundIndex = index
            self.CurrentSoundPath = path 
            frame:Close()
            
            net.Start("MellstroySWEP_SelectSound")
                net.WriteUInt(index, 8)
            net.SendToServer()
        end
    end
end

if SERVER then
    util.AddNetworkString("MellstroySWEP_SelectSound")
    
    net.Receive("MellstroySWEP_SelectSound", function(len, ply)
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "mellstroy_sweep" then
            local index = net.ReadUInt(8)
            wep.CurrentSoundIndex = index
            wep.CurrentSoundPath = wep.SoundList[index]
        end
    end)
end

function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end
    
    if self.CurrentSoundPath then

        local pitch = math.random(40, 170)
        
        if SERVER then
            self:EmitSound(self.CurrentSoundPath, 75, pitch, 1)
        else
            self:EmitSound(self.CurrentSoundPath, 75, pitch, 1)
        end
        
        self:SetNextPrimaryFire(CurTime() + 0.5)
    else
        if CLIENT then
            notification.AddLegacy("Выберите звук в меню (R)", NOTIFY_HINT, 2)
        end
    end
end

if CLIENT then
    function SWEP:DrawHUD()
        local soundName = self.CurrentSoundPath and self.CurrentSoundPath:match("([^/]+)%.%w+$") or "Не выбран"
        draw.SimpleText("Выбран: "..soundName, "DermaDefaultBold", ScrW()/2, ScrH()-100, Color(255,255,255), TEXT_ALIGN_CENTER)
        draw.SimpleText("ЛКМ - играть выбранный звук | R - меню", "DermaDefault", ScrW()/2, ScrH()-80, Color(200,200,200), TEXT_ALIGN_CENTER)
    end
end
