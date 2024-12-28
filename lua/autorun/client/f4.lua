if CLIENT then

    local frame
    local isMenuOpen = false -- Переменная для отслеживания состояния меню
    local keyPressed = false -- Переменная для отслеживания состояния нажатия клавиши

    local function OpenF4Menu()
        if isMenuOpen then
            return -- Если меню уже открыто, просто возвращаемся
        end

        -- Создаем новое окно меню
        frame = vgui.Create("DFrame")
        frame:SetTitle("F4")
        frame:SetSize(600, 400)
        frame:Center()
        frame:MakePopup()
        frame.Paint = function()
            draw.RoundedBox( 8, 0, 0, frame:GetWide(), frame:GetTall(), Color( 24, 24, 24) )
        end
        local sheet = vgui.Create("DPropertySheet", frame)
        sheet:Dock(FILL)

        -- Первая вкладка с деревом режимов
        local treePanel = vgui.Create("DPanel", sheet)
        treePanel:SetBackgroundColor(Color(31, 30, 30))

        local tree = vgui.Create("DTree", treePanel)
        tree:SetBackgroundColor(Color(31, 31, 31))
        tree:Dock(LEFT)
        tree:SetWidth(200)
        tree:SetShowIcons(true) -- Включаем иконки (или отключаем, если не нужны)
        
        -- Путь к иконкам
        local iconPath = "materials/icon72/"
        
        -- Создание узлов с кастомными иконками
        local function AddNodeWithIcon(tree, nodeName, iconFileName)
            local node = tree:AddNode(nodeName)
            node:SetIcon(iconPath .. iconFileName)
            return node
        end
        -- Создаем панель, которая будет отображаться справа
        local rightPanel = vgui.Create("DPanel", treePanel)
        rightPanel:Dock(FILL)
        rightPanel:SetBackgroundColor(Color(41, 41, 41))
        rightPanel:SetVisible(false) -- Изначально скрываем правую панель

        -- Создаем узлы дерева и добавляем элементы
        local groupNode = AddNodeWithIcon(tree, "Командный бой", "anger.png")
        local innerFolder = AddNodeWithIcon(groupNode, "Захват точек", "flag.png")
        AddNodeWithIcon(innerFolder, "cp", "flag.png")
        AddNodeWithIcon(innerFolder, "css", "css_icon.png")
        AddNodeWithIcon(innerFolder, "bahmut", "bahmut_icon.png")
        AddNodeWithIcon(innerFolder, "ww2", "ww2.png")
        AddNodeWithIcon(innerFolder, "starwarsclonewars", "star2.png")
        AddNodeWithIcon(innerFolder, "starwarsgalacticcw", "star2.png")
        AddNodeWithIcon(groupNode, "tdm", "anger.png")
        AddNodeWithIcon(groupNode, "hl2dm", "hl2dm_icon.png")
        AddNodeWithIcon(groupNode, "riot", "riot_icon.png")
        AddNodeWithIcon(groupNode, "slovopacana", "slovopacana_icon.png")
        AddNodeWithIcon(groupNode, "bodycam", "camera.png")
        AddNodeWithIcon(groupNode, "scout", "airplane.png")

        local dmFolder = AddNodeWithIcon(tree, "Каждый сам за себя", "gun.png")
        AddNodeWithIcon(dmFolder, "dm", "gun.png")
        AddNodeWithIcon(dmFolder, "igib", "bomb.png")
        AddNodeWithIcon(tree, "wick", "assassins.png")
        AddNodeWithIcon(tree, "kingkong", "speak_no_evil.png")
        AddNodeWithIcon(tree, "hideandseek", "rat.png")
        AddNodeWithIcon(tree, "homicide", "homicide.png")
        AddNodeWithIcon(tree, "jailbreak", "jail.png")
        AddNodeWithIcon(tree, "deathrun", "deathrun.png")
        AddNodeWithIcon(tree, "zombo", "zombiesurvival.png")
        AddNodeWithIcon(tree, "nextbot", "hankey.png")
        AddNodeWithIcon(tree, "construct", "sandbox.png")

        tree:LayoutTree() -- Обновляем макет

        -- Переменная для хранения имени выбранного режима
        local selectedMode = ""

        -- Обработка выбора узла
        function tree:OnNodeSelected(node)
            local isFolder = node:GetChildNode(0) ~= nil
            if isFolder then
                rightPanel:SetVisible(false) -- Это папка, скрываем правую панель
            else
                selectedMode = node:GetText()
                rightPanel:SetVisible(true)
                rightPanel:Clear() -- Очистить предыдущий контент

                local description = vgui.Create("DLabel", rightPanel)
                description:SetText("")
                description:SetTextColor(Color(0, 0, 0))
                description:SetFont("DermaDefault")
                description:SetWrap(true)
                description:SetAutoStretchVertical(true)
                description:SetContentAlignment(7) -- Выравнивание по центру
                description:Dock(TOP)
                description:DockMargin(10, 10, 10, 10)

                -- Устанавливаем текст в зависимости от выбранного режима
                if selectedMode == "tdm" then
                    description:SetText("TeamDeathMatch Красная команда против Синей.")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "bahmut" then
                    description:SetText("TDM, но ЧВК Вагнер против НАТО.")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "cp" then
                    description:SetText("TDM Режим с захватом точек и респавнами")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "css" then
                    description:SetText("TDM Режим Контр-Террористы против Террористов с CSS модельками и возможностью захвата точек.")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "dm" then
                    description:SetText("DeathMatch Каждый сам за себя.")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "hl2dm" then
                    description:SetText("TDM режим Комбайны против Повстанцев из Half-Life 2.")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "igib" then
                    description:SetText("DM режим с респавнами, где у каждого гранатомёт.")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "riot" then
                    description:SetText("TDM режим Бунтующие против Полиции. Целью Полиции является АРРЕСТ бунтующих.")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "slovopacana" then
                    description:SetText("TDM режим Октябрьские против Шаровары. Бьёмся до первой крови.")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "wick" then
                    description:SetText("Один человек Джон Уик. Остальные должны его устранить.")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "hideandseek" then
                    description:SetText("Режим прятки, где на 4 прячущихся приходится 1 искатель. Через время, если искатели не убили всех прячущихся приезжает спецназ.")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "starwarsclonewars" then
                    description:SetText("Звездные войны, войны клонов")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "starwarsgalacticcw" then
                    description:SetText("Империя против повстанцев")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "deathrun" then
                    description:SetText("В разработке")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "jailbreak" then
                    description:SetText("Побег из тюрьмы, в стиле КС1.6")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "homicide" then
                    description:SetText("Homicide - основной режим предатель против невиновных.")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "zombo" then
                    description:SetText("Зондбе вирус")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "ww2" then
                    description:SetText("Сражение Вермахта против Красной армии в ВОВ")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "bodycam" then
                    description:SetText("ТДМ, с видом от нагрудной камеры.")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "nextbot" then
                    description:SetText("Побег от некстботов(пока только ебака из бекрумсов)")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "construct" then
                    description:SetText("Строительство, с доступом к пропам")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "kingkong" then
                    description:SetText("режим Кинг Конг, в котором есть люди с оружием и их задача уничтожить обезьяну, и не дать спизидить бананы. Обезьяна обрела силу от радиоактивных бананов. Она имеет большую силу удара, скорость и высоту прыжка. Также он видит игроков через стены, когда они близко к нему.")
                    description:SetTextColor(Color(255, 255, 255))
                elseif selectedMode == "scout" then
                    description:SetText("Перелётные снайперы из кски.")
                    description:SetTextColor(Color(255, 255, 255))
                else
                    description:SetText("Selected mode: " .. selectedMode)
                    description:SetTextColor(Color(255, 255, 255))
                end
                

                -- Создаем панель для кнопок
                local buttonPanel = vgui.Create("DPanel", rightPanel)
                buttonPanel:Dock(TOP)
                buttonPanel:SetTall(40)
                buttonPanel:SetBackgroundColor(Color(32, 32, 32))
                buttonPanel:DockMargin(10, 10, 10, 10)

                -- Создаем кнопку "Сменить режим"
                local changeModeButton = vgui.Create("DButton", buttonPanel)
                changeModeButton:SetText("Сменить режим")
                changeModeButton:SetSize(170, 25)
                changeModeButton:Dock(LEFT)
                changeModeButton:DockMargin(0, 0, 5, 0)

                changeModeButton.DoClick = function()
                    if selectedMode ~= "" then
                        RunConsoleCommand("set_next_mode", selectedMode)
                    else
                        LocalPlayer():ChatPrint("Выберите режим для смены.")
                    end
                end

                -- Создаем кнопку "Голосование"
                local voteButton = vgui.Create("DButton", buttonPanel)
                voteButton:SetText("Голосование")
                voteButton:SetSize(170, 25)
                voteButton:Dock(LEFT)
                voteButton:DockMargin(0, 0, 5, 0)

                voteButton.DoClick = function()
                    if selectedMode ~= "" then
                        RunConsoleCommand("vote_next_mode", selectedMode)
                    else
                        LocalPlayer():ChatPrint("Выберите режим для голосования.")
                    end
                end

                -- Создаем панель для кнопки "Закончить уровень" и добавляем её в основной контейнер
                local endLevelPanel = vgui.Create("DPanel", rightPanel)
                endLevelPanel:Dock(BOTTOM)
                endLevelPanel:SetTall(40)
                endLevelPanel:SetBackgroundColor(Color(31, 31, 31))
                endLevelPanel:DockMargin(10, 10, 10, 10)

                -- Создаем кнопку "Закончить уровень"
                local endLevelButton = vgui.Create("DButton", endLevelPanel)
                endLevelButton:SetText("Закончить раунд")
                endLevelButton:SetSize(170, 25)
                endLevelButton:Dock(FILL)
                endLevelButton:DockMargin(0, 0, 5, 0)

                endLevelButton.DoClick = function()
                    RunConsoleCommand("say", "!levelend")
                end

                -- Обновляем макет панели
                rightPanel:InvalidateLayout(true)

            end
        end

        -- Добавляем панель дерева в первую вкладку
        sheet:AddSheet("Режимы", treePanel, "icon16/application_view_list.png")



