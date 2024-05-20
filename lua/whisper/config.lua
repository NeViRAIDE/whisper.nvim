local ConfigModule = { Config = { Notify = {} } }

ConfigModule.NS_NAME = 'NeviraideUINotify'
ConfigModule.NS_ID = vim.api.nvim_create_namespace('neviraideNotify')

ConfigModule.config = {
  ignore_messages = {},
  status_width = function()
    local tw = vim.o.textwidth
    local cols = vim.o.columns
    if tw > 0 and tw < cols then
      return math.floor((cols - tw) * 0.7)
    else
      return math.floor(cols / 3)
    end
  end,
  -- TODO: add all messages
  components = { 'NeviraIDE', 'LSP', 'messages' },
  notify = {
    clear_time = 5000,
    min_level = vim.log.levels.INFO,
  },
  zindex = 50,
}

local function hl_group(name, options)
  local hl_name = ConfigModule.NS_NAME .. name
  vim.api.nvim_set_hl(0, hl_name, options)
  return hl_name
end

ConfigModule.HL_CONTENT_DIM =
  hl_group('ContentDim', { link = 'NotifyContentDim', default = true })
ConfigModule.HL_CONTENT =
  hl_group('Content', { link = 'NotifyContent', default = true })
ConfigModule.HL_TITLE =
  hl_group('Title', { link = 'NotifySource', default = true })
ConfigModule.HL_ICON =
  hl_group('Icon', { link = 'NotifySource', default = true })

ConfigModule.HL_INFO = hl_group('Info', { link = 'NofifyINFO', default = true })
ConfigModule.HL_WARNING =
  hl_group('Warning', { link = 'NotifyWARN', default = true })
ConfigModule.HL_ERROR =
  hl_group('Error', { link = 'NotifyERROR', default = true })

if vim.api.nvim_win_set_hl_ns then
  vim.api.nvim_set_hl(ConfigModule.NS_ID, 'NormalFloat', { bg = 'NONE' })
end

return ConfigModule
