local wk = require('which-key')
local i = require('stigmata.utils').icon

wk.register({
  d = {
    n = {
      '<cmd>NeviraideUINotifyClear<cr>',
      'Dismiss all Notifications' .. i('󰎟', 'inbox', 1),
    },
  },
})