local adminPanel = vgui.Create("DPanel", sheet)
adminPanel:SetBackgroundColor(Color(240, 240, 240))

local adminLabel = vgui.Create("DLabel", adminPanel)
adminLabel:SetTextColor(Color(0, 0, 0))
adminLabel:SetFont("DermaDefaultBold")
adminLabel:SetText("Это админское меню. Только для администраторов.")
adminLabel:Dock(TOP)
adminLabel:DockMargin(10, 10, 10, 10)

-- Проверка, является ли игрок администратором
if LocalPlayer():IsAdmin() then
    adminLabel:SetText("Добро пожаловать в админское меню.")

    local scrollPanel = vgui.Create("DScrollPanel", adminPanel)
    scrollPanel:Dock(FILL)
    scrollPanel:DockMargin(10, 10, 10, 10)

    local mainPanel = vgui.Create("DPanel", scrollPanel)
    mainPanel:Dock(FILL)
    mainPanel:SetBackgroundColor(Color(240, 240, 240))
    mainPanel:SetTall(600) -- Устанавливаем высоту панели, чтобы все элементы отображались

    -- Панель для обычных кнопок
    local normalButtonPanel = vgui.Create("DPanel", mainPanel)
    normalButtonPanel:Dock(TOP)
    normalButtonPanel:SetBackgroundColor(Color(240, 240, 240))
    normalButtonPanel:SetTall(200) -- Устанавливаем высоту панели для обычных кнопок

    local normalButtonsLabel = vgui.Create("DLabel", normalButtonPanel)
    normalButtonsLabel:SetTextColor(Color(0, 0, 0))
    normalButtonsLabel:SetText("Обычные кнопки")
    normalButtonsLabel:SetFont("DermaDefaultBold")
    normalButtonsLabel:Dock(TOP)
    normalButtonsLabel:DockMargin(10, 10, 10, 5)

    local normalButtonGrid = vgui.Create("DIconLayout", normalButtonPanel)
    normalButtonGrid:Dock(TOP)
    normalButtonGrid:SetSpaceY(5)
    normalButtonGrid:SetSpaceX(5)

    -- Функция для добавления обычной кнопки
    local function addAdminButton(panel, label, command, withInput)
        local buttonPanel = vgui.Create("DPanel", panel)
        buttonPanel:SetSize(200, 30)
        buttonPanel:SetBackgroundColor(Color(240, 240, 240))

        local button = vgui.Create("DButton", buttonPanel)
        button:SetText(label)
        button:SetSize(100, 25)
        button:Dock(LEFT)
        button:DockMargin(0, 0, 5, 0)

        if withInput then
            button.DoClick = function()
                local arg = inputField:GetText()
                if arg ~= "" then
                    RunConsoleCommand(command, arg)
                else
                    LocalPlayer():ChatPrint("Введите аргумент для команды.")
                end
            end
        else
            button.DoClick = function()
                -- Отправляем команду в чат
                RunConsoleCommand("say", command)
            end
        end
    end

    -- Добавление обычных кнопок
    addAdminButton(normalButtonGrid, "Разрешить Q меню", "accessspawn", false)
    addAdminButton(normalButtonGrid, "Рандом режимы", "levelrandom", false)
    addAdminButton(normalButtonGrid, "Закончить раунд", "levelend", false)
    addAdminButton(normalButtonGrid, "Кик при смерти", "sync", false)
    addAdminButton(normalButtonGrid, "Закрыть сервер", "closedev", false)

    -- Переменная для отслеживания состояния RTV
    local nortvState = false

    -- Добавление кнопки для переключения !nortv
    local function toggleNortv()
        nortvState = not nortvState
        local command = "!nortv " .. (nortvState and "1" or "0")
        RunConsoleCommand("say", command)
    end

    -- Добавление кнопки для вызова RTV
    addAdminButton(normalButtonGrid, "Вызвать RTV", "!forcertv", false)

    -- Панель для кнопок с вводом
    local inputPanel = vgui.Create("DPanel", mainPanel)
    inputPanel:Dock(TOP)
    inputPanel:SetBackgroundColor(Color(240, 240, 240))
    inputPanel:SetTall(200) -- Устанавливаем высоту панели для кнопок с вводом

    local inputLabel = vgui.Create("DLabel", inputPanel)
    inputLabel:SetTextColor(Color(0, 0, 0))
    inputLabel:SetText("Кнопки с вводом")
    inputLabel:SetFont("DermaDefaultBold")
    inputLabel:Dock(TOP)
    inputLabel:DockMargin(10, 10, 10, 5)

    local inputField = vgui.Create("DTextEntry", inputPanel)
    inputField:Dock(TOP)
    inputField:SetTall(25)
    inputField:DockMargin(0, 0, 0, 5)

    local inputButtonGrid = vgui.Create("DIconLayout", inputPanel)
    inputButtonGrid:Dock(TOP)
    inputButtonGrid:SetSpaceY(5)
    inputButtonGrid:SetSpaceX(5)

    -- Добавление кнопок с полями ввода
    addAdminButton(inputButtonGrid, "Заразить", "virus", true)
    addAdminButton(inputButtonGrid, "Макс игроки", "setmaxplayers", true)

    
    local Teamlabel = vgui.Create("DLabel", inputPanel)
    Teamlabel:SetTextColor(Color(0, 0, 0))
    Teamlabel:SetText("Смена команды")
    Teamlabel:SetFont("DermaDefaultBold")
    Teamlabel:Dock(TOP)
    -- Панель для команды TeamForce
    local teamForcePanel = vgui.Create("DPanel", inputPanel)
    teamForcePanel:DockMargin(0, 0, 0, 0)
    teamForcePanel:Dock(TOP)

    teamForcePanel:SetBackgroundColor(Color(240, 240, 240))
    teamForcePanel:SetTall(210) -- Высота панели для команды TeamForce

    local teamForceLayout = vgui.Create("DIconLayout", teamForcePanel)
    teamForceLayout:Dock(TOP)
    teamForceLayout:SetSpaceY(5)
    teamForceLayout:SetSpaceX(5)

    local function addTeamForceButton(panel, label, team)
        local buttonPanel = vgui.Create("DPanel", panel)
        buttonPanel:SetSize(30, 20)
        buttonPanel:SetBackgroundColor(Color(240, 240, 240))

        local button = vgui.Create("DButton", buttonPanel)
        button:SetText(label)
        button:SetSize(30, 20)
        button:Dock(FILL)

        button.DoClick = function()
            local playerName = inputField:GetText()
            if playerName ~= "" then
                local command = "!teamforce " .. playerName .. " " .. team
                RunConsoleCommand("say", command)
            else
                LocalPlayer():ChatPrint("Введите ник игрока.")
            end
        end
    end

    -- Кнопки для выбора команды
    addTeamForceButton(teamForceLayout, "T", "1")
    addTeamForceButton(teamForceLayout, "CT", "2")
    addTeamForceButton(teamForceLayout, "Spec", "3")

    -- Добавление кнопки для переключения состояния !nortv
    local toggleNortvButton = vgui.Create("DButton", normalButtonPanel)
    toggleNortvButton:SetText("NoRTV")
    toggleNortvButton:SetSize(30, 30)
    toggleNortvButton:SetWide(100)
    toggleNortvButton:Dock(TOP)
    toggleNortvButton:DockMargin(10, 10, 10, 5)

    toggleNortvButton.DoClick = toggleNortv

