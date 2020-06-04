-------------------------------------------
script_name('Gold Tppls ')
script_author('Vespan & Fedosyuk')
script_version('4.5')
script_description('Упрощение админам Gold-RP | Команды / Клавишы')
-------------------------------------------

-- Библиотеки --
local cjson = require"cjson"
local sampev = require 'lib.samp.events'
local encoding = require 'encoding'
local imgui = require 'imgui'
local key = require 'vkeys'
local mem = require "memory"
local dlstatus = require('moonloader').download_status
local effil = require"effil"
local ffi = require "ffi"
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
require "lib.moonloader"
local inicfg = require 'inicfg'
local BulletSync = {lastId = 0, maxLines = 15}
for i = 1, BulletSync.maxLines do
    BulletSync[i] = {enable = false, o = {x, y, z}, t = {x, y, z}, time = 0, tType = 0}
end

-- авто обновление

-- ini конфиг --
if not doesDirectoryExist('moonloader/Admin Tools') then
    lua_thread.create(function()
    createDirectory('moonloader/Admin Tools')
    createDirectory('moonloader/Admin Tools/ChatLog')
    wait(1000)
end)
end
local Direct_Ini = "..\\Admin Tools\\Admin Tools[Gold-RP].ini"
local Load_Config = inicfg.load({
    info = {
        LastConnect=' ',
        CarColor=0
    },
    General = {
        LoginAdminPanel='1234',
        LoginAccount='qwerty123',
        Active=false
    },
    Recon = {
        Actived=true,
        ReconID=68,
        Y=475,
        X=315
    },
    InfoBar = {
        Y=465,
        X=850
    },
    Checker= {
        Actived=false,
        X=315,
        Y=475
    },
    Options = {
    	FastKey = false,
        Gm=false,
        WH=false,
        check=false,
        togphone=false,
        Sound=true,
        Message=false,
        Offgoto=false,
        WallHackSkeletalLine=false,
        ChatSms=false,
        CheckConnect=false,
        damageActived=true
    },
}, Direct_Ini)    

local AutoUpdateCheck = inicfg.load({
    Update = {
        Version = 4.5
    },
}, '..\\lib\\Update Check [Gold Tools].ini')

local ReportOtvet = inicfg.load({
	settings = {
		otvet1 = 'Слежу за нарушителем!',
		otvet2 = 'Начинаю работать по вашей жалобе!',
		otvet3 = 'Передам старшой администрации',
		otvet4 = 'Для вопросов есть раздел "Вопрос" для хелперов!'
	},
}, '..\\Admit Tools\\Report Otvet.ini')

local tag = '{00AAFF}[Admin Tools]: {FFFFFF}'

encoding.default = 'CP1251'
u8 = encoding.UTF8

-- imgui
local main_window_state = imgui.ImBool(false)
local rules_for_admins = imgui.ImBool(false)
local recon_infa_player = imgui.ImBool(false)
local recon = imgui.ImBool(false)
local Checker = imgui.ImBool(Load_Config.Checker.Actived)

-- Меню --
local TextBind = '0'
local active = 'false'
local page_id = 'home'
local redakt_zametki = '0'
local command_ = '0'
local settings_ = '0'

-- Прочее  --
local path = 'moonloader/Admin Tools/'
local traicers = false
local WallHackNameTag = false
local WallHackSkeletal = false
local btn_size = imgui.ImVec2(-1, 0)
local LogConnect_Text = {}
local ShowTextdraw = false
local ReconID = Load_Config.Recon.ReconID
local GetPosition = false
local speed_airbrk = 1.5
local Pped = PLAYER_PED
local font = renderCreateFont("arial", 8, 5)
local NoResize = imgui.WindowFlags.NoResize
local NoTitleBar = imgui.WindowFlags.NoTitleBar
local localPlayerInCar = true

-- строки --
local BinderWait       = imgui.ImBuffer('1000', 256)
local BinderLine       = imgui.ImBuffer('', 256)
local zametki          = imgui.ImBuffer('', 256)
local InfoBar_X        = imgui.ImInt(Load_Config.InfoBar.X)
local InfoBar_Y        = imgui.ImInt(Load_Config.InfoBar.Y) 
local Recon_X          = imgui.ImInt(Load_Config.Recon.X)
local Recon_Y          = imgui.ImInt(Load_Config.Recon.Y)
local Checker_X        = imgui.ImInt(Load_Config.Checker.X)
local Checker_Y        = imgui.ImInt(Load_Config.Checker.Y)
local CheckerAdd       = imgui.ImBuffer('', 256)
local pass_osnova      = imgui.ImBuffer('', 256)
local pass_admin_panel = imgui.ImBuffer('', 256)
local CarColor         = imgui.ImInt(Load_Config.info.CarColor)
local ReportOtvet1		= imgui.ImBuffer('', 256)
local ReportOtvet2		= imgui.ImBuffer('', 256)
local ReportOtvet3		= imgui.ImBuffer('', 256)
local ReportOtvet4		= imgui.ImBuffer('', 256)

-- combo

-- Кнопки
local ToggleButton_FastKey = imgui.ImBool(Load_Config.Options.FastKey)
local ToggleButton_Recon = imgui.ImBool(Load_Config.Recon.Actived)
local ToggleButton_CheckConnected = imgui.ImBool(Load_Config.Options.CheckConnect)
local ToggleButton_ChatSms = imgui.ImBool(Load_Config.Options.ChatSms)
local ToggleButton_AutoLogin = imgui.ImBool(Load_Config.General.Active)
local ToggleButton_speedometer = imgui.ImBool(Load_Config.Speedometer.Active)
local ToggleButton_PushMessage = imgui.ImBool(Load_Config.Options.Message)
local ToggleButton_infoBar = imgui.ImBool(false)
local ToggleButton_togphone = imgui.ImBool(Load_Config.Options.togphone)
local ToggleButton_Wh = imgui.ImBool(Load_Config.Options.WH)
local ToggleButton_Gm = imgui.ImBool(Load_Config.Options.Gm)
local ToggleButton_offgoto = imgui.ImBool(Load_Config.Options.Offgoto)
local ToggleButton_Sound = imgui.ImBool(Load_Config.Options.Sound)
local ToggleButton_Checker = imgui.ImBool(Load_Config.Checker.Actived)
local ToggleButton_WHLine = imgui.ImBool(Load_Config.Options.WallHackSkeletalLine)

-- text --
local rules_helperam = [[
В /rep вы обязаны отвечать на вопросы игроков.
Запрещено использовать мат/просторечия/сокращать слова при ответе. Пример : "Ща поможем" - (/hwarn)
Запрещено игнорировать /rep - (Снятие)
Offtop в репорт - 10 минут блокировки репорта (/offtop)

В /vad игроки присылают объявления. Задача хелперов их пропустить (/vadgo) или отредактировать (/evad).
Запрещено пропускать объявления содержащие MG - (/hwarn)
Запрещено использовать "КК" в объявлениях - (/hwarn)
Запрещено использовать команду /evad и пропускать пустые объявления - (/hwarn)
Запрещен мат в объявлениях - (/hwarn)
При пропуске объявлений в нем не должно быть грамматических ошибок - (/hwarn)
Запрещено пропускать объявления с сокращенными словами. Пример : Банк захвачен госсы действуйте - (/hwarn)

При входе на сервер вы должны прописать команду /hduty. При выходе из сервера так-же вы должны прописать эту команду.
За offtop бан репорта 10 минут!
Администратор в праве выдавать наказания за АДЕКВАТНЫЕ нарушения.       
]]
local help_list_command = [[
-- Получить(get) 
[ /glog ] - Посмотреть логи игрока
[ /gt ] - Посмотреть информацию о игроке(/geton)
[ /gi ] - Информация о персонаже
[ /gip ] - Получить информацию о ip(Провайдер/страна/город/Растояние)
-- Наказания 
[ /check ] - Быстро посмотреть статистику игрока
[ /oofftop ] - Дает оффтоп за оффтоп на 20 минут
[ /ocaps ] - Дает оффтоп за капс на 5 минут
[ /omat ] - Дает оффтоп за мат на 10 минут
[ /bcheat ] - Бан за читы
[ /bnead ] - Бан за неадекват
[ /jdm ] - Можно быстро посадить игркоа в тюрму за ДМ
[ /jsk ] - Можно быстро посадить игркоа в тюрму за SK
[ /mcaps ] - Даёт мут игроку за CapsLock
[ /mosk ] - Даёт мут игроку за Оскорбления
[ /moska ] - Даёт мут за оск.адм
[ /mmg ] - Мут за МГ
-- Прочее
[ /veh ] - Создать транспорт + /atune
[ /reoff ] - Выйти из tools рекона
[ /re ] - Следить за игроков + включаеться tools рекон
[ /gg ] - Даёт игроку оружие
[ /pma ] - Пожелать удачи в игре игроку
[ /aa ] - /admins
[ /t ] - /time
[ /sh ] - Выдать игроку уроверь ХП
[ /gi ] - Показать информацию о игроке(для разработчиков)
[ //recon ] - Реконектиться на сервер
[ /checkplayers ] - Информация о игроках в зоне стрима
[ /damage ] - Информация о нанесенним уроном
[ /tr ] - Трейсер пуль
[ /zametki ] - выводит всё заметки в чат
[ /sb ] - старт биндера
]]
local help_list_keys = [[
[ U ] - Зажать показать курсор мыши,отжать скрыть курсор мыши
[ CONTROL + 5 ] - Окрыть транспорт(/alock)
[ F3 ] - Сделать скриншот + /time
[ F2 ] - Включить/выключить WallHack Name
[ F5 ] - Включить/выключить WallHack Скелет
[ RSIFT(правый shift)] - Включить/Выключить AirBreak
[ B ] - /hp
[ Insert ] - Включить/выключить ГМ на персонажа / На машину
[ 3 ] - Вводить в чат /a и не нажимает ENTER
[ 4p ] - Вводить в чат /re и не нажимает ENTER
[ CONTROL + Z ] - Вводить в чат /vadgo и не нажимает ENTER
[ CONTROL + X ] - Вводить в чат /evad и не нажимает ENTER
[ CONTROL + B ] - Скопировать id в буфер-обмена
[ CONTROL + NUMPAD 1 ] - Пишет в /ooc о репортах
[ CONTROL + NUMPAD 2 ] - Пишут в /ooc проводите собеседования
-- Репорт
[ P ] - /rep
[ P + 1 ] - Начинаю работать по вашей жалобе!
[ P + 2 ] - Начинаю работать по вашему вопросу!
[ P + 3 ] - Уточните,и я смогу вам помочь!
[ P + 4 ] - перенаправить жалобу в вопрос
-- Быстрые клавишы
ПКМ(по игроку) + Z - Чекнуть статистику игрока
ПКМ(по игроку) + X - Зареспавнить игрока
]]
local text_help_recon = [[
-- рекон
NUMPAD0 +
NUMPAD1 - Пожелать игроку удачи
NUMPAD2 - Зареспавнить
NUMPAD3 - Дать хп
NUMPAD4 - Убить
NUMPAD5 - Получить оружие/патроны
NUMPAD6 - Получить ip
Стрелочка вправо - следущий игрок
Стрелочка влево - привыдущий игрок
/ - Вкл./Откл. инфобар
-- инфобар
NICK: - Ник_Нейм игрока за которым вы сделите
ID: - Ид игрока за которым вы следите
_____________
ХП: - ХП/Здоровья игрока
Броня: - Броня игрока
Пинг: - Пинг игрока
LVL: - лвл/score игрока
AFK: - афк ли игрок 
Скин: - Скин игрока
Оружие: - Оружие игрока 
_____________
ХП: - ХП/Здоровья машины
Скорость: - Скорость машины 
Модель: - Kакая машина
Двигатель: - Проверяет ли заглушен или заведен Двигатель
Машина: - закрыта или окрыта машина 
Id: - ид машины (/dl)
]]

function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    style.WindowRounding = 2.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0
    colors[clr.FrameBg]                = ImVec4(0.16, 0.48, 0.42, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.98, 0.85, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.98, 0.85, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.48, 0.42, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.88, 0.77, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.98, 0.85, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.98, 0.82, 1.00)
    colors[clr.Header]                 = ImVec4(0.26, 0.98, 0.85, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.98, 0.85, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.10, 0.75, 0.63, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.10, 0.75, 0.63, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.98, 0.85, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.98, 0.85, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.98, 0.85, 0.95)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.81, 0.35, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.98, 0.85, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end
apply_custom_style()

-- Функции -- 

function main()
    sampHandle = sampGetBase()
    writeMemory(sampHandle + 0x2D3C45, 4, 0, 1)
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

	sampAddChatMessage('1', -1)

       --[[ ip, port = sampGetCurrentServerAddress()
        if ip == '176.32.39.43' or port == '7777' then
            PushMessage("Gold Admin Tools  - Успешно загружен!")
        else
            PushMessage('Gold Admin Tools Был отключен (вы не находитесь на Gold-Role Play!)')
            thisScript():unload()
        end]]

    RegisterCommands()

  while true do
    wait(0)

--[[
		if admin then
			lua_thread.create(function()
			RegisterCommands()
			PushMessage("Gold Admin Tools  - Успешно загружен!")
		else
			wait(120000)
			PushMessage('Gold Tools Был отключен. Вы не администратор')
			end)
			break
		end
]]

    -- Прочее
    if GetPosition then -- получить X и Y
        sampSetCursorMode(2)
        main_window_state.v = false
            if wasKeyPressed(key.VK_LBUTTON) then
                x, y = getCursorPos()
                PushMessage('Координаты \nX:'..math.floor(x)..' | Y:'..math.floor(y))
                sampSetCursorMode(0)
                GetPosition = false
                main_window_state.v = true
            end
    end
        if ShowTextdraw == true then
            for a = 0, 2304 do --cycle trough all textdeaw id
                if sampTextdrawIsExists(a) then --if textdeaw exists then
                    x, y = sampTextdrawGetPos(a) --we get it's position. value returns in game coords
                        x1, y1 = convertGameScreenCoordsToWindowScreenCoords(x, y) --so we convert it to screen cuz render needs screen coords
                        renderFontDrawText(font, a, x1, y1, 0xFFBEBEBE) --and then we draw it's id on textdeaw position
                    end
                end
            end
        if isCharInAnyCar(PLAYER_PED) then -- car name 
            if localPlayerInCar then
                localPlayerInCar = false
                printStyledString('~y~'..getCarNamebyModel(getCarModel(storeCarCharIsInNoSave(PLAYER_PED))), 1500, 2)
            end
        else
            localPlayerInCar = true
        end
        _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if recon.v then -- imgui recon
        sampTextdrawDelete(70) 
            sampTextdrawDelete(2064)
                sampTextdrawDelete(2063)
        if wasKeyPressed(key.VK_NUMPAD1) and isKeyDown(key.VK_NUMPAD0) then
            sampSendChat('/pm '..ReconID..' Удачной вам игры на Gold-RP!')
        end
        if wasKeyPressed(key.VK_NUMPAD2) and isKeyDown(key.VK_NUMPAD0) then
            sampSendChat('/setsp '..ReconID)
        end
        if wasKeyPressed(key.VK_NUMPAD3) and isKeyDown(key.VK_NUMPAD0) then
            sampSendChat('/sethp '..ReconID.. ' 100')
        end
        if wasKeyPressed(key.VK_NUMPAD4) and isKeyDown(key.VK_NUMPAD0) then
            sampSendChat('/sethp '..ReconID.. ' 0')
        end
        if wasKeyPressed(key.VK_NUMPAD5) and isKeyDown(key.VK_NUMPAD0) then
            sampSendChat('/iwep '..ReconID)
        end
        if wasKeyPressed(key.VK_NUMPAD6) and isKeyDown(key.VK_NUMPAD0) then
            sampSendChat('/getip '..ReconID)
        end
        if wasKeyPressed(key.VK_RIGHT) and isKeyDown(key.VK_NUMPAD0) then
            ReconID = (ReconID + 1)
                sampProcessChatInput('/re '..ReconID)
        end
        if wasKeyPressed(key.VK_LEFT) and isKeyDown(key.VK_NUMPAD0) then
            ReconID = (ReconID - 1)
                sampProcessChatInput('/re '..ReconID)
        end
        if wasKeyPressed(key.VK_DIVIDE) and isKeyDown(key.VK_NUMPAD0) then
            var = not var
                if var then
                    recon_infa_player.v = false
                else
                    recon_infa_player.v = true
                end
        end
    end --
    -- key
    if not isSampfuncsConsoleActive() and not sampIsDialogActive() then
        if wasKeyPressed(key.VK_B) and isKeyDown(key.VK_CONTROL) then setClipboardText(id) PushMessage('Ваш id был скопирован в буфер-обмена') end -- id
    end
    if not sampIsChatInputActive() and not isSampfuncsConsoleActive() then
	    if isKeyDown(key.VK_P) and wasKeyPressed(key.VK_1) then
        	sampSetCurrentDialogEditboxText(ReportOtvet.settings.otvet1)
        	setVirtualKeyDown(key.VK_RETURN, true) wait(150) setVirtualKeyDown(key.VK_RETURN, false)
        end
    	if isKeyDown(key.VK_P) and wasKeyPressed(key.VK_2) then
    		sampSetCurrentDialogEditboxText(ReportOtvet.settings.otvet2)
    		setVirtualKeyDown(key.VK_RETURN, true) wait(150) setVirtualKeyDown(key.VK_RETURN, false)
    	end
    	if isKeyDown(key.VK_P) and wasKeyPressed(key.VK_3) then
    		sampSetCurrentDialogEditboxText(ReportOtvet.settings.otvet3)
    		setVirtualKeyDown(key.VK_RETURN, true) wait(150) setVirtualKeyDown(key.VK_RETURN, false)
    	end
    	if isKeyDown(key.VK_P) and wasKeyPressed(key.VK_4) then
    		sampSetCurrentDialogEditboxText(ReportOtvet.settings.otvet4)
    		setVirtualKeyDown(key.VK_RETURN, true) wait(150) setVirtualKeyDown(key.VK_RETURN, false)
    	end
    end
    if not sampIsDialogActive() and not sampIsChatInputActive() and not isSampfuncsConsoleActive() then
        if isKeyDown(key.VK_U) then -- мышь
            imgui.ShowCursor = true
        else
            imgui.ShowCursor = false
        end
        	if Load_Config.Options.FastKey then
	        	if wasKeyPressed(key.VK_3) then sampSetChatInputEnabled(true) sampSetChatInputText('/a ') end -- /a
	            if wasKeyPressed(key.VK_4) then sampSetChatInputEnabled(true) sampSetChatInputText('/re ') end -- /re
	            if wasKeyPressed(key.VK_5) then sampSendChat('/alock') end -- /alock
	        end
            if wasKeyPressed(key.VK_NUMPAD1) and isKeyDown(key.VK_CONTROL) then -- binder /ooc report's
                text = [[/o Ув.Игроки,увидели читера,или хотите задать вопрос?.
/o Пишите в репорт(/mm -> Репорт -> Жалоба/Вопрос)!.
/o Жалоба - Для администрации | Вопрос - Для хелперов.
/o Соблюдайте правила подачи репорта!.
/o Администрация и хелперы ждут ваших жалоб/вопросов!.]]
                    multiStringSendChat(1000, text)
            end
            if wasKeyPressed(key.VK_NUMPAD2) and isKeyDown(key.VK_CONTROL) then -- binder /ooc zam/leaders sobecki
                text = [[/o Ув.Лидеры и Замы.
/o Делайте собеседование,игрокам скучно!
/o С уважением -> Администрация Gold Rp!]]
                    multiStringSendChat(1000, text)
            end
            if wasKeyPressed(key.VK_B) then sampSendChat('/hp') end -- /hp
            if wasKeyPressed(key.VK_F5) then 
                WallHackSkeletal = not WallHackSkeletal
                PushMessage(WallHackSkeletal and '[WallHack Skeletal]: Включен' or '[WallHack Skeletal]: Выключен')
            end
            if wasKeyPressed(key.VK_RSHIFT) then -- key air break
                var = not var
                    if var then
            airbrk = true
            posX, posY, posZ = getCharCoordinates(playerPed)
            airBrkCoords = {posX, posY, posZ, 0.0, 0.0, getCharHeading(playerPed)}
                PushMessage('[AirBreak] Включен') 
        else
            airbrk = false
                PushMessage('[AirBreak] Выключен')
                end
            end
        local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE) -- Fast Key
            if valid and doesCharExist(ped) then
                local result, id_ = sampGetPlayerIdByCharHandle(ped)
                    if result and isKeyDown(key.VK_RBUTTON) then
                        if isKeyJustPressed(key.VK_Z) then
                            sampSendChat('/getstats '..id_)
                            nick = sampGetPlayerNickname(id_) 
                                PushMessage('[Fast Key] Вы посмотрели статистику '..nick)
                        end
                        if isKeyJustPressed(key.VK_X) then
                            sampA('/setsp '..id_)
                            nick = sampGetPlayerNickname(id_)
                                PushMessage('[Fast Key] Вы зареспавнили '..nick)
                        end
                    end
            end
