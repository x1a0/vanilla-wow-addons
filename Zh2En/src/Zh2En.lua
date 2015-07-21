Zh2En_Settings = {}
Zh2En_Data = {}
Zh2En_Settings["init"] = false
Zh2En_LastQueryResult = ";)"

function Zh2En_onLoad()
  this:RegisterEvent("ADDON_LOADED")
  Zh2En_addMessage("Zh2En loaded")
end

function Zh2En_onEvent()
  if ((event == "ADDON_LOADED") and (arg1 == "Zh2En")) then
    if (not Zh2En_Settings["init"]) then
      Zh2En_InitData()
      Zh2En_Settings["init"] = true
    end
  end
end

function Zh2En_addMessage(msg)
  DEFAULT_CHAT_FRAME:AddMessage("<Zh2En> " .. msg)
end

StaticPopupDialogs["ZH2EN"] = {
  text = "%s",
  button2 = "OK",
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
  hasEditBox = true,
  OnShow = function()
    getglobal(this:GetName().."EditBox"):SetText(Zh2En_LastQueryResult);
  end
};

SLASH_ZH2EN1 = '/z2e'
function SlashCmdList.ZH2EN(msg, editbox)
  Zh2En_LastQueryResult = Zh2En_Data[msg]
  StaticPopup_Show("ZH2EN", msg)
end

function Zh2En_InitData()
  Zh2En_Data["厚重的石头"] = "Dense Stone"
  Zh2En_Data["丝绸"] = "Silk cloth"
  Zh2En_addMessage("Data loaded")
end
