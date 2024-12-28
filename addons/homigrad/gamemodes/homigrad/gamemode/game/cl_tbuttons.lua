-- cl_tbuttons.lua

-- Добавляем файл для загрузки на клиент
print("Кнопочки загружены!")

--- Display of and interaction with ttt_traitor_button
local surface = surface
local pairs = pairs
local math = math
local abs = math.abs

TBHUD = {}
TBHUD.buttons = {}
TBHUD.buttons_count = 0

TBHUD.focus_ent = nil
TBHUD.focus_stick = 0

-- Кэширование кнопок
function TBHUD:CacheEnts()
    if IsValid(LocalPlayer()) then
        self.buttons = {}
        local ents_found = ents.FindByClass("ttt_traitor_button")
        for _, ent in ipairs(ents_found) do
            if IsValid(ent) then
                self.buttons[ent:EntIndex()] = ent
            end
        end
    else
        self.buttons = {}
    end

    self.buttons_count = table.Count(self.buttons)
end

-- Проверка, находится ли игрок в фокусе на сущности
function TBHUD:PlayerIsFocused()
    return IsValid(LocalPlayer()) and IsValid(self.focus_ent)
end

-- Использование сфокусированной кнопки
function TBHUD:UseFocused()
   if IsValid(self.focus_ent) and self.focus_stick >= CurTime() then
       local plypos = LocalPlayer():GetPos()
       local entpos = self.focus_ent:GetPos()
       if plypos:Distance(entpos) <= self.focus_ent:GetUsableRange() then
           RunConsoleCommand("ttt_use_tbutton", tostring(self.focus_ent:EntIndex()))
           self.focus_ent = nil
           return true
       end
   end
   return false
end


-- Обработка сетевого сообщения подтверждения использования кнопки
local confirm_sound = Sound("buttons/button24.wav")
function TBHUD.ReceiveUseConfirm()
    surface.PlaySound(confirm_sound)
    TBHUD:CacheEnts()
end
net.Receive("TTT_ConfirmUseTButton", TBHUD.ReceiveUseConfirm)

-- Функция для вычисления фактора расстояния (при необходимости)
local function ComputeRangeFactor(plypos, tgtpos)
    local d = tgtpos - plypos
    d = d:Dot(d)
    return d / range
end

-- Загрузка текстур
local tbut_normal = surface.GetTextureID("vgui/ttt/tbut_hand_line")
local tbut_focus = surface.GetTextureID("vgui/ttt/tbut_hand_filled")
local size = 32
local mid  = size / 2
local focus_range = 25

-- Получение клавиши использования
local use_key = input.LookupBinding("+use") or "E"
-- Переводы (если используются)
--local GetTranslation = LANG.GetTranslation
--local GetPTranslation = LANG.GetParamTranslation
-- Отрисовка HUD
function TBHUD:Draw(client)
    RoundActiveName = tostring(roundActiveName)
    if RoundActiveName ~= "homicide" then
        return 
    end
    if not ply.roleT then
        return
    end
    if self.buttons_count ~= 0 then
        surface.SetTexture(tbut_normal)

        local plypos = client:GetPos()
        local midscreen_x = ScrW() / 2
        local midscreen_y = ScrH() / 2
        local pos, scrpos, d
        local focus_ent = nil
        local focus_d, focus_scrpos_x, focus_scrpos_y = 0, midscreen_x, midscreen_y

        for k, but in pairs(self.buttons) do
            if IsValid(but) then
                pos = but:GetPos()
                scrpos = pos:ToScreen()

                if but:IsUsable() then
                    d = pos - plypos
                    d = d:Dot(d) / (but:GetUsableRange() ^ 2)
                    if d < 1 then
                        surface.SetDrawColor(255, 255, 255, 200 * (1 - d))
                        surface.DrawTexturedRect(scrpos.x - mid, scrpos.y - mid, size, size)

                        if d > focus_d then
                            local x = abs(scrpos.x - midscreen_x)
                            local y = abs(scrpos.y - midscreen_y)
                            if (x < focus_range and y < focus_range and
                                x < focus_scrpos_x and y < focus_scrpos_y) then

                                if self.focus_stick < CurTime() or but == self.focus_ent then
                                    focus_ent = but
                                end
                            end
                        end
                    end
                end
            end

            -- Рисуем дополнительные элементы для сфокусированной кнопки
            if IsValid(focus_ent) then
                self.focus_ent = focus_ent
                self.focus_stick = CurTime() + 0.2  -- Увеличьте время задержки при необходимости

                local scrpos = focus_ent:GetPos():ToScreen()

                local sz = 16

                -- Перерисовываем иконку в фокусе
                surface.SetTexture(tbut_focus)
                surface.SetDrawColor(255, 255, 255, 200)
                surface.DrawTexturedRect(scrpos.x - mid, scrpos.y - mid, size, size)

                -- Описание
                surface.SetTextColor(255, 0, 0)
                surface.SetFont("TabLarge")

                local x = scrpos.x + sz + 10
                local y = scrpos.y - sz - 3
                surface.SetTextPos(x, y)
                surface.DrawText(focus_ent:GetDescription())

                y = y + 12
                surface.SetTextPos(x, y)
                if focus_ent:GetDelay() < 0 then
                    surface.DrawText("Одноразовая")
                elseif focus_ent:GetDelay() == 0 then
                    surface.DrawText("Reuse")
                else
                    surface.DrawText("Повторное использование")
                end

                y = y + 12
                surface.SetTextPos(x, y)
                surface.DrawText("Жмякай 'E' для активации")
            end
        end
    else
        -- Если кнопок нет, можно вывести сообщение
    end
end

-- Регистрация хуков
hook.Add("HUDPaint", "TBHUD_DrawHUD", function()
    if IsValid(LocalPlayer()) then
        TBHUD:Draw(LocalPlayer())
    end
end)

hook.Add("InitPostEntity", "TBHUD_InitCache", function()
    TBHUD:CacheEnts()
end)

timer.Create("TBHUD_CacheTimer", 5, 0, function()
    if IsValid(LocalPlayer()) then
        TBHUD:CacheEnts()
    end
end)

-- Обработчик нажатия клавиши E
hook.Add("Think", "TBHUD_KeyPress", function()
    if ply:KeyDown(IN_USE) then
        TBHUD:UseFocused()
    end
end)