-- sampGetPlayerNickname(sampGetPlayerIdByCharHandle)
            if airbrk then -- Air Break
                if isCharInAnyCar(playerPed) then heading = getCarHeading(storeCarCharIsInNoSave(playerPed))
                else heading = getCharHeading(playerPed) end
                camCoordX, camCoordY, camCoordZ = getActiveCameraCoordinates()
                targetCamX, targetCamY, targetCamZ = getActiveCameraPointAt()
                angle = getHeadingFromVector2d(targetCamX - camCoordX, targetCamY - camCoordY)
                if isCharInAnyCar(playerPed) then difference = 0.79 else difference = 1.0 end
                setCharCoordinates(playerPed, airBrkCoords[1], airBrkCoords[2], airBrkCoords[3] - difference)
                if isKeyDown(key.VK_W) then
                    airBrkCoords[1] = airBrkCoords[1] + speed_airbrk * math.sin(-math.rad(angle))
                    airBrkCoords[2] = airBrkCoords[2] + speed_airbrk * math.cos(-math.rad(angle))
                    if not isCharInAnyCar(playerPed) then setCharHeading(playerPed, angle)
                    else setCarHeading(storeCarCharIsInNoSave(playerPed), angle) end
                elseif isKeyDown(key.VK_S) then
                    airBrkCoords[1] = airBrkCoords[1] - speed_airbrk * math.sin(-math.rad(heading))
                    airBrkCoords[2] = airBrkCoords[2] - speed_airbrk * math.cos(-math.rad(heading))
                end
                if isKeyDown(key.VK_A) then
                    airBrkCoords[1] = airBrkCoords[1] - speed_airbrk * math.sin(-math.rad(heading - 90))
                    airBrkCoords[2] = airBrkCoords[2] - speed_airbrk * math.cos(-math.rad(heading - 90))
                elseif isKeyDown(key.VK_D) then
                    airBrkCoords[1] = airBrkCoords[1] - speed_airbrk * math.sin(-math.rad(heading + 90))
                    airBrkCoords[2] = airBrkCoords[2] - speed_airbrk * math.cos(-math.rad(heading + 90))
                end
                if isKeyDown(key.VK_LSHIFT) then airBrkCoords[3] = airBrkCoords[3] + speed_airbrk / 2.0 end
                if isKeyDown(key.VK_SPACE) and airBrkCoords[3] > - 95.0 then airBrkCoords[3] = airBrkCoords[3] - speed_airbrk / 2.0 end
            end
    end
    if wasKeyPressed(key.VK_F3) then
        sampSendChat('/time') sampAddChatMessage(os.date( "Время на вашем компьютере:{CCFF00}%H:%M:%S{FFFFFF} | Вы отыграли:{CCFF00}"..(FormatTime(os.clock(), os.time()))), -1)
        wait(350)
            takeScreen()
    end
    imgui.Process = main_window_state.v or recon.v or rules_for_admins.v or Checker.v
    TraicesBullet()
    SkeletalWallHack()
    if sampGetPlayerHealth(id) == 0 then
        printStyledString('~b~WASTED', 1500, 1)
    end
    if os.date("%M:%S") == '55:00' then printStyledString('~y~Five Minute To PayDay!', 2500, 2) end
    if main_window_state.v or recon.v or rules_for_admins.v or Checker.v then
        if wasKeyPressed(key.VK_R) and isKeyDown(key.VK_LSHIFT) then
            thisScript():reload()
                PushMessage('[Reload] Вы успешно перезагрузили плагин!')
        end
    end
  end
end

-- прочие функции 

function set_player_skin(id, skin)
 local BS = raknetNewBitStream()
 raknetBitStreamWriteInt32(BS, id)
 raknetBitStreamWriteInt32(BS, skin)
 raknetEmulRpcReceiveBitStream(153, BS)
 raknetDeleteBitStream(BS)
end

function FormatTime(time)
    local timezone_offset = 86400 - os.date('%H', 0) * 3600
    local time = time + timezone_offset
    return  os.date((os.date("%H",time) == "00" and '%M:%S' or '%H:%M:%S'), time)
end

function TraicesBullet()
 local oTime = os.time()
    if traicers == true then
        for i = 1, BulletSync.maxLines do
            if BulletSync[i].enable == true and BulletSync[i].time >= oTime then
                local sx, sy, sz = calcScreenCoors(BulletSync[i].o.x, BulletSync[i].o.y, BulletSync[i].o.z)
                local fx, fy, fz = calcScreenCoors(BulletSync[i].t.x, BulletSync[i].t.y, BulletSync[i].t.z)

                if sz > 1 and fz > 1 then
                    renderDrawLine(sx, sy, fx, fy, 1, BulletSync[i].tType == 0 and 0xFFFFFFFF or 0xFFFFC700)
                    renderDrawPolygon(fx, fy-1, 3, 3, 4.0, 10, BulletSync[i].tType == 0 and 0xFFFFFFFF or 0xFFFFC700)
                end
            end
        end
    end
end

function asyncHttpRequest(method, url, args, resolve, reject)
    local request_thread = effil.thread(function(method, url, args)
        local requests = require"requests"
        local result, response = pcall(requests.request, method, url, args)
        if result then
            response.json, response.xml = nil, nil
            return true, response
        else
            return false, response
        end
    end)(method, url, args)

    if not resolve then
        resolve = function() end
    end
    if not reject then
        reject = function() end
    end
    lua_thread.create(function()
        local runner = request_thread
        while true do
            local status, err = runner:status()
            if not err then
                if status == "completed" then
                    local result, response = runner:get()
                    if result then
                        resolve(response)
                    else
                        reject(response)
                    end
                    return
                elseif status == "canceled" then
                    return reject(status)
                end
            else
                return reject(err)
            end
            wait(0)
        end
    end)
end

function distance_cord(lat1, lon1, lat2, lon2)
    if lat1 == nil or lon1 == nil or lat2 == nil or lon2 == nil or lat1 == "" or lon1 == "" or lat2 == "" or lon2 == "" then
        return 0
    end
    local dlat = math.rad(lat2 - lat1)
    local dlon = math.rad(lon2 - lon1)
    local sin_dlat = math.sin(dlat / 2)
    local sin_dlon = math.sin(dlon / 2)
    local a =
        sin_dlat * sin_dlat + math.cos(math.rad(lat1)) * math.cos(
            math.rad(lat2)
        ) * sin_dlon * sin_dlon
    local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    local d = 6378 * c
    return d
end

function getFileName()
    file = string.format("moonloader\\Admin Tools\\ChatLog\\["  .. os.date("!*t").day .. "." .. os.date("!*t").month .. "." .. os.date("!*t").year .. "].txt")
    return file  
end

function takeScreen()
  if isSampLoaded() then
    require("ffi").cast("void (*__stdcall)()", sampGetBase() + 0x70FC0)()
  end
end

function PushMessage(text)
    if Load_Config.Options.Sound == true then
        addOneOffSound(0, 0, 0, 1083)
    end
    if Load_Config.Options.Message == true then
    local notf
        if not doesFileExist(getWorkingDirectory() .. "\\imgui_notf.lua") then
                sampAddChatMessage(tag..'{FF0000}[!] Ошибка! {FFFFFF}Файл imgui_notf.lua не найдет', -1); sampAddChatMessage(tag..'{FF0000}[!] {FFFFFF}Функция PushMessage отключена', -1)
                    Load_Config.Options.Message = false
                        inicfg.save(Load_Config, Direct_Ini)                        
        else
            notf = import 'imgui_notf.lua'
        end
        if notf then notf.addNotification((text), 5, 2) end
    end
    if Load_Config.Options.Message == false then
        sampAddChatMessage(tag..(text), -1)
    end
end

