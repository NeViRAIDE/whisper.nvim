local async = require('plenary.async')

local status = require('neviraide-ui.notifications.status')
local config = require('neviraide-ui.notifications.config')

local api = vim.api

local notify_msg_cache = {}

local notify = async.void(function(msg, level, opts, no_cache)
  level = level or vim.log.levels.INFO
  no_cache = no_cache or false
  opts = opts or {}
  if level >= config.config.notify.min_level then
    status.push(
      'NeviraIDE',
      { mandat = msg, title = opts.title, icon = opts.icon }
    )

    if not no_cache then
      table.insert(notify_msg_cache, { msg = msg, level = level, opts = opts })
    end

    local lifetime = config.config.notify.clear_time
    if lifetime > 0 then
      async.util.sleep(lifetime)
      status.pop('NeviraIDE')
    end
  end
end)

local commands = {
  Clear = {
    opts = {},
    func = function() status.clear('NeviraIDE') end,
  },
  Recent = {
    opts = {
      bang = true,
    },
    func = function(args)
      if args.bang then
        local list = {}
        for _, msg in ipairs(notify_msg_cache) do
          list[#list + 1] = {
            text = msg.msg,
          }
        end

        vim.fn.setqflist(list, 'r')
      else
        for _, msg in ipairs(notify_msg_cache) do
          print(msg.msg)
          print(' ')
        end
      end
    end,
  },
}

return {
  notify = function(msg, level, opts) notify(msg, level, opts) end,
  setup = function()
    api.nvim_create_augroup(config.NS_NAME, {
      clear = true,
    })

    vim.notify = function(msg, level, opts, no_cache)
      notify(msg, level, opts, no_cache)
    end

    for cname, def in pairs(commands) do
      api.nvim_create_user_command(config.NS_NAME .. cname, def.func, def.opts)
    end

    local lsp_storage = {}

    vim.lsp.handlers['$/progress'] = function(_, params, ctx)
      if not params then return end

      local value = params.value

      local client = vim.lsp.get_client_by_id(ctx.client_id)
      if client then
        if value.kind == 'end' then
          status.pop('LSP', client.name)
          lsp_storage[params.token] = nil
        elseif value.kind == 'report' then
          local msg = lsp_storage[params.token]
          if not msg then error('Report without begin ?') end

          msg.opt = value.message or msg.opt

          status.push('LSP', msg, client.name)
        else
          lsp_storage[params.token] =
            { mandat = value.title, opt = value.message, dim = true }
          status.push('LSP', lsp_storage[params.token], client.name)
        end
      end
    end

    api.nvim_create_autocmd('VimResized', {
      group = config.NS_NAME,
      callback = function() status._delete_win() end,
    })
  end,
}