else
    adminLabel:SetText("Только для админов")
end

sheet:AddSheet("Админ меню", adminPanel, "icon16/shield.png")

-- Вкладка настроек
local settingsPanel = vgui.Create("DPanel", sheet)
settingsPanel:SetBackgroundColor(Color(32, 32, 32))

local settingsLabel = vgui.Create("DLabel", settingsPanel)
settingsLabel:SetTextColor(Color(255, 255, 255))
settingsLabel:SetFont("DermaDefaultBold")
settingsLabel:SetText("Настройки")
settingsLabel:Dock(TOP)
settingsLabel:DockMargin(10, 10, 10, 10)

local settingsContent = vgui.Create("DPanel", settingsPanel)
settingsContent:Dock(FILL)
settingsContent:SetBackgroundColor(Color(32, 32, 32))
settingsContent:DockMargin(10, 10, 10, 10)

-- Раздел для настроек звука
local soundSettingsLabel = vgui.Create("DLabel", settingsContent)
soundSettingsLabel:SetText("Эхо от выстрелов                                                                                                                            FOV")
soundSettingsLabel:SetTextColor(Color(255, 255, 255))
soundSettingsLabel:SetFont("DermaDefaultBold")
soundSettingsLabel:Dock(TOP)
soundSettingsLabel:DockMargin(0, 0, 0, 10)