function getweaponname(weapon)
  local names = {
  [0] = "Fist",
  [1] = "Brass Knuckles",
  [2] = "Golf Club",
  [3] = "Nightstick",
  [4] = "Knife",
  [5] = "Baseball Bat",
  [6] = "Shovel",
  [7] = "Pool Cue",
  [8] = "Katana",
  [9] = "Chainsaw",
  [10] = "Purple Dildo",
  [11] = "Dildo",
  [12] = "Vibrator",
  [13] = "Silver Vibrator",
  [14] = "Flowers",
  [15] = "Cane",
  [16] = "Grenade",
  [17] = "Tear Gas",
  [18] = "Molotov Cocktail",
  [22] = "9mm",
  [23] = "Silenced 9mm",
  [24] = "Desert Eagle",
  [25] = "Shotgun",
  [26] = "Sawnoff Shotgun",
  [27] = "Combat Shotgun",
  [28] = "Micro SMG/Uzi",
  [29] = "MP5",
  [30] = "AK-47",
  [31] = "M4",
  [32] = "Tec-9",
  [33] = "Country Rifle",
  [34] = "Sniper Rifle",
  [35] = "RPG",
  [36] = "HS Rocket",
  [37] = "Flamethrower",
  [38] = "Minigun",
  [39] = "Satchel Charge",
  [40] = "Detonator",
  [41] = "Spraycan",
  [42] = "Fire Extinguisher",
  [43] = "Camera",
  [44] = "Night Vis Goggles",
  [45] = "Thermal Goggles",
  [46] = "Parachute" }
  return names[weapon]
end

function getCarNamebyModel(model)
    local names = {
      [400] = 'Landstalker',
      [401] = 'Bravura',
      [402] = 'Buffalo',
      [403] = 'Linerunner',
      [404] = 'Perennial',
      [405] = 'Sentinel',
      [406] = 'Dumper',
      [407] = 'Firetruck',
      [408] = 'Trashmaster',
      [409] = 'Stretch',
      [410] = 'Manana',
      [411] = 'Infernus',
      [412] = 'Voodoo',
      [413] = 'Pony',
      [414] = 'Mule',
      [415] = 'Cheetah',
      [416] = 'Ambulance',
      [417] = 'Leviathan',
      [418] = 'Moonbeam',
      [419] = 'Esperanto',
      [420] = 'Taxi',
      [421] = 'Washington',
      [422] = 'Bobcat',
      [423] = 'Mr. Whoopee',
      [424] = 'BF Injection',
      [425] = 'Hunter',
      [426] = 'Premier',
      [427] = 'Enforcer',
      [428] = 'Securicar',
      [429] = 'Banshee',
      [430] = 'Predator',
      [431] = 'Bus',
      [432] = 'Rhino',
      [433] = 'Barracks',
      [434] = 'Hotknife',
      [435] = 'Article Trailer',
      [436] = 'Previon',
      [437] = 'Coach',
      [438] = 'Cabbie',
      [439] = 'Stallion',
      [440] = 'Rumpo',
      [441] = 'RC Bandit',
      [442] = 'Romero',
      [443] = 'Packer',
      [444] = 'Monster',
      [445] = 'Admiral',
      [446] = 'Squallo',
      [447] = 'Seaspamrow',
      [448] = 'Pizzaboy',
      [449] = 'Tram',
      [450] = 'Article Trailer 2',
      [451] = 'Turismo',
      [452] = 'Speeder',
      [453] = 'Reefer',
      [454] = 'Tropic',
      [455] = 'Flatbed',
      [456] = 'Yankee',
      [457] = 'Caddy',
      [458] = 'Solair',
      [459] = 'Topfun Van',
      [460] = 'Skimmer',
      [461] = 'PCJ-600',
      [462] = 'Faggio',
      [463] = 'Freeway',
      [464] = 'RC Baron',
      [465] = 'RC Raider',
      [466] = 'Glendale',
      [467] = 'Oceanic',
      [468] = 'Sanchez',
      [469] = 'Spamrow',
      [470] = 'Patriot',
      [471] = 'Quad',
      [472] = 'Coastguard',
      [473] = 'Dinghy',
      [474] = 'Hermes',
      [475] = 'Sabre',
      [476] = 'Rustler',
      [477] = 'ZR-350',
      [478] = 'Walton',
      [479] = 'Regina',
      [480] = 'Comet',
      [481] = 'BMX',
      [482] = 'Burrito',
      [483] = 'Camper',
      [484] = 'Marquis',
      [485] = 'Baggage',
      [486] = 'Dozer',
      [487] = 'Maverick',
      [488] = 'News Maverick',
      [489] = 'Rancher',
      [490] = 'FBI Rancher',
      [491] = 'Virgo',
      [492] = 'Greenwood',
      [493] = 'Jetmax',
      [494] = 'Hotring Racer',
      [495] = 'Sandking',
      [496] = 'Blista Compact',
      [497] = 'Police Maverick',
      [498] = 'Boxville',
      [499] = 'Benson',
      [500] = 'Mesa',
      [501] = 'RC Goblin',
      [502] = 'Hotring Racer A',
      [503] = 'Hotring Racer B',
      [504] = 'Bloodring Banger',
      [505] = 'Rancher',
      [506] = 'Super GT',
      [507] = 'Elegant',
      [508] = 'Journey',
      [509] = 'Bike',
      [510] = 'Mountain Bike',
      [511] = 'Beagle',
      [512] = 'Cropduster',
      [513] = 'Stuntplane',
      [514] = 'Tanker',
      [515] = 'Roadtrain',
      [516] = 'Nebula',
      [517] = 'Majestic',
      [518] = 'Buccaneer',
      [519] = 'Shamal',
      [520] = 'Hydra',
      [521] = 'FCR-900',
      [522] = 'NRG-500',
      [523] = 'HPV1000',
      [524] = 'Cement Truck',
      [525] = 'Towtruck',
      [526] = 'Fortune',
      [527] = 'Cadrona',
      [528] = 'FBI Truck',
      [529] = 'Willard',
      [530] = 'Forklift',
      [531] = 'Tractor',
      [532] = 'Combine',
      [533] = 'Feltzer',
      [534] = 'Remington',
      [535] = 'Slamvan',
      [536] = 'Blade',
      [537] = 'Train',
      [538] = 'Train',
      [539] = 'Vortex',
      [540] = 'Vincent',
      [541] = 'Bullet',
      [542] = 'Clover',
      [543] = 'Sadler',
      [544] = 'Firetruck',
      [545] = 'Hustler',
      [546] = 'Intruder',
      [547] = 'Primo',
      [548] = 'Cargobob',
      [549] = 'Tampa',
      [550] = 'Sunrise',
      [551] = 'Merit',
      [552] = 'Utility Van',
      [553] = 'Nevada',
      [554] = 'Yosemite',
      [555] = 'Windsor',
      [556] = 'Monster A',
      [557] = 'Monster B',
      [558] = 'Uranus',
      [559] = 'Jester',
      [560] = 'Sultan',
      [561] = 'Stratum',
      [562] = 'Elegy',
      [563] = 'Raindance',
      [564] = 'RC Tiger',
      [565] = 'Flash',
      [566] = 'Tahoma',
      [567] = 'Savanna',
      [568] = 'Bandito',
      [569] = 'Train',
      [570] = 'Train',
      [571] = 'Kart',
      [572] = 'Mower',
      [573] = 'Dune',
      [574] = 'Sweeper',
      [575] = 'Broadway',
      [576] = 'Tornado',
      [577] = 'AT400',
      [578] = 'DFT-30',
      [579] = 'Huntley',
      [580] = 'Stafford',
      [581] = 'BF-400',
      [582] = 'Newsvan',
      [583] = 'Tug',
      [584] = 'Petrol Trailer',
      [585] = 'Emperor',
      [586] = 'Wayfarer',
      [587] = 'Euros',
      [588] = 'Hotdog',
      [589] = 'Club',
      [590] = 'Train',
      [591] = 'Article Trailer 3',
      [592] = 'Andromada',
      [593] = 'Dodo',
      [594] = 'RC Cam',
      [595] = 'Launch',
      [596] = 'Police Car LS',
      [597] = 'Police Car SF',
      [598] = 'Police Car LV',
      [599] = 'Police Ranger',
      [600] = 'Picador',
      [601] = 'S.W.A.T.',
      [602] = 'Alpha',
      [603] = 'Phoenix',
      [604] = 'Glendale',
      [605] = 'Sadler',
      [606] = 'Baggage Trailer',
      [607] = 'Baggage Trailer',
      [608] = 'Tug Stairs Trailer',
      [609] = 'Boxville',
      [610] = 'Farm Trailer',
      [611] = 'Utility Traileraw '
    }
    return names[model]
end

function multiStringSendChat(delay, multiStringText)   
    lua_thread.create(function()
        multiStringText = multiStringText..'\n'
        for s in multiStringText:gmatch('.-\n') do
            sampSendChat(s)
            wait(delay)
        end
    end)
end

function imgui.Center(coords)
    imgui.Spacing()
        imgui.SameLine(coords)
end

