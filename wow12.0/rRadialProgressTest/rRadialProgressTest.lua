local A, L = ...

local frame = CreateFrame("Frame", A.."Frame", UIParent)
frame:SetSize(128, 128)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
frame:SetScale(1)

local baseTex = frame:CreateTexture(nil, "BACKGROUND")
baseTex:SetAllPoints(frame)
baseTex:SetTexture("Interface\\AddOns\\"..A.."\\ring_bg2.tga")
baseTex:SetVertexColor(1, 1, 0, 1)

local maskTex = frame:CreateMaskTexture(nil, "BACKGROUND")
maskTex:SetAllPoints(frame)
maskTex:SetTexture("Interface\\AddOns\\"..A.."\\ring_mask.tga")
baseTex:AddMaskTexture(maskTex)

local controlYOffset = -40

local function CreateSlider(name, labelText, minVal, maxVal, step, defaultVal, onChange)
    local slider = CreateFrame("Slider", A.."Slider_"..name, frame, "OptionsSliderTemplate")
    slider:SetPoint("TOP", frame, "BOTTOM", 0, controlYOffset)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetValue(defaultVal)
    slider:SetObeyStepOnDrag(true)
    slider:SetWidth(180)

    _G[slider:GetName().."Text"]:SetText(labelText)
    local valText = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    valText:SetPoint("TOP", slider, "BOTTOM", 0, -2)
    valText:SetText(tostring(defaultVal))

    slider:SetScript("OnValueChanged", function(self, value)
        valText:SetText(string.format("%.2f", value))
        onChange(value)
    end)

    controlYOffset = controlYOffset - 45
    return slider
end

local function CreateCheckbox(name, labelText, defaultVal, onChange)
    local cb = CreateFrame("CheckButton", A.."Checkbox_"..name, frame, "UICheckButtonTemplate")
    cb:SetPoint("TOP", frame, "BOTTOM", -70, controlYOffset)
    cb:SetChecked(defaultVal)

    cb.text = cb:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    cb.text:SetPoint("LEFT", cb, "RIGHT", 5, 0)
    cb.text:SetText(labelText)

    cb:SetScript("OnClick", function(self)
        onChange(self:GetChecked())
    end)

    controlYOffset = controlYOffset - 35
    return cb
end

local function CreateColorPicker(name, labelText, defaultR, defaultG, defaultB, defaultA, onChange)
    local btn = CreateFrame("Button", A.."ColorPicker_"..name, frame, "UIPanelButtonTemplate")
    btn:SetPoint("TOP", frame, "BOTTOM", 0, controlYOffset)
    btn:SetSize(140, 24)
    btn:SetText(labelText)

    local swatch = btn:CreateTexture(nil, "OVERLAY")
    swatch:SetSize(16, 16)
    swatch:SetPoint("LEFT", btn, "LEFT", 6, 0)
    swatch:SetColorTexture(defaultR, defaultG, defaultB, defaultA)

    btn:SetScript("OnClick", function()
        local info = {
            r = defaultR,
            g = defaultG,
            b = defaultB,
            opacity = defaultA,
            hasOpacity = true,
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                local a = ColorPickerFrame:GetColorAlpha()
                swatch:SetColorTexture(r, g, b, a)
                defaultR, defaultG, defaultB, defaultA = r, g, b, a
                onChange(r, g, b, a)
            end,
            opacityFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                local a = ColorPickerFrame:GetColorAlpha()
                swatch:SetColorTexture(r, g, b, a)
                defaultR, defaultG, defaultB, defaultA = r, g, b, a
                onChange(r, g, b, a)
            end,
            cancelFunc = function(previousValues)
                local r, g, b, a = previousValues.r, previousValues.g, previousValues.b, previousValues.opacity
                swatch:SetColorTexture(r, g, b, a)
                defaultR, defaultG, defaultB, defaultA = r, g, b, a
                onChange(r, g, b, a)
            end,
        }
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end)

    controlYOffset = controlYOffset - 35
    return btn
end

-- Slider: SetRadialProgressBarPercent (0.0 to 1.0)
CreateSlider("Percent", "Percent", 0, 1, 0.01, 1.0, function(val)
    baseTex:SetRadialProgressBarPercent(val)
end)

-- Slider: SetRadialProgressBarStartOffset (Angle/Ratio Offset: 0.0 to 1.0)
CreateSlider("StartOffset", "Start Offset", 0, 1, 0.01, 0.0, function(val)
    baseTex:SetRadialProgressBarStartOffset(val)
end)

-- Slider: SetRadialProgressBarEndOffset (Angle/Ratio Offset: 0.0 to 1.0)
CreateSlider("EndOffset", "End Offset", 0, 1, 0.01, 0.0, function(val)
    baseTex:SetRadialProgressBarEndOffset(val)
end)

-- Slider: SetRadialProgressBarFeather (Edge Feathering: 0.0 to 1.0)
CreateSlider("Feather", "Feather", 0, 1, 0.01, 0.0, function(val)
    baseTex:SetRadialProgressBarFeather(val)
end)

-- Checkbox: SetRadialProgressBarReverse (Boolean)
CreateCheckbox("Reverse", "Reverse Fill", false, function(isReversed)
    baseTex:SetRadialProgressBarReverse(isReversed)
end)

-- Color Picker: Changes Vertex Color of baseTex
CreateColorPicker("RingColor", "Texture Color", 1, 1, 0, 1, function(r, g, b, a)
    baseTex:SetVertexColor(r, g, b, a)
end)