local soundButtonPanel = vgui.Create("DPanel", settingsContent)
soundButtonPanel:Dock(TOP)
soundButtonPanel:SetBackgroundColor(Color(32, 32, 32))
soundButtonPanel:SetTall(40)
soundButtonPanel:DockMargin(0, 0, 0, 10)

local enableButton = vgui.Create("DButton", soundButtonPanel)
enableButton:SetText("Вкл")
enableButton:SetSize(70, 30)
enableButton:Dock(LEFT)
enableButton:DockMargin(0, 0, 5, 0)

enableButton.DoClick = function()
    RunConsoleCommand("cl_dwr_volume", "100")
end

local disableButton = vgui.Create("DButton", soundButtonPanel)
disableButton:SetText("Выкл")
disableButton:SetSize(70, 30)
disableButton:Dock(LEFT)

disableButton.DoClick = function()
    RunConsoleCommand("cl_dwr_volume", "0")
end

local fov90Button = vgui.Create("DButton", soundButtonPanel)
fov90Button:SetText("90")
fov90Button:SetSize(70, 30)
fov90Button:Dock(RIGHT)
fov90Button:DockMargin(0, 0, 5, 0)

fov90Button.DoClick = function()
    RunConsoleCommand("hg_fov", "90")
end

local fov120Button = vgui.Create("DButton", soundButtonPanel)
fov120Button:SetText("120")
fov120Button:SetSize(70, 30)
fov120Button:Dock(RIGHT)
fov120Button:DockMargin(0, 0, 5, 0)