function imgui.TextQuestion(sign, text)
    imgui.TextDisabled(sign)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        if sign == '[!]' then
            imgui.TextColored(imgui.ImVec4(1,0,0,1), u8'[!] Важно!')
        elseif sign == '(?)' then
            imgui.Text(u8'(?) Подсказка')
        end
        imgui.Separator()
        imgui.TextUnformatted(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function hint(text)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        imgui.TextDisabled(u8'Подсказка')
        imgui.Separator()
        imgui.TextUnformatted(u8(text))
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function FontSize(size)
    imgui.SetWindowFontScale(size)
end

function nameTagOn()
    local pStSet = sampGetServerSettingsPtr()
    WallHackNameTag = true
    NTdist = mem.getfloat(pStSet + 39) -- дальность
    NTwalls = mem.getint8(pStSet + 47) -- видимость через стены
    NTshow = mem.getint8(pStSet + 56) -- видимость тегов
    mem.setfloat(pStSet + 39, 1488.0)
    mem.setint8(pStSet + 47, 0)
    mem.setint8(pStSet + 56, 1)
end

function showdialog(name, rdata)
    sampShowDialog(
        math.random(1000),
        "{FF4444}" .. name,
        rdata,
        "Закрыть",
        false,
        0
    )
end

function calcScreenCoors(fX,fY,fZ)
    local dwM = 0xB6FA2C

    local m_11 = mem.getfloat(dwM + 0*4)
    local m_12 = mem.getfloat(dwM + 1*4)
    local m_13 = mem.getfloat(dwM + 2*4)
    local m_21 = mem.getfloat(dwM + 4*4)
    local m_22 = mem.getfloat(dwM + 5*4)
    local m_23 = mem.getfloat(dwM + 6*4)
    local m_31 = mem.getfloat(dwM + 8*4)
    local m_32 = mem.getfloat(dwM + 9*4)
    local m_33 = mem.getfloat(dwM + 10*4)
    local m_41 = mem.getfloat(dwM + 12*4)
    local m_42 = mem.getfloat(dwM + 13*4)
    local m_43 = mem.getfloat(dwM + 14*4)

    local dwLenX = mem.read(0xC17044, 4)
    local dwLenY = mem.read(0xC17048, 4)

    frX = fZ * m_31 + fY * m_21 + fX * m_11 + m_41
    frY = fZ * m_32 + fY * m_22 + fX * m_12 + m_42
    frZ = fZ * m_33 + fY * m_23 + fX * m_13 + m_43

    fRecip = 1.0/frZ
    frX = frX * (fRecip * dwLenX)
    frY = frY * (fRecip * dwLenY)

    if(frX<=dwLenX and frY<=dwLenY and frZ>1)then
        return frX, frY, frZ
    else
        return -1, -1, -1
    end
end

function join_argb(a, r, g, b)
  local argb = b  -- b
  argb = bit.bor(argb, bit.lshift(g, 8))  -- g
  argb = bit.bor(argb, bit.lshift(r, 16)) -- r
  argb = bit.bor(argb, bit.lshift(a, 24)) -- a
  return argb
end

function explode_argb(argb)
  local a = bit.band(bit.rshift(argb, 24), 0xFF)
  local r = bit.band(bit.rshift(argb, 16), 0xFF)
  local g = bit.band(bit.rshift(argb, 8), 0xFF)
  local b = bit.band(argb, 0xFF)
  return a, r, g, b
end

function sampGetPlayerIdByNickname(nick)
    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    if tostring(nick) == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 1000 do if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then return i end end
end

function saveConfig()
    if inicfg.save(Load_Config, Direct_Ini) then
        PushMessage('Вы успешно сохранили настройки!')
        	imgui.ShowCursor = false
            --thisScript():reload()
    else
        PushMessage('[!] Ой..Что-то пошло не так!\n Настройки не сохранились!')
    end
end

function SkeletalWallHack()
    if WallHackSkeletal == true then
    for i = 0, sampGetMaxPlayerId() do
        if sampIsPlayerConnected(i) then
            local result, cped = sampGetCharHandleBySampPlayerId(i)
            local color = sampGetPlayerColor(i)
            local aa, rr, gg, bb = explode_argb(color)
            local color = join_argb(255, rr, gg, bb)
            if result then
                if doesCharExist(cped) and isCharOnScreen(cped) then
                    local t = {3, 4, 5, 51, 52, 41, 42, 31, 32, 33, 21, 22, 23, 2}
                    for v = 1, #t do
                        pos1X, pos1Y, pos1Z = getBodyPartCoordinates(t[v], cped)
                        pos2X, pos2Y, pos2Z = getBodyPartCoordinates(t[v] + 1, cped)
                        pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                        pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                        renderDrawLine(pos1, pos2, pos3, pos4, 1, color)
                    end
                    for v = 4, 5 do
                        pos2X, pos2Y, pos2Z = getBodyPartCoordinates(v * 10 + 1, cped)
                        pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                        renderDrawLine(pos1, pos2, pos3, pos4, 1, color)
                    end
                    local t = {53, 43, 24, 34, 6}
                    for v = 1, #t do
                        posX, posY, posZ = getBodyPartCoordinates(t[v], cped)
                        pos1, pos2 = convert3DCoordsToScreen(posX, posY, posZ)
                        end
                    end
                end
            end
        if Load_Config.Options.WallHackSkeletalLine == true then
            DNICK_RESULT, DNICK_PED = sampGetCharHandleBySampPlayerId(i)
            if DNICK_RESULT and isCharOnScreen(DNICK_PED) then
                local pPedX, pPedY, pPedZ = getCharCoordinates(PLAYER_PED)
                local dPedX, dPedY, dPedZ = getCharCoordinates(DNICK_PED)
                if getDistanceBetweenCoords3d(pPedX, pPedY, pPedZ, dPedX, dPedY, dPedZ) < 100 then
                    local VirPoX, VirPoY = convert3DCoordsToScreen(pPedX, pPedY, pPedZ)
                    local VirPosX, VirPosY = convert3DCoordsToScreen(dPedX, dPedY, dPedZ)
                    if sampIsPlayerPaused(i) then
                        afkColor = 0xFFFF0000 -- 0xFFFF0000
                    else
                        afkColor = 0xFF00FF00
                    end
                    renderDrawLine(VirPoX, VirPoY, VirPosX, VirPosY, 1, afkColor)
        end
                end
            end
        end
    end
end

        --[[for i = 0, sampGetMaxPlayerId(true) do
            DNICK_RESULT, DNICK_PED = sampGetCharHandleBySampPlayerId(i)
            if DNICK_RESULT and isCharOnScreen(DNICK_PED) then
                local pPedX, pPedY, pPedZ = getCharCoordinates(PLAYER_PED)
                local dPedX, dPedY, dPedZ = getCharCoordinates(DNICK_PED)
                if getDistanceBetweenCoords3d(pPedX, pPedY, pPedZ, dPedX, dPedY, dPedZ) < 100 then
                    local VirPoX, VirPoY = convert3DCoordsToScreen(pPedX, pPedY, pPedZ)
                    local VirPosX, VirPosY = convert3DCoordsToScreen(dPedX, dPedY, dPedZ)
                    renderDrawLine(VirPoX, VirPoY, VirPosX, VirPosY, 1, 0xFFFFFFFF)
                end
            end
        end
        ]]

function getBodyPartCoordinates(id, handle)
  local pedptr = getCharPointer(handle)
  local vec = ffi.new("float[3]")
  getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
  return vec[0], vec[1], vec[2]
end

function onQuitGame()
    local Online = os.date("%d.%m.%y | %H:%M:%S")
    Load_Config.info.LastConnect = Online
        inicfg.save(Load_Config, Direct_Ini)
end

function nameTagOff()
    WallHackNameTag = false
    local pStSet = sampGetServerSettingsPtr()
    mem.setfloat(pStSet + 39, NTdist)
    mem.setint8(pStSet + 47, NTwalls)
    mem.setint8(pStSet + 56, NTshow)
end

function imgui.TextColor(text)
    local width = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local textsize = w:gsub('{.-}', '')
            local text_width = imgui.CalcTextSize(u8(textsize))
            imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else
                imgui.Text(u8(w))
            end
        end
    end
    render_text(text)
end

function CreateFile()
    createDirectory('moonloader/Admin Tools/Прочее')
c1 = [[
употреблять ненормативную лексику в диалоге с игроком – выговор !
угрожать игрокам – выговор !
игнорировать репорт – выговор !
заходить с мультиаккаунта в основу и мстить - снятие!
использовать читы и команды администратора в РП ситуациях/захватах - выговор!
нарушать правила сервера (ДМ.ДБ.ТК.СК.ПГ.RK) - выговор!
проверять на GM игрока во время стрельбы! – кбан 10 минут !
проверять личные файлы ПК игрока – выговор!
игроки Ghetto и Мафий при явных подозрениях на использование приватных читов.
вступать в банду! Даже если есть доступ на фракцию - выговор!
использовать читы при игроках – выговор !
использовать вредительские читы – снятие !

ненормативная лексика в /o /aad /pm и т.д - снятие!
использовать /pm в личных целях – выговор !
писать бред в /aad, /o чаты - выговор!
флуд в /a, /hc, /aad, /o и т.д. – кбан 10 минут!
оскорбление родителей– Снятие !
оскорбление национальности, ориентации и половой принадлежности – выговор!

оскорбление коллег - выговор!
нарушать субординацию – кбан 10 мин !
выдавать наказание админу старше, или равному себе по должности - выговор!
угрожать коллегам снятием или выговором – выговор !
конфликтовать на сервере - выговор!
делать замечания или обсуждать действие админа старше или равного себе - выговор!
клеветать на коллег – выговор !
выполнять просьбы других администраторов – выговор !
выпрашивать у ст.Администрации доступ/снятие выговора/должность/повышение – выговор !

выдавать наказание игроку не имея доказательств на его нарушение – выговор !
участвовать в МП - выговор!
использовать баги сервера - выговор!
писать несуразные причины - выговор!
оскорбительные причины –снятие!
делать обзвон с помощью команды: "/mp" - выговор!
проводить мероприятие во время капта или обзвона– кбан 10 минут !
проводить мероприятия чаще, чем раз в час – выговор !
Исключение : Разрешение создателя
быть лидером на любом из 2-х серверов – выговор !
использовать читы и вступать во фракцию без доступа – выговор !     

P.S.:Было вырезаный текст "Запрещено",вить изза этого были баги в тексте]]
c2 = [[
•• Спец. Администратор

Разрешается 1 помощник: Помощник Спец. Адм

Должность не продается. Назначаются на эту должность только создателем.

Обязанности:

Контроль за форумом (Проверка спец. тем, контроль за следящим за форумом)
Спец. администратор ставит на должности: гс форума; гс гетто; гс мафий, гс гос; организатора мп, гс за рп; (Создатели и основатели могут принимать в этом участие)
Контроль должностных администраторов ниже по иерархии.
Организационные идеи для улучшения сервера.
Проверка отчетности ГС и прочих должностных лиц.
список может пополняться ..
•• Следящий за Форумом

Разрешается 1 зам: Заместитель Следящего за форумом
Разрешается 1 помощник: Помощник Следящего за Форумом

Должность не продается. Назначаются на эту должность только создателем/спец.администратором.

Обязанности:

Контроль за форумом (Проверка тем, контроль следящих за форумом)
Контроль должностных администраторов ниже по иерархии.
Организационные идеи для улучшения сервера.
список может пополняться ..


•• Full Основатель

Цена : 3000 рублей.
Разрешается 1 помощник: Помощник Основателя.

Обязанности:
1. Контроль за порядком на сервере
2. Создание и поддержание деловой репутации проекта
3. Помощь в разработке организационных мероприятий проекта
4. Ведение отчётности о нахождении багов
5. Составление целей, планов и тактик развития проекта
6. Предотвращение угроз проекту или его деловой репутации
список может пополняться ..
3000 рублей.


•• Заместитель Следящего за Форумом

Должность не продается. Назначаются на эту должность только создателем/спец.администратором/следящим за форумом.

Обязанности:


Контроль за форумом (Проверка тем)
Контроль должностных администраторов ниже по иерархии.
Организационные идеи для улучшения сервера.
список может пополняться ...

•• Simple Основатель

Покупка временно закрыта.
Разрешается 1 помощник: Помощник Основателя.

Обязанности:
1. Помощь в организационной работе старшой администрации
2. Контроль мл.состава администрации
3. Решение и предотвращение конфликтных ситуаций
4. Разработка мероприятий по повышению квалификации административного состава
5. Разработка и контроль кампании по сбору обратной связи с игроками
6. Предотвращение угроз проекту со стороны действующей администрации и лидеров


••Помощник Следящего за Форумом

Должность не продается. Назначаются на эту должность только создателем/спец.администратором/следящим за форумом.

Обязанности:


Контроль за форумом (Проверка тем)
Контроль должностных администраторов ниже по иерархии.
Организационные идеи для улучшения сервера.
список может пополняться ...


•• Зам.Создателя

Цена: 1500 рублей.

Обязанности:
1. Помощь в организационной работе функционирования проекта
2. Разработка мер по совершенствованию игрового проекта
3. Контроль и исполнение обязанностей по достижению установленных целей
4. Составление прогноза о продвижении показтелей онлайна и деловой репутации проекта
5. При отсутствии создателя, ведение переговоров с составом администрации, кандидатами на сотрудничество и т.д.
6. Контроль трудовой дисцеплины среди администраторов
7. Обеспечение коммуникации между создателем и составом администрации , проверка на исполнение поручений и распоряжений
8. Информирвание создателя о имеющихся недоработках в функционировании проекта
9.Выполнение прямых поручений создателя


•• Куратор ГЕТТО, ГОС.ОРГ, МАФИИ.••

Назначаются спец.админами; создателями после окончания срока ГС.
1.Выбор и назначение ГС за фракциями;
2.Проведение тренингов по повышению квалификации ГС
3. Проведение аттестации для подтверждения уровня квалификации ГС
4. Проверка отчетной документации следящего состава.
5. Представление законных интересов ГС и признание полной ответственности за действия ГС
6. Замещение и временное исполнение обязанностей ГС на момент его нахождения в отпуске
7. Решение конфликтных ситуаций связанных с областью управления и работой ГС
8. Создание целей и планов по развитию области управления
9. Контроль и разработка мер направленных на достижение поставленных целей
10. Составление технических и организационных улучшений в области управления
11. Сбор обратной связи на предмет удовлетворения игроков в области управления
12. Своевременный доклад о возможном негативном влиянии на область управления, со стороны другой администрации
13. Выполнение прямых поручение высшей администрации и поддержание быстрой связи.


•• Пиар-Менеджер••

Назначается спец.админами; создателями
1.Соблюдение Должностной Инструкции ( Предоставляется лично Пиар Менеджеру и разглашению не подлежит )
2. Разработка рекламной кампании
3. Разработка и реализация методов повышения онлайна
4. Контроль средного и суточного онлайна на сервере
5. Создание и поддержание деловой репутации проекта
6. Аудит упоминания и привлечения проекта на сторонних ресурсах
7. Выявление угроз негативного восприятия имиджа проекта
8. Ведение прогноза по развитию проекта
9. Составление отчётной документации о проделанной работе
10. Разработка рекламной кампании

•• Организатор МП••

Назначается на должность спец.администратором.
Разрешается 1 помощник: Помощник Орг. МП.

Обязанности:

1. Организация развлекательных мероприятий на сервере (Организовывать качественные мп (не стандартные) , в день минимум 2 глобальные мп.)
2. Проведение конкурсов
3. Выдача призов
4. Отчёт о выдаче призов
5. Сбор обратной связи о качестве проведения мероприятий
6. Контроль за проведением мероприятий другими администраторами
7. Разработка новых мероприятий.

•• Главный Следящий за РП••
Назначается на должность спец.администратором.
Разрешается 1 помощник: Помощник ГС за РП.
Обязанности:
1. Следить за РП; организовывать каждый день минимум 2 глобальных рп.
2. Поддерживать уровень РП на сервере.
3. Обучать и контролировать лидеров о соблюдении РП.
4. Помогать новым игрокам адаптироваться в РП режим.
5. Следить и контролировать чат на предмет нарушения МГ.
6. Докладывать о нарушениях со стороны администрации, принимающей участия в РП.
7. Предлагать креативные идеи по созданию технических улучшений для повышения уровня РП режима.
8. Создавать и размещать статьи в свободной группе о времени проведения РП или презентовать уже проведённые
9. Помогать игрокам в создании РП биографии и поддержании образа ролевого режима
10. Обучать и проводить повышение квалификации на знание РП истории фракций и их роли в штате.


•• ГС гос; ГС гетто; ГС мафий .

Назначаются куратором, спец.админами; создателями;
Разрешается по 5 помощников: Помощник ГС.
и 2 заместителя : Заместитель ГС.
Обязанности:
1. Выбор и назначение лидеров фракций
2. Ведение отчётов о назначении и снятии лидеров, а также о проделанной работе
3. Быстрое реагирование и решение жалоб на лидеров.
4. Организационный контроль фракций
5. Создание, редактирование и контроль за соблюдением правил в пределах своей области управления
6. Обучение и помощь лидерам.
7. Поиск, назначение и контроль следящих за областью управления
8. Повышение квалификации администраторов находящихся в области управления
9. Решение конфликтных ситуаций в области управления
10. Проведение собраний у лидерского состава для проверки знаний и обязанностей.
11. Помощь в поддержании уровня РП режима.
12. Модерация идей по улучшению области управления
13. Выявление и составление отчёта о нахождении технических неисправностей в области управления
14. Своевременный доклад о возможных угрозах или негативном влиянии на область управления со стороны других администраторов.
15. Ведение форума в области своего управления.
16. Выполнение прямых поручений Куратора, Спец.Админа или Создателя]]
c3 = [[
Правила выдачи КПЗ(jail/prison):

DM - Prison/Jail 10 мин .
DM администратора - Prison/Jail 10 мин.
DB - Prison/Jail 10 мин.
SK - Prison/Jail 10 мин.
MG - бан чата 10 мин.
Помеха - Jail минута
NonRp - 10 min
Гос.В гетто - jail 10 мин(Исключение : Гос.группой от 2 человек, погоня или под прикрытием)
Срыв набора - 10 мин.

Правила выдачи увольнения:

TK - увольнение
Нонрп ник - увольнение
NonRp - увольнение

Правила выдачи кика:

Помеха спавну - кик
Nonrp - Kick

Правила выдачи варна:

Уход в АФК от Наказания - warn
NonRp - Warn 
Соучастие - варн

Правила выдачи мута:

Оск.Администратора - 15 мин.
Оскорбление - 10 мин.
Caps lock - 5 мин.

Правила выдачи бана:
Реклама - бан навсегда + ip 
Слив - бан навсегда + ip
Создания аккаунтов для сливов - бан навсегда + ip
Читы - 14 дней
Неадекват - 3 дня
Оскорбление Родных - 7 дней
Оск.Ник/Фейк ник - sban(бан навсегда)]]
    file1 = io.open('moonloader/Admin Tools/Прочее/Запрещено админам.txt', 'w')
    file1:write(c1)
    file1:close()
    file2 = io.open('moonloader/Admin Tools/Прочее/Иерархия Админов.txt', 'w')
    file2:write(c2)
    file2:close()
    file3 = io.open('moonloader/Admin Tools/Прочее/Правила Наказаний.txt', 'w')
    file3:write(c3)
    file3:close()
end

function RegisterCommands()
    if Load_Config.Recon.Actived == true then
        sampRegisterChatCommand('re', recon_)
        sampRegisterChatCommand('iroff', recon_off)
    end
    sampRegisterChatCommand('veh', veh)
    sampRegisterChatCommand('gg', give_gun)
    sampRegisterChatCommand('gs', check_stats)
    sampRegisterChatCommand('bcheat', ban_cheat)
    sampRegisterChatCommand('bnead', ban_neadekvat)
    sampRegisterChatCommand('jdm', jail_dm)
    sampRegisterChatCommand('jsk', jail_sk)
    sampRegisterChatCommand('mcaps', mute_caps)
    sampRegisterChatCommand('mosk', mute_osk)
    sampRegisterChatCommand('moska', mute_oskAdm)
    sampRegisterChatCommand('mmg', mute_mg)
    sampRegisterChatCommand('pma', pma)
    sampRegisterChatCommand('at', function() main_window_state.v = not main_window_state.v end)
    sampRegisterChatCommand('sh', cmd_setHp)
    sampRegisterChatCommand('aa', function () sampSendChat('/admins') end)
    sampRegisterChatCommand('t', function () sampSendChat('/time') sampAddChatMessage(os.date( "Время на вашем компьютере:{CCFF00}%H:%M:%S{FFFFFF} | Вы отыграли:{CCFF00}"..(FormatTime(os.clock(), os.time()))), -1) end)
    sampRegisterChatCommand('sp', cmd_setSp)
    sampRegisterChatCommand('glog', cmd_getlogs)
    sampRegisterChatCommand('gt', cmd_geton)
    sampRegisterChatCommand('gip', cmd_getip)
    sampRegisterChatCommand('gi', cmd_get)
    sampRegisterChatCommand('/recon', recconect)
    sampRegisterChatCommand('oCaps', offtopCaps)
    sampRegisterChatCommand('oMat', offtopMat)
    sampRegisterChatCommand('oofftop', cmd_offtop)
    sampRegisterChatCommand('checkplayers', cmd_checkPlayers)
    sampRegisterChatCommand('zametki', function() sampAddChatMessage('{66CCFF}Заметка:', -1)
    tbl = {}
        for line in io.lines(getWorkingDirectory().."\\Admin Tools\\Заметки.txt") do
            table.insert(tbl,line)
        end
        for k,v in pairs(tbl) do
            sampAddChatMessage(u8:decode('{66CCFF}'..v), -1)
        end
    end)
    sampRegisterChatCommand('sb', function()
                lua_thread.create(function()
        BinderFile = io.open('moonloader/Admin Tools/Биндер.txt', 'r')
            for line in BinderFile:lines() do
                sampSendChat(u8:decode(line))
                wait(BinderWait.v)
            end
        end)
    end)
    sampRegisterChatCommand('damage', function()
        var = not var 
        if var then
        Load_Config.Options.damageActived = true
                PushMessage('[Damage] Включено')
        else
            Load_Config.Options.damageActived = false
                    PushMessage('[Damage] Выключено')
            end
        end)
    sampRegisterChatCommand('tr', function()
        var = not var 
            if var then
            traicers = true
                PushMessage('[Трейсер Пуль] Включено')
            else
                 traicers = false
                PushMessage('[Трейсер Пуль] Выключено')
            
        end
    end)
    sampRegisterChatCommand('fr', function(param)
        id = tonumber(param)
        if id == nil then PushMessage('(?) Введите /fr [id игрока]') return end
        sampSendChat('/freeze '..id)
    end)
    sampRegisterChatCommand('unfr', function(param)
        id = tonumber(param)
         if id == nil then PushMessage('(?) Введите /unfr [id игрока]') return end
        sampSendChat('/unfreeze '..id)
    end)
end

function imgui.ToggleButton(str_id, bool)
   local rBool = false

   if LastActiveTime == nil then
      LastActiveTime = {}
   end
   if LastActive == nil then
      LastActive = {}
   end

   local function ImSaturate(f)
      return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
   end
 
   local p = imgui.GetCursorScreenPos()
   local draw_list = imgui.GetWindowDrawList()

   local height = imgui.GetTextLineHeightWithSpacing() + (imgui.GetStyle().FramePadding.y / 2)
   local width = height * 1.55
   local radius = height * 0.50
   local ANIM_SPEED = 0.15

   if imgui.InvisibleButton(str_id, imgui.ImVec2(width, height)) then
      bool.v = not bool.v
      rBool = true
      LastActiveTime[tostring(str_id)] = os.clock()
      LastActive[str_id] = true
   end

   local t = bool.v and 1.0 or 0.0

   if LastActive[str_id] then
      local time = os.clock() - LastActiveTime[tostring(str_id)]
      if time <= ANIM_SPEED then
         local t_anim = ImSaturate(time / ANIM_SPEED)
         t = bool.v and t_anim or 1.0 - t_anim
      else
         LastActive[str_id] = false
      end
   end

   local col_bg
   if imgui.IsItemHovered() then
      col_bg = imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.FrameBgHovered])
   else
      col_bg = imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.FrameBg])
   end

   draw_list:AddRectFilled(p, imgui.ImVec2(p.x + width, p.y + height), col_bg, height * 0.5)
   draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.0), p.y + radius), radius - 1.5, imgui.GetColorU32(bool.v and imgui.GetStyle().Colors[imgui.Col.ButtonActive] or imgui.GetStyle().Colors[imgui.Col.Button]))

   return rBool
end

-- rED 0.65, 0.26, 0.26, 0.83
-- BLACK 0.00, 0.00, 0.00, 1.00

-- функции к команд

function cmd_checkPlayers()
    players = getAllChars()
    sampAddChatMessage('Игроки в зоне стрима:', -1)
    for k, v in pairs(players) do
        nick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(v)))
        ped, id = sampGetPlayerIdByCharHandle(v)
        AfkResult = sampIsPlayerPaused(v)
        NpcResult = sampIsPlayerNpc(v)
        color = sampGetPlayerColor(v)
        if AfkResult then afk = 'Да' else afk = 'Нет' end
        if NpcResult then npc = 'Да' else npc = 'Нет' end           
             sampAddChatMessage(nick..'['..id..'] | Afk:'..afk..' | Нпс:'..npc..' | Skin:'..getCharModel(v)..' | LVL:'..sampGetPlayerScore(v)..' | Ping:'..sampGetPlayerPing(v), color)
    end
end

function cmd_setHp(arg)
    if #arg == 0 then PushMessage('(?) Введите /sh [ид игрока] [уроверь хп]') return end
    var1,var2 = string.match(arg, "(.+) (.+)") 
            sampSendChat('/sethp '..var1..' '..var2)
end

function recconect(seconds)
    if #seconds == 0 then PushMessage('Введите //recon [секунд]') return end
    local seconds = tonumber(seconds)
    if seconds <= 60 and seconds >= 1 then
    lua_thread.create(function()
        sampDisconnectWithReason(quit)
            wait(seconds * 1000) 
            sampSetGamestate(1)
        end)
else
    PushMessage('Ошибка\nНельзя поставить '..seconds..'!\n(Пишите от 1 до 60 секунд)')
    end
end

function cmd_get()
    local x, y, z = getCharCoordinates(Pped)
    local res, id = sampGetPlayerIdByCharHandle(playerPed)
       local animid = sampGetPlayerAnimationId(id)
    local animname, animfile = sampGetAnimationNameAndFile(animid)
    local weapon = getCurrentCharWeapon(Pped)
    local weap = getweaponname(weapon)
    sampAddChatMessage('_____________Персонаж_____________', -1)
        sampAddChatMessage('Ваши координаты:{CCCCCC}X:'..math.floor(x)..' | Y:'..math.floor(y)..' | Z:'..math.floor(z), -1)
            sampAddChatMessage('ХП:{FF0000}'..getCharHealth(Pped), -1)
                sampAddChatMessage('Броня:{999999}'..getCharArmour(Pped), -1)
                    sampAddChatMessage('Денег:{339900}'..getPlayerMoney(Pped), -1)
                        sampAddChatMessage('Пинг:{FFFF00}'..sampGetPlayerPing(id), -1)
                            sampAddChatMessage('Ник:{9999CC}'..sampGetPlayerNickname(id), -1)
                                sampAddChatMessage('id:{3399FF}'..id, -1)
                                    sampAddChatMessage('Skin:{00CC99}'..getCharModel(Pped), -1)
                                        sampAddChatMessage('Оружие:{CC6600}'..weap, -1)
                                            sampAddChatMessage('Скорость:'..math.floor(getCharSpeed(Pped)), -1)
                                                sampAddChatMessage(string.format("Анимация:Name: {996666}%s {FFFFFF}| id: {996666}%d", animfile, animid), -1)
    sampAddChatMessage('_____________Транспорт_____________', -1)
        if isCharInAnyCar(PLAYER_PED) then
            local car = storeCarCharIsInNoSave(PLAYER_PED)
            local speed_car = getCarSpeed(car)
            sampAddChatMessage('ХП:{FF0000}'..getCarHealth(car), -1)
                sampAddChatMessage('Скорость:{99FFCC}'..math.floor(speed_car), -1)
                    sampAddChatMessage('id транспорта:{9966FF}'..getCarModel(car), -1)
                        sampAddChatMessage(string.format("Цвет:{009999}%d {FFFFFF}& {009999}%d", getCarColours(car)), -1)
        else
            sampAddChatMessage('Вы не сидите в транспорте', -1)
        end
end

function pma(id)
    if #id == 0 then PushMessage('(?) Введите /pma [ид игрока]') return end
        local result = sampIsPlayerConnected(id)
        if not result then
            PushMessage("[!] Игрок с id "..id..' нет в сети!')
    else
        sampSendChat('/pm '..id..' Удачной игры на сервере Gold Role Play!')
        end
end

function cmd_setSp(id)
    if #id == 0 then PushMessage('(?) Введите /sp [ид игрока]') return end
        local result = sampIsPlayerConnected(id)
        if not result then
            PushMessage("[!] Игрок с id "..id..' нет в сети!')
    else
        sampSendChat('/setsp '..id)
        end
end

function cmd_getlogs(id)
    if #id == 0 then PushMessage('(?) Введите /glog [ид игрока]') return end
     local result = sampIsPlayerConnected(id)
        if not result then
                PushMessage("[!] Игрок с id "..id..' нет в сети!')
    else
            sampSendChat('/getlogs '..nick)
    end
end

function cmd_geton(id)
    if #id == 0 then PushMessage('(?) Введите /gt [ид игрока]') return end
        local result = sampIsPlayerConnected(id)
            if not result then
                PushMessage("[!] Игрок с id "..id..' нет в сети!')
    else
        nick = sampGetPlayerNickname(id)
        sampSendChat('/geton '..nick)
    end
end

function check_stats(id)
    if #id == 0 then PushMessage("(?) Напишите /gs [ид игрока]") return end
        local result = sampIsPlayerConnected(id)
        if not result then
            PushMessage("[!] Игрок с id "..id..' нет в сети!')
    else
        sampSendChat('/getstats '..id)
    end
end

function give_gun(id)
    if #id == 0 then 
        PushMessage("(?) Напишите /gg [ид игрока] [ид оружие]") 
    else
        var1,var2 = string.match(id, "(.+) (.+)")
            sampSendChat('/givegun '..var1..' '..var2..' 9999')
    end
end

function veh(arg)
    if #arg == 0 then PushMessage('(?) Введите /veh [ид машины]') return end
        color = Load_Config.info.CarColor
        lua_thread.create(function()
        sampSendChat('/veh '..arg..' '..color..' '..color)
        wait(20)
            sampSendChat('/atune')  
        end)
end

function cmd_getip(cl)
    if #cl == 0 then PushMessage('(?) Введите /gip [ip адрес | ip адрес]') return end
    ips = {}
    for word in string.gmatch(cl, "(%d+%p%d+%p%d+%p%d+)") do
        table.insert(ips, { query = word })
    end
    if #ips > 0 then
        data_json = cjson.encode(ips)
        asyncHttpRequest(
            "POST",
            "http://ip-api.com/batch?fields=25305&lang=ru",
            { data = data_json },
            function(response)
                local rdata = cjson.decode(u8:decode(response.text))
                local text = ""
                for i = 1, #rdata do
                    if rdata[i]["status"] == "success" then
                        local distances =
                            distance_cord(
                                rdata[1]["lat"],
                                rdata[1]["lon"],
                                rdata[i]["lat"],
                                rdata[i]["lon"]
                            )
                        text =
                            text .. string.format(
                                "\n{FFF500}IP - {FF0400}%s\n{FFF500}Страна -{FF0400} %s\n{FFF500}Город -{FF0400} %s\n{FFF500}Провайдер -{FF0400} %s\n{FFF500}Растояние -{FF0400} %d  \n\n",
                                rdata[i]["query"],
                                rdata[i]["country"],
                                rdata[i]["city"],
                                rdata[i]["isp"],
                                distances
                            )
               end
                end
                if text == "" then
                    text = " \n\t{FFF500}Ничего не найдено"
                end
                showdialog("Информация о IP", text)
            end,
            function(err)
                showdialog("Информация о IP", "Произошла ошибка \n" .. err)
            end
        )
    end
end
function ban_cheat(id)
    if #id == 0 then PushMessage("(?) Введите /bcheat [ид игрока]") return end
    local result = sampIsPlayerConnected(id)
        if not result then
            PushMessage("[!] Игрок с id "..id..' нет в сети!')
    else
        sampSendChat('/ban '..id..' 14 Cheat')
    end
end

function ban_neadekvat(id)
        if #id == 0 then PushMessage("(?) Введите /bnead [ид игрока]") return end
    local result = sampIsPlayerConnected(id)
        if not result then
            PushMessage("[!] Игрок с id "..id..' нет в сети!')
    else
        sampSendChat('/ban '..id..' 7 Неадекват')
    end
end

function mute_caps(id)
    if #id == 0 then PushMessage('(?) Введите /mcaps [ид игрока]') return end
    local result = sampIsPlayerConnected(id)
        if not result then
            PushMessage("[!] Игрок с id "..id..' нет в сети!')
    else
        local nick = sampGetPlayerNickname(id)
            sampSendChat('/mute '..id..' 5 CapsLock')
    end
end

function mute_osk(id)
    if #id == 0 then PushMessage('(?) Введите m/osk [ид игрока]') return end
    local result = sampIsPlayerConnected(id)
        if not result then
            PushMessage("[!] Игрок с id "..id..' нет в сети!')
        else
            sampSendChat('/mute '..id..' 10 Оск.')
    end
end

function mute_oskAdm(id)
    if #id == 0 then PushMessage('(?) Введите /moska [ид игрока]') return end
    local result = sampIsPlayerConnected(id)
        if not result then
            PushMessage("[!] Игрок с id "..id..' нет в сети!')
        else
            sampSendChat('/mute '..id..' 10 Оск.Администрации')
    end
end

function mute_mg(id)
    if #id == 0 then PushMessage('(?) Введите /moska [ид игрока]') return end
    local result = sampIsPlayerConnected(id)
        if not result then
            PushMessage("[!] Игрок с id "..id..' нет в сети!')
        else
            sampSendChat('/mute '..id..' 10 МГ')
    end
end