fov120Button.DoClick = function()
    RunConsoleCommand("hg_fov", "120")
end


-- Раздел для настроек анимации бега
local animationSettingsLabel = vgui.Create("DLabel", settingsContent)
animationSettingsLabel:SetText("Кастомная анимация бега")
animationSettingsLabel:SetTextColor(Color(255, 255, 255))
animationSettingsLabel:SetFont("DermaDefaultBold")
animationSettingsLabel:Dock(TOP)
animationSettingsLabel:DockMargin(0, 0, 0, 10)

local animationButtonPanel = vgui.Create("DPanel", settingsContent)
animationButtonPanel:Dock(TOP)
animationButtonPanel:SetBackgroundColor(Color(34, 34, 34))
animationButtonPanel:SetTall(40)
animationButtonPanel:DockMargin(0, 0, 0, 10)

local animationEnableButton = vgui.Create("DButton", animationButtonPanel)
animationEnableButton:SetText("Вкл")
animationEnableButton:SetSize(70, 30)
animationEnableButton:Dock(LEFT)
animationEnableButton:DockMargin(0, 0, 5, 0)

animationEnableButton.DoClick = function()
    RunConsoleCommand("alternate_sprint_anim", "1")
end

local animationDisableButton = vgui.Create("DButton", animationButtonPanel)
animationDisableButton:SetText("Выкл")
animationDisableButton:SetSize(70, 30)
animationDisableButton:Dock(LEFT)