function jail_dm(id)
    if #id == 0 then PushMessage('(?) Введите /jdm [ид игрока]') return end
    local result = sampIsPlayerConnected(id)
        if not result then
                PushMessage("[!] Игрок с id "..id..' нет в сети!')
    else
            sampSendChat('/jail '..id..' 10 DM')
    end
end

function jail_sk(id)
    if #id == 0 then PushMessage('(?) Введите /jsk [ид игрока]') return end
    local result = sampIsPlayerConnected(id)
        if not result then
            PushMessage("[!] Игрок с id "..id..' нет в сети!')
    else
            sampSendChat('/jail '..id..' 10 SK')
    end
end

function offtopCaps(id)
    if #id == 0 then PushMessage("(?) Напишите /offtopCaps [ид игрока] ") return end
        local result = sampIsPlayerConnected(id)
        if not result then
            PushMessage("[!] Игрок с id "..id..' нет в сети!')
    else
        sampSendChat('/offtop '..id..' 5 CapsLock in Report')
    end
end

function offtopMat(id)
    if #id == 0 then PushMessage("(?) Напишите /offtopMat [ид игрока] ") return end
        local result = sampIsPlayerConnected(id)
        if not result then
                PushMessage("[!] Игрок с id "..id..' нет в сети!')
    else
        sampSendChat('/offtop '..id..' 10 Mat in Report')
    end
end

function cmd_offtop(id)
    if #id == 0 then PushMessage("(?) Напишите /offtop [ид игрока] ") return end
        local result = sampIsPlayerConnected(id)
        if not result then
            PushMessage("[!] Игрок с id "..id..' нет в сети!')
    else
        sampSendChat('/offtop '..id..' 20 Offtop in Report')
    end
end

function recon_(id)
    if #id == 0 then PushMessage("(?) Напишите /re [ид игрока] ") return end
        local result = sampIsPlayerConnected(id)
        if not result then
            PushMessage("[!] Игрок с id "..id..' нет в сети!')
    else
        sampSendChat('/re '..id)
            PushMessage("[Imgui Recon] Вы вошли в рекон за "..id.." ID\n(выключить /iroff)")
          Load_Config.Recon.ReconID = id
                inicfg.save(Load_Config, Direct_Ini)
        recon.v = true
        recon_infa_player.v = true
    end
end

function recon_off()
        PushMessage("[Imgui Recon] Вы закрыли imgui рекон")
    recon.v = false
        recon_infa_player.v = false
            imgui.ShowCursor = false
end

-- sampev 