animationDisableButton.DoClick = function()
    RunConsoleCommand("alternate_sprint_anim", "0")
end

-- Раздел для настроек анимации сидения
local crouchAnimationSettingsLabel = vgui.Create("DLabel", settingsContent)
crouchAnimationSettingsLabel:SetText("Кастомная анимация сидения")
crouchAnimationSettingsLabel:SetTextColor(Color(255, 255, 255))
crouchAnimationSettingsLabel:SetFont("DermaDefaultBold")
crouchAnimationSettingsLabel:Dock(TOP)
crouchAnimationSettingsLabel:DockMargin(0, 0, 0, 10)

local crouchAnimationButtonPanel = vgui.Create("DPanel", settingsContent)
crouchAnimationButtonPanel:Dock(TOP)
crouchAnimationButtonPanel:SetBackgroundColor(Color(32, 32, 32))
crouchAnimationButtonPanel:SetTall(40)
crouchAnimationButtonPanel:DockMargin(0, 0, 0, 10)

local crouchAnimationEnableButton = vgui.Create("DButton", crouchAnimationButtonPanel)
crouchAnimationEnableButton:SetText("Вкл")
crouchAnimationEnableButton:SetSize(70, 30)
crouchAnimationEnableButton:Dock(LEFT)
crouchAnimationEnableButton:DockMargin(0, 0, 5, 0)

crouchAnimationEnableButton.DoClick = function()
    RunConsoleCommand("alternate_crouch_anim", "1")
end

local crouchAnimationDisableButton = vgui.Create("DButton", crouchAnimationButtonPanel)
crouchAnimationDisableButton:SetText("Выкл")
crouchAnimationDisableButton:SetSize(70, 30)
crouchAnimationDisableButton:Dock(LEFT)

crouchAnimationDisableButton.DoClick = function()
    RunConsoleCommand("alternate_crouch_anim", "0")
end

sheet:AddSheet("Настройки", settingsPanel, "icon16/wrench_orange.png")



        isMenuOpen = true -- Устанавливаем состояние меню как открытое

        -- Закрываем меню при нажатии на окно
        frame.OnClose = function()
            isMenuOpen = false
        end
    end

    local function CloseF4Menu()
        if IsValid(frame) then
            frame:Close()
        end
    end

    hook.Add("OnPlayerChat", "OpenMenuOnChatCommand", function(ply, text)
        if ply == LocalPlayer() and (string.lower(text) == "!levels" or string.lower(text) == "!levelnext") then
            OpenF4Menu()
            return true
        end
    end)

    hook.Add("Think", "ToggleF4Menu", function()
        if input.IsKeyDown(KEY_F4) then
            if not keyPressed then
                if isMenuOpen then
                    CloseF4Menu()
                else
                    OpenF4Menu()
                end
                keyPressed = true -- Устанавливаем состояние нажатия клавиши
            end
        else
            keyPressed = false -- Сбрасываем состояние нажатия клавиши, когда клавиша отпущена
        end
    end)

end