function sampev.onServerMessage(color, text)
    chatlog = io.open(getFileName(), "a+")
    chatTime =  '[' .. os.date("%d.%m.%y") .. "]"
    chatlog:write(chatTime .. ' ' .. text .. "\n")
    chatlog:close()
    nick = sampGetPlayerNickname(id)
    if string.find(text, nick) then
        if string.find(text, ' забанил') or string.find(text, ' выдал Warn') or string.find(text, ' посадил') or string.find(text, ' кикнул') or string.find(text, ' закрыл репорт') or string.find(text, ' заглушил') then
            if not doesFileExist('moonloader/Admin Tools/Логирование Наказаний.txt') then
                NewFile = io.open('moonloader/Admin Tools/Логирование Наказаний.txt', 'w') 
                NewFile:write('')
                NewFile:close()
            end
            file = io.open('moonloader/Admin Tools/Логирование Наказаний.txt', 'a+')
                chatTime = "[" .. os.date("*t").hour .. ":" .. os.date("*t").min .. ":" .. os.date("*t").sec .. " | " .. os.date("%d.%m.%y") .. "]"
                file:write(chatTime ..' '..text..' \n')
                file:close()
        end
    end
    nick = sampGetPlayerNickname(id)
    if string.find(text, nick) then
        if string.find(text, 'начинает свое дежурство!') then
        	--[[lua_thread.create(function()
        		wait(10000)
        		sampSendChat('/admins')]]
            if Load_Config.Options.Gm == true then sampSendChat('/agm') end
                if Load_Config.Options.togphone == true then sampSendChat('/togphone') end
                    if Load_Config.Options.WH == true then nameTagOn() end
                        if Load_Config.Options.Offgoto == true then sampSendChat('/agm') end
                            if Load_Config.Options.ChatSms == true then sampSendChat('/chatsms') end
        end
    end  
    if string.find(text, 'Репорт от:') then
        printStyledString('~y~REPORT ++', 2500, 2)
            if Load_Config.Options.Sound == true then
                addOneOffSound(0, 0, 0, 1085)
            end
    end
    if string.find(text, 'Игрок не авторизовался!') then
        recon.v = false
            recon_infa_player.v = false
            PushMessage("[!] Игрок не авторизовался")
    end
    if string.find(text, 'Машина открыта!') then
        PushMessage('[ALOCK] Машина окрыта!')
            return false
    end
    if string.find(text, 'Машина закрыта!') then
        PushMessage('[ALOCK] Машина закрыта!')
            return false
    end
    if string.find(text, 'Вы указали свой ') then
        recon.v = false
            recon_infa_player.v = false
            PushMessage("[!] Вы указали свой ID")   
    end
    if string.find(text, 'Нельзя следить за админом старше ') then
        recon.v = false
            recon_infa_player.v = false
                PushMessage('[!] Нельзя следить за админом старше вас!')
    end
    if string.find(text, 'Вам никто не предлагал бросить кости!') then return false end
    for i = 0, sampGetMaxPlayerId() do
        if sampIsPlayerConnected(i) and not sampIsPlayerNpc(i) then
            nick = sampGetPlayerNickname(i)
    if string.find(text, 'создал объект под номером') or string.find(text, 'удалил объект под номером') or string.find(text, ' взял(а) себе комплект оружия') or string.find(text, 'создал авто') or string.find(text, 'удалил объект под номером') or string.find(text, '] ответил') or string.find(text, 'тп к себе админа') or string.find(text, 'тп к игроку') or string.find(text, 'тп к себе игрока') or string.find(text, 'изменил скин игроку') then
--[[ Зам.Гл.Следящего за Гетто {FFFFFF}Enzo_Valdez[54]: Ярик 57 ид плз
Ricky_Terner[34] начал(а) следить за Benjamin_Hightower[74]
]]
        sampAddChatMessage('{009933}[A] {FF9900}'..text, -1)
        return false 
            end
        end
    end
    --[[if text:find('АФК') then
        local time = text:match('Вы стояли в АФК: (.+)')
        sampAddChatMessage('AFK:'..time, -1)
    end -- вырезать минуты:секунды
    ]] 
end

function sampev.onPlayerJoin(id, color, isNpc, nickname)
    table.insert(LogConnect_Text, '['..os.date('%H:%M:%S')..']'..nickname.." "..id.." ID\n подключился к серверу")
        if ToggleButton_CheckConnected.v then
            if Load_Config.Options.Message == true then
                PushMessage('['..os.date('%H:%M:%S')..']'..nickname.." "..id.." ID\n подключился к серверу")
                if Load_Config.Options.Sound == true then
                    addOneOffSound(0, 0, 0, 1150)
                end
            else
                sampAddChatMessage(tag..'[Connected] '..nickname.." "..id.." ID {00FF00}подключился {FFFFFF}к серверу", -1)
                if Load_Config.Options.Sound == true then
                    addOneOffSound(0, 0, 0, 1150)
                end
            end
        end
end

function sampev.onPlayerQuit(id, reason)
    nick = sampGetPlayerNickname(id)
    table.insert(LogConnect_Text, '['..os.date('%H:%M:%S')..']'..nick.." "..id.." ID\n Отключился от сервера")
        if ToggleButton_CheckConnected.v then
            if Load_Config.Options.Message == true then
                PushMessage('['..os.date('%H:%M:%S')..']'..nick.." "..id.." ID\n Отключился от сервера")
                if Load_Config.Options.Sound == true then
                    addOneOffSound(0, 0, 0, 1150)
                end
            else
                sampAddChatMessage(tag..'[Connected] '..nick.." "..id.." ID {FF0000}Отключился {FFFFFF}от сервера", -1)
                if Load_Config.Options.Sound == true then
                    addOneOffSound(0, 0, 0, 1150)
                end
            end
        end
end

function sampev.onSendTakeDamage(dmgid, damage, weapon, bodypart)
    lua_thread.create(function()
    if Load_Config.Options.damageActived == true then
    result = sampIsPlayerConnected(dmgid)
        if result then
            isPed, pPed = sampGetCharHandleBySampPlayerId(dmgid)
                if isPed and doesCharExist(pPed) then
                    if not isCharInAnyCar(pPed) then
                            nick = sampGetPlayerNickname(dmgid)
                            weap = getweaponname(weapon)
                            sampAddChatMessage(tag..'{FF0000}[Damage] {FFFFFF}Nick:'..nick..' ['..dmgid..'] -> Оружие:'..weap..' | Damage:'..math.floor(damage), -1)
                    end
                end
        end
    end
    wait(2500)
    end)
    if Load_Config.Options.Sound == true then
        addOneOffSound(0, 0, 0, 1190)
    end
end

function sampev.onBulletSync(playerid, data)
    if traicers == true  then
        if data.target.x == -1 or data.target.y == -1 or data.target.z == -1 then
            return true
                    end
                    BulletSync.lastId = BulletSync.lastId + 1
                    if BulletSync.lastId < 1 or BulletSync.lastId > BulletSync.maxLines then
                        BulletSync.lastId = 1
                    end
                    local id = BulletSync.lastId
                    BulletSync[id].enable = true
                    BulletSync[id].tType = data.targetType
                    BulletSync[id].time = os.time() + 15
                    BulletSync[id].o.x, BulletSync[id].o.y, BulletSync[id].o.z = data.origin.x, data.origin.y, data.origin.z
                    BulletSync[id].t.x, BulletSync[id].t.y, BulletSync[id].t.z = data.target.x, data.target.y, data.target.z
                end
            end

function sampev.onShowDialog(id, style, caption, b1, b2, text)
    if Load_Config.General.Active == true then
        if string.find(text, 'Добро пожаловать на проект') then
lua_thread.create(function()
    wait(1500)
        sampSetCurrentDialogEditboxText(Load_Config.General.LoginAccount)
            setVirtualKeyDown(key.VK_RETURN,true)
                wait(20)
                    setVirtualKeyDown(key.VK_RETURN,false)
                        wait(800)
                            sampSetCurrentDialogEditboxText(Load_Config.General.LoginAdminPanel)
                                setVirtualKeyDown(key.VK_RETURN,true)
                                    wait(20)
                                        setVirtualKeyDown(key.VK_RETURN,false)
                                wait(250)
                            setVirtualKeyDown(key.VK_ESCAPE,true)
                        wait(20)
                    setVirtualKeyDown(key.VK_ESCAPE,false)
                PushMessage('Вы вошли в свой аккаунт')
            end)
        end
    end
end

-- imgui

function imgui.OnDrawFrame()
    if Checker.v then
        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(Load_Config.Checker.X, Load_Config.Checker.Y), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(200, 200), imgui.Cond.FirstUseEver)
        imgui.Begin('', Checker.v, NoTitleBar)
        tbl = {}
        for line in io.lines(getWorkingDirectory().."\\Admin Tools\\Чекер.txt") do
            table.insert(tbl,line)
        end
        for k,v in pairs(tbl) do
            id = sampGetPlayerIdByNickname(v)
               if id then imgui.Text(u8(v..' ['..id..'] в сети')) 
                imgui.Separator()
            else
                imgui.Text(u8(v..' не в сети')) end
        end
        imgui.End()
    end
  if main_window_state.v then
    local sw, sh = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(750, 500), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.Begin(u8'Admin Tools', main_window_state, imgui.WindowFlags.NoResize)
    imgui.BeginChild('#a', imgui.ImVec2(200, 400), true)
        FontSize(1.1)
            if airbrk then
                 imgui.TextColored(imgui.ImVec4(0.00, 1.00, 0.00, 1.00), u8'AirBreak')
            else
                imgui.TextColored(imgui.ImVec4(1.00, 0.00, 0.00, 1.00), u8'AirBreak')
        end
            if WallHackNameTag then
                 imgui.TextColored(imgui.ImVec4(0.00, 1.00, 0.00, 1.00), u8'WallHack Name')
            else
                imgui.TextColored(imgui.ImVec4(1.00, 0.00, 0.00, 1.00), u8'WallHack Name')
            end
            if WallHackSkeletal then
                 imgui.TextColored(imgui.ImVec4(0.00, 1.00, 0.00, 1.00), u8'WallHack Skeletal')
            else
                imgui.TextColored(imgui.ImVec4(1.00, 0.00, 0.00, 1.00), u8'WallHack Skeletal')
            end
            if traicers then
                 imgui.TextColored(imgui.ImVec4(0.00, 1.00, 0.00, 1.00), u8'Трейсер Пуль')
            else
                imgui.TextColored(imgui.ImVec4(1.00, 0.00, 0.00, 1.00), u8'Трейсер Пуль')
            end
            imgui.SameLine() imgui.TextQuestion('(?)', u8'Активировать/Деактивировать - /tr')
            if Load_Config.Options.damageActived then
                 imgui.TextColored(imgui.ImVec4(0.00, 1.00, 0.00, 1.00), u8'Damage')
            else
                imgui.TextColored(imgui.ImVec4(1.00, 0.00, 0.00, 1.00), u8'Damage')
            end
            imgui.SameLine() imgui.TextQuestion('(?)', u8'Активировать/Деактивировать - /damage\n(i) Получает информацию об игроке который начинает стрелять по вам')
        FontSize(1.0)
        imgui.Separator()
        if imgui.Selectable(u8' Правила наказаний', false) then rules_for_admins.v = not rules_for_admins.v end 
        if imgui.Selectable(u8" Журнал подключений", false) then page_id = 'log connected' end
        if imgui.Selectable(u8" Оружие", false) then page_id = 'admin gun' end
        if imgui.Selectable(u8" Команды / Клавишы >>", false) then var = not var if var then command_ = '1' else command_ = '0' end end
            if command_ == '1' then
                if imgui.Selectable(u8"   Клавишы", false) then page_id = 'keys' end
                if imgui.Selectable(u8"   Команды", false) then page_id = 'command' end
            end
        if imgui.Selectable(u8" Настройки >>", false) then var = not var if var then settings_ = '1' else settings_ = '0' end end
            if settings_ == '1' then
                if imgui.Selectable(u8"   Плагин", false) then page_id = 'settings' end
                if imgui.Selectable(u8"   Автологин", false) then page_id = 'settings_2' end
                if imgui.Selectable(u8"   Imgui рекон", false) then page_id = 'settings_3' end
                if imgui.Selectable(u8'   Чекер', false) then page_id = 'settings_5' end
                if imgui.Selectable(u8'   Ответы на репорты', false) then page_id = 'settings_6' end
            end
        if imgui.Selectable(u8' Заметки', false) then page_id = 'zametki' end
        if imgui.Selectable(u8' Биндер', false) then page_id = 'binder' end       
        if imgui.Selectable(u8" Домой", false) then page_id = 'home' end
    imgui.EndChild()
        imgui.SameLine(235)
         imgui.BeginChild('#okno', imgui.ImVec2(525, 450))
            if page_id == 'home' then -- домой
                FontSize(1.2) imgui.Text(u8' - Домой') FontSize(1.0) imgui.Separator()
                imgui.Text(u8'Автор:Vespan | VK:idv3sp4n | Discord:Vespan#8544')
                        if imgui.IsItemClicked() then
                            setClipboardText('idv3sp4n | Vespan#8544')
                                PushMessage('Вы копировали связи с автором(ВК/Discord)')
                        end
                        imgui.Text(u8'Помощник:Vlad Fedosyuk | radmir005 | Discord:Нету')
                        if imgui.IsItemClicked() then
                            setClipboardText('radmir005')
                                PushMessage('Вы копировали id вк помощника')
                        end
                        imgui.Text(u8'Discord Admin Tools"a:https://discord.gg/EkahEZV')
                            if imgui.IsItemClicked() then
                                setClipboardText('https://discord.gg/EkahEZV')
                                    PushMessage('Вы скопировали ссылку на discord сервер Admin Tools"a')
                            end
                        imgui.Separator()
                            imgui.Text(u8'Последний заход в игру:'..Load_Config.info.LastConnect)
                        imgui.Text(u8'Вы отыграли:'..FormatTime(os.clock()))
             elseif page_id == 'zametki' then -- заметки
                FontSize(1.2) imgui.Text(u8' - Заметки') FontSize(1.0) imgui.Separator()
                    if not doesFileExist('moonloader/Admin Tools/Заметки.txt') then 
                        NewFile = io.open('moonloader/Admin Tools/Заметки.txt', 'w')
                        NewFile:write(u8'Этот .txt файл был создан')
                        NewFile:close()
                    end
                    if redakt_zametki == '0' then
                    tbl = {}
                        for line in io.lines(getWorkingDirectory().."\\Admin Tools\\Заметки.txt") do
                            table.insert(tbl,line)
                        end
                        for k,v in pairs(tbl) do
                            imgui.Text(v)
                        end
                    if imgui.Button(u8'Редактировать') then redakt_zametki = '1' end
                    elseif redakt_zametki == '1' then
                        imgui.InputTextMultiline('', zametki, imgui.ImVec2(500, 250))
                            if imgui.Button(u8'Сохранить') then 
                                config = io.open("moonloader/Admin Tools/Заметки.txt", 'w')
                                    config:write(zametki.v)
                                    config:close()
                                    redakt_zametki = '0'
                            end
                            imgui.SameLine(150) 
                            if imgui.Button(u8'Очистить') then 
                                config = io.open("moonloader/Admin Tools/Заметки.txt", 'w')
                                config:write('')
                                config:close()
                                redakt_zametki = '0'
                            end
                            imgui.SameLine(350)
                            if imgui.Button(u8'Удалить') then
                            redakt_zametki = '0'
                                os.remove('moonloader/Admin Tools/Заметки.txt')                            
                        end
                        imgui.SameLine() imgui.TextQuestion('(?)', u8'Удаляет файл "Заметки.txt" в папке Admin Tools')
                        imgui.TextDisabled(u8'Можно быстро посмотреть заметки командой </zametki>')
                    end
            elseif page_id == 'binder' then
                FontSize(1.2) imgui.Text(u8' - Биндер') FontSize(1.0) imgui.Separator() 
                    if not doesFileExist('moonloader/Admin Tools/Биндер.txt') then 
                        NewFile = io.open('moonloader/Admin Tools/Биндер.txt', 'w')
                        NewFile:write(u8'Этот .txt файл был создан')
                        NewFile:close()
                    end
                    if TextBind == '0' then
                    tbl = {}
                        for line in io.lines(getWorkingDirectory().."\\Admin Tools\\Биндер.txt") do
                            table.insert(tbl,line)
                        end
                        for k,v in pairs(tbl) do
                            imgui.Text(v)
                        end
                    imgui.Separator()
                    if imgui.Button(u8'Запустить') then
                        lua_thread.create(function()
                        BinderFile = io.open('moonloader/Admin Tools/Биндер.txt', 'r')
                            for line in BinderFile:lines() do
                                sampSendChat(u8:decode(line))
                                wait(BinderWait.v)
                            end
                       end)
                    end
                    imgui.SameLine() imgui.TextQuestion('(?)', u8'Можно активировать биндер через команду </sb> \n(start binder)')
                    if imgui.Button(u8'Редактировать') then TextBind = '1' end
                        elseif TextBind == '1' then
                            imgui.InputTextMultiline('', BinderLine, imgui.ImVec2(500, 250))
                            imgui.InputText(u8'Задержка биндера', BinderWait)
                                imgui.SameLine() imgui.TextQuestion('(?)', u8'1000 - 1 секунда\n1 - 1 мл. секунда\n10000 - 10 секунд')
                        if imgui.Button(u8'Сохранить') then
                            BinderFile = io.open('moonloader/Admin Tools/Биндер.txt', 'w')
                            BinderFile:write(BinderLine.v)
                            BinderFile:close() 
                            TextBind = '0' 
                        end
                        imgui.SameLine(150)
                        if imgui.Button(u8'Очистить биндер') then
                            BinderFile = io.open('moonloader/Admin Tools/Биндер.txt', 'w')
                            BinderFile:write('')
                            BinderFile:close() 
                            TextBind = '0' 
                        end
                        imgui.SameLine(350)
                        if imgui.Button(u8'Удалить') then
                            TextBind = '0'
                                os.remove('moonloader/Admin Tools/Биндер.txt')                            
                        end
                        imgui.SameLine() imgui.TextQuestion('(?)', u8'Удаляет файл "Биндер.txt" в папке Admin Tools')
                    end   
            elseif page_id == 'settings_3' then -- настройки рекона
                    FontSize(1.2)
                    imgui.Text(u8' - Настройка imgui рекона')
                    FontSize(1.0)
                    imgui.Separator()
                    imgui.Text(u8'Позиция imgui рекона:')
                    imgui.InputInt(u8':X', Recon_X)
                    imgui.InputInt(u8':Y', Recon_Y)
                    if imgui.Button(u8'Cохранить') then
                        Load_Config.Recon.X = Recon_X.v 
                        Load_Config.Recon.Y = Recon_Y.v 
                            if inicfg.save(Load_Config, Direct_Ini) then
                                saveConfig()
                                    PushMessage('Настройки успешно сохранены!')
                                else
                                    PushMessage('[!] Возникла ошибка при сохранение настроек')
                            end
                    end
                    imgui.SameLine(); imgui.TextQuestion('(?)', u8'Нужно сохранить,что-бы координаты сохранились в .ini файле\nПосле сохранение Admin Tools будет перезагружен')
                    imgui.Separator() imgui.Text(u8'Позиция imgui инфобара:')
                        imgui.InputInt(u8':X ', InfoBar_X)
                        imgui.InputInt(u8':Y ', InfoBar_Y)
                            if imgui.Button(u8'Сохранить') then
                                Load_Config.InfoBar.X = InfoBar_X.v 
                                Load_Config.InfoBar.Y = InfoBar_Y.v 
                                    if inicfg.save(Load_Config, Direct_Ini_Recon) then
                                        thisScript():reload()
                                            PushMessage('Настройки успешно сохранены!')
                                        else
                                            PushMessage('[!] Возникла проблема при сохранение настроек')
                                    end
                            end
                            imgui.SameLine(); imgui.TextQuestion('(?)', u8'Нужно сохранить,что-бы координаты сохранились в .ini файле\nПосле сохранение Admin Tools будет перезагружен')
                            imgui.ToggleButton('', ToggleButton_Recon)
                            imgui.SameLine() imgui.Text(u8'Включить/Отключить imgui рекон и инфобар')
            elseif page_id == 'settings_5' then
                if not doesFileExist('moonloader/Admin Tools/Чекер.txt') then 
                    File = io.open(path..'Чекер.txt', 'w')
                    File:write('')
                    File:close()
                end
                FontSize(1.2) imgui.Text(u8' - Чекер') FontSize(1.0) imgui.Separator()
                    imgui.InputTextMultiline(u8' - Добавить игроков', CheckerAdd)
                    if isKeyDown(key.VK_LSHIFT) then
                        if wasKeyPressed(key.VK_RETURN) then
                            File = io.open('moonloader/Admin Tools/Чекер.txt', 'w')
                            File:write(CheckerAdd.v)
                            File:close()
                            PushMessage('Вы успешно сохранили ники!')
                        end
                    end
                    imgui.InputInt(u8':X', Checker_X)
                    imgui.InputInt(u8':Y', Checker_Y)
                    imgui.ToggleButton('', ToggleButton_Checker)
                    imgui.SameLine() imgui.Text(u8'Включить/Выключить чекер')
                    if imgui.Button(u8'Сохранить') then
                        File = io.open('moonloader/Admin Tools/Чекер.txt', 'w')
                        File:write(CheckerAdd.v)
                        File:close()
                        Load_Config.Checker.X = Checker_X.v 
                        Load_Config.Checker.Y = Checker_Y.v 
                        saveConfig() 
                    end
                    imgui.TextDisabled(u8'Нажмите SHIFT + ENTER и вы сохраните ники\nдругие настройки вы не сохраните')
                    -- setClipboardText
                    imgui.Separator()
                        tbl = {}
                        for line in io.lines(getWorkingDirectory().."\\Admin Tools\\Чекер.txt") do
                            table.insert(tbl,line)
                        end
                        for k,v in pairs(tbl) do
                            id = sampGetPlayerIdByNickname(v)
                               if id then imgui.Text(u8(v..' ['..id..'] в сети')) else imgui.Text(u8(v..' не в сети')) end
                        end
            elseif page_id == 'settings_2' then -- настройка автологина
                FontSize(1.2) imgui.Text(u8' - Настройка автологина') FontSize(1.0) imgui.Separator()
                imgui.Text(u8'Пароль к основному аккаунту')
            imgui.InputText(u8'К осн.аккаунту', pass_osnova, imgui.InputTextFlags.Password)
            imgui.InputText(u8'Aдмин вход', pass_admin_panel, imgui.InputTextFlags.Password)
            if imgui.Button(u8'Сохранить') then
                Load_Config.General.LoginAdminPanel = pass_admin_panel.v 
                Load_Config.General.LoginAccount = pass_osnova.v 
                if inicfg.save(Load_Config, Direct_Ini) then
                    PushMessage('Пароль успешно сохранен!')
                end
            end
            if imgui.Button(u8'Пароли') then imgui.OpenPopup('Passwords') end
            imgui.ToggleButton('', ToggleButton_AutoLogin)
            imgui.SameLine() imgui.Text(u8'Отключить/Включить')
                if imgui.BeginPopupModal('Passwords', nil, NoTitleBar + NoResize) then
                    imgui.Text(u8'Ваш пароль к основному аккаунту:'..Load_Config.General.LoginAccount)
                    imgui.Text(u8'Ваш пароль к админ входу:'..Load_Config.General.LoginAdminPanel)
                    imgui.Separator()
                     if imgui.Button(u8'Закрыть') then imgui.CloseCurrentPopup() end
                     imgui.EndPopup()
                end
            imgui.TextDisabled(u8'[!] Если у вас будет включен пин-код,то автологин не будет работать! [!]')
            elseif page_id == 'settings' then -- настройки
                FontSize(1.2) imgui.Text(u8' - Настройка плагина') FontSize(1.0)
                imgui.Separator()
            if imgui.Button(u8'Перезагрузить', btn_size) then
                imgui.OpenPopup('Reload')
            end
            if imgui.BeginPopupModal('Reload', nil, NoResize + NoTitleBar) then
                imgui.Text(u8'Перезагрузить плагин?')
                    imgui.Separator()
                if imgui.Button(u8'Да') then reloadScripts() end
                imgui.SameLine(115)
                if imgui.Button(u8'Нет') then imgui.CloseCurrentPopup() end
                imgui.EndPopup()
            end
            if imgui.Button(u8'Отключить', btn_size) then
                imgui.OpenPopup('Off Plagin')
            end
            if imgui.BeginPopupModal('Off Plagin', nil, NoResize + NoTitleBar) then
                imgui.Text(u8'Отключить плагин?')
                    imgui.Separator()
                        if imgui.Button(u8'Да') then thisScript():unload() end
                        imgui.SameLine(150)
                        if imgui.Button(u8'Нет') then imgui.CloseCurrentPopup() end
                imgui.EndPopup()
            end
            if imgui.Button(u8'Получить координаты экрана', btn_size) then
                GetPosition = true
                    PushMessage('Нажмите в любое место экрана,что-бы получить координаты X и Y')
            end
            imgui.Separator()
            imgui.InputInt(u8' - Цвет машины', CarColor)
            imgui.SameLine() imgui.TextDisabled(u8'(/veh)')
            imgui.ToggleButton(u8'Push уведомление', ToggleButton_PushMessage)
            imgui.SameLine() imgui.Text(u8'Push Уведомления')
            imgui.ToggleButton('1', ToggleButton_Sound)
            imgui.SameLine() imgui.Text(u8'Звук при уведомлених')
            imgui.ToggleButton(' 2', ToggleButton_WHLine)
            imgui.SameLine() imgui.Text(u8'Линии от персонажа к игроку') imgui.SameLine() imgui.TextDisabled(' [WallHack Skeletal]')
            imgui.ToggleButton(' 3', ToggleButton_FastKey) imgui.SameLine()  imgui.Text(u8'Быстрые клавишы') imgui.SameLine() imgui.TextQuestion(u8'(?)', u8'Быстрые Клавишы\n3 - /a\n4 - /re\n5 - /alock')
            imgui.Separator()
            if imgui.ToggleButton('Выключать телефон', ToggleButton_togphone) then
                    sampSendChat('/togphone')
                end
                imgui.SameLine() imgui.Text(u8'Выключать телефон') imgui.SameLine() imgui.TextDisabled('(/togphone)')
                if imgui.ToggleButton('Выключать ТП', ToggleButton_offgoto) then
                    sampSendChat('/offgoto')   
                end
                imgui.SameLine() imgui.Text(u8'Выключать ТП') imgui.SameLine() imgui.TextDisabled('(/offgoto)')
                if imgui.ToggleButton('Включать ВХ', ToggleButton_Wh) then
                    var = not var
                        if var then
                                nameTagOn()
                        else
                                nameTagOff()
                        end
                end
                imgui.SameLine() imgui.Text(u8'Включать ВХ')
                if imgui.ToggleButton(u8'Включать GM(/agm)', ToggleButton_Gm) then
                    sampSendChat('/agm')
                end
                imgui.SameLine() imgui.Text(u8'Включать GM') imgui.SameLine() imgui.TextDisabled(u8'(/agm)')
                if imgui.ToggleButton(u8'Прослушка смс', ToggleButton_ChatSms) then
                    sampSendChat('/chatsms')
                end
                imgui.SameLine() imgui.Text(u8'Прослушка СМС') imgui.SameLine() imgui.TextDisabled('(/chatsms)')
                    imgui.Separator()
            elseif page_id == 'settings_6' then -- ответы на репорты
            	FontSize(1.2) imgui.Text(u8' - Ответы на репорты') FontSize(1.0) imgui.Separator()
            	imgui.InputText(u8'Ответ 1', ReportOtvet1)
            	imgui.Text(u8('>> '..ReportOtvet.settings.otvet1))
            	imgui.Separator()
            	imgui.InputText(u8'Ответ 2', ReportOtvet2)
            	imgui.Text(u8('>> '..ReportOtvet.settings.otvet2))
            	imgui.Separator()
            	imgui.InputText(u8'Ответ 3', ReportOtvet3)
            	imgui.Text(u8('>> '..ReportOtvet.settings.otvet3))
            	imgui.Separator() 
            	imgui.InputText(u8'Ответ 4', ReportOtvet4)
            	imgui.Text(u8('>> '..ReportOtvet.settings.otvet4))
            	imgui.Separator()
            	if imgui.Button(u8'Сохранить', btn_size) then
            		    ReportOtvet.settings.otvet1 = ReportOtvet1.v
			        	ReportOtvet.settings.otvet2 = ReportOtvet2.v
			        	ReportOtvet.settings.otvet3 = ReportOtvet3.v
			        	ReportOtvet.settings.otvet4 = ReportOtvet4.v
            		if inicfg.save(ReportOtvet, '..\\Admin Tools\\Report Otvet.ini') then
            			PushMessage('Успешно!')
            		else
            			PushMessage('Ошибка*\n Возникла ошибка при сохранение ответов!')
            		end
            	end
            	imgui.TextDisabled(u8'Что?')
            	hint('Ответы для репортов,как пользоваться?\nНапишите свой ответ и нажмите "Сохранить"\nДальше,когда придёт репорт,вы нажимаите\nP - 1-4 (от 1 до 4 (1-4 это ответы)) и ваш ответ вставляется и нажимает ENTER!')
            elseif page_id == 'log connected' then -- журнал подключений
                FontSize(1.2) imgui.Text(u8' - Журнал подключений') FontSize(1.0) imgui.Separator()
                imgui.Separator()
                if imgui.Button(u8'Очистить журнал', btn_size) then LogConnect_Text = {} end
                imgui.ToggleButton('', ToggleButton_CheckConnected)
                imgui.SameLine() imgui.Text(u8'Показывать кто подключился/отключился в чат')
                imgui.Separator()
                        if #LogConnect_Text > 0 then
                            for k, v in pairs(LogConnect_Text) do
                                imgui.Text(u8(v))
                            end
                        else
                            imgui.Text(u8("Журнал пуст..."))
                        end
            elseif page_id == 'admin gun' then -- оружие
                FontSize(1.2) imgui.Text(u8' - Оружие') FontSize(1.0) imgui.Separator()
                if imgui.Button(u8'Взять компект оружия', btn_size) then
                    sampSendChat('/agun')
                end
                imgui.Separator()
                for i = 0, 18 do
                    if imgui.Button(u8'Оружие '..getweaponname(i), btn_size) then
                        sampSendChat('/givegun '..id..' '..i..' 999')
                    end
                end
                for i = 22, 46 do
                    if imgui.Button(u8'Оружие '..getweaponname(i), btn_size) then
                        sampSendChat('/givegun '..id..' '..i..' 999')
                    end
                end
                    imgui.Separator()
            elseif page_id == 'command' then -- команды
                FontSize(1.2) imgui.Text(u8' - Команды') FontSize(1.0) imgui.Separator()
                    imgui.TextColor(help_list_command)
            elseif page_id == 'keys' then -- клавишы
                FontSize(1.2) imgui.Text(u8' - Клавишы') FontSize(1.0) imgui.Separator()
                    imgui.TextColor(help_list_keys)
            end
        imgui.EndChild()
    imgui.End()
  end

--[[ цвета 
imgui.TextColored
imgui.ImVec4(1,0,0,1) - красный / red
imgui.ImVec4(0, 0, 1, 1) - синий / blue
imgui.ImVec4(0, 0.5, 0, 1.00) - зёленый / green
]]

    if rules_for_admins.v then
    CreateFile()
    imgui.SetNextWindowSize(imgui.ImVec2(900, 650), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'<<Правила>>', rules_for_admins, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + NoTitleBar)
        if imgui.Button(u8'Закрыть', btn_size) then rules_for_admins.v = false end
         FontSize(1.2) imgui.Text(u8'Правила Наказаний \n ') FontSize(1.0)
            tbl = {}
            for line in io.lines(getWorkingDirectory().."\\Admin Tools\\Прочее\\Правила Наказаний.txt") do
                table.insert(tbl,line)
            end
            for k,v in pairs(tbl) do
                imgui.Text(u8(v))
            end
            imgui.Separator()
             FontSize(1.2) imgui.Text(u8'Запрещено Админам \n ') FontSize(1.0)
            tbl = {}
            for line in io.lines(getWorkingDirectory().."\\Admin Tools\\Прочее\\Запрещено админам.txt") do
                table.insert(tbl,line)
            end
            for k,v in pairs(tbl) do
                imgui.Text(u8(v))
            end
            imgui.Separator()
            FontSize(1.2) imgui.Text(u8'Иерархия Админов \n ' ) FontSize(1.0)
            tbl = {}
            for line in io.lines(getWorkingDirectory().."\\Admin Tools\\Прочее\\Иерархия Админов.txt") do
                table.insert(tbl,line)
            end
            for k,v in pairs(tbl) do
                imgui.Text(u8(v))
            end
            imgui.Separator()
             FontSize(1.2) imgui.Text(u8'Правила Хелперам \n ' ) FontSize(1.0)
            imgui.Text(u8(rules_helperam))
        imgui.End()
    end

    if recon.v then
    local sw, sh = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(Recon_X.v, Recon_Y.v), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5)) 
    imgui.SetNextWindowSize(imgui.ImVec2(150, 275), imgui.Cond.FirstUseEver)
        imgui.Begin('Recon', recon, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar+ imgui.WindowFlags.ShowBorders) 
            if imgui.Button('PM ', btn_size) then
                sampSendChat('/pm '..Load_Config.Recon.ReconID..' Удачной вам игры на Gold-RP!')
            end
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(450)
                imgui.TextUnformatted(u8'Пожелает удачи игроку!')
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            if imgui.Button(u8'Заспавнить', btn_size) then
                 sampSendChat('/setsp '..Load_Config.Recon.ReconID)
              end
            if imgui.Button(u8'Дать ХП', btn_size) then
                sampSendChat('/sethp '..Load_Config.Recon.ReconID.. ' 100')
            end
            if imgui.Button('Kill', btn_size) then
                sampSendChat('/sethp '..Load_Config.Recon.ReconID.. ' 0')
            end
            if imgui.Button(u8'Get', btn_size) then 
                imgui.OpenPopup("Get")
            end
            if imgui.BeginPopupModal("Get", nil, NoTitleBar + NoResize) then
                imgui.Text(u8'Получить..') imgui.Separator()
                if imgui.Button(u8'Get Iwep') then
                    sampSendChat('/iwep '..ReconID)
                        imgui.CloseCurrentPopup()
                end
                imgui.SameLine()
                if imgui.Button(u8'Get Ip') then
                    sampSendChat('/getip '..ReconID)
                        imgui.CloseCurrentPopup()
                end
                imgui.SameLine()
                if imgui.Button('Get Stats') then
                    sampSendChat('/getstats '..ReconID) 
                        imgui.CloseCurrentPopup()
                end
                imgui.SameLine()
                if imgui.Button(u8'Закрыть') then imgui.CloseCurrentPopup() end
            imgui.EndPopup()
            end
            if imgui.Button('Next>>', btn_size) then
                ReconID = (ReconID + 1)
                    sampProcessChatInput('/re '..ReconID)
            end
            if imgui.Button('<<Back', btn_size) then
                ReconID = (ReconID - 1)
                    sampProcessChatInput('/re '..ReconID)
            end
            imgui.Separator()
            if imgui.Button(u8'OFF', btn_size) then
                recon.v = false
                    recon_infa_player.v = false
                    PushMessage("вы убрали imgui")
            end
            if imgui.Button(u8'On/Off InfoBar', btn_size) then
                var = not var
                    if var then
                        recon_infa_player.v = false
                    else
                        recon_infa_player.v = true
                    end
            end
                if imgui.Button(u8'help', btn_size) then
                    imgui.OpenPopup('helpRecon')
                end
                if imgui.BeginPopupModal('helpRecon', nil, NoTitleBar + NoResize) then
                    imgui.Text(u8'Помощь') imgui.Separator()
                        imgui.Text(u8(text_help_recon))
                    imgui.Separator()
                     if imgui.Button(u8'Закрыть') then imgui.CloseCurrentPopup() end
                     imgui.EndPopup()
                end
        imgui.End()
    end
    
    if recon_infa_player.v then
    local sw, sh = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(InfoBar_X.v, InfoBar_Y.v), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(200, 300), imgui.Cond.FirstUseEver)
        imgui.Begin('', recon_infa_player, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
            local result = sampIsPlayerConnected(Load_Config.Recon.ReconID)
                if not result then
                    recon.v = false
                    recon_infa_player.v = false
                    printStyledString('~r~RECON ~r~OFF ~r~PLAYER ~r~DISCONNECT', 1500, 4)
                else
                    recon_nick = sampGetPlayerNickname(Load_Config.Recon.ReconID)
                end
            local isPed, pPed = sampGetCharHandleBySampPlayerId(Load_Config.Recon.ReconID)
                if isPed and doesCharExist(pPed) then
                    recon_infa_player.v = true
                    recon_health = sampGetPlayerHealth(Load_Config.Recon.ReconID)
                    recon_armour = sampGetPlayerArmor(Load_Config.Recon.ReconID)
                    recon_ping =  sampGetPlayerPing(Load_Config.Recon.ReconID)
                    recon_score = sampGetPlayerScore(Load_Config.Recon.ReconID)
                    recon_skin = getCharModel(pPed)
                    recon_weapon = getCurrentCharWeapon(pPed)
                    weap = getweaponname(recon_weapon)
            FontSize(1.1)
            imgui.Text(u8'NICK:'..recon_nick..'\nID:'..Load_Config.Recon.ReconID)
            imgui.Separator()
                imgui.Text(u8'ХП:'..recon_health)
                    if recon_armour == 0 then
                        imgui.Text(u8'Броня:Нету')
                    else
                        imgui.Text(u8'Броня:'..recon_armour)
                    end
                        imgui.Text(u8'Пинг:'..recon_ping)
                            imgui.Text(u8'LVL:'..recon_score)
                            local result = sampIsPlayerPaused(Load_Config.Recon.ReconID)
                                if result then
                                    afk = u8'Да'
                                else
                                    afk = u8'Нет'
                                end
                                imgui.Text(u8'AFK:'..afk)
                                    imgui.Text(u8'Скин:'..recon_skin..' id')
                                        imgui.Text(u8'Оружие:'..weap..' ['..recon_weapon..']')
                                        imgui.Separator()
                                    if isCharInAnyCar(pPed) then
                                        carHundle = storeCarCharIsInNoSave(pPed)
                                        carHealth = getCarHealth(carHundle)
                                        carSpeed = getCarSpeed(carHundle)
                                        car_model = getCarModel(carHundle)
                                        car_door = getCarDoorLockStatus(carHundle)
                                        result, idCar = sampGetVehicleIdByCarHandle(carHundle)
                                            imgui.Text(u8'ХП:'..carHealth)
                                                imgui.Text(u8'Скорость:'..math.floor(carSpeed*4))
                                                    imgui.Text(u8'Модель:'..getCarNamebyModel(car_model)..' ['..car_model..']')
                                                if isCarEngineOn(carHundle) then
                                                    engine = u8'Заведен'
                                                else 
                                                    engine = u8'Заглушен'
                                                end
                                                imgui.Text(u8'Двигатель:'..engine)
                                                imgui.Text(u8(car_door > 0 and 'Двери:закрыта' or 'Двери:окрыта'))
                                                imgui.Text(u8'Id:'..idCar)
                                        else
                                            imgui.TextColored(imgui.ImVec4(1,0,0,1), u8'Игрок не в транспорте')
                                    end
                                else
                                    imgui.TextColored(imgui.ImVec4(1,0,0,1), u8'Нет информации о игроке')
                                end
        imgui.End()
    end
end

function onScriptTerminate(script, quitGame)
    if script == thisScript() then 
    Load_Config.Options.togphone             = ToggleButton_togphone.v 
    Load_Config.Options.WH                   = ToggleButton_Wh.v 
    Load_Config.Options.Offgoto              = ToggleButton_offgoto.v 
    Load_Config.Options.Gm                   = ToggleButton_Gm.v 
    Load_Config.Options.ChatSms              = ToggleButton_ChatSms.v 
    Load_Config.Options.Message              = ToggleButton_PushMessage.v 
    Load_Config.Options.FastKey              = ToggleButton_FastKey.v 
    Load_Config.Options.CheckConnect         = ToggleButton_CheckConnected.v
    Load_Config.Recon.Actived                = ToggleButton_Recon.v 
    Load_Config.Options.Sound                = ToggleButton_Sound.v
    Load_Config.Checker.Actived              = ToggleButton_Checker.v
    Load_Config.Options.WallHackSkeletalLine = ToggleButton_WHLine.v
    Load_Config.General.Active               = ToggleButton_AutoLogin.v
    Load_Config.info.CarColor                = CarColor.v 
        inicfg.save(Load_Config, Direct_Ini)
    -- Other --
    end
end