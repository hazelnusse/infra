{
  flake.modules.nixvim.base = {
    autoCmd = [
      {
        event = [ "FileType" ];
        pattern = [ "gitcommit" ];
        callback.__raw = ''
          function()
            local group = vim.api.nvim_create_augroup("GitCommitLimits", { clear = true })

            vim.cmd("startinsert")

            vim.opt_local.spell = true

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              group = group,
              buffer = 0,
              callback = function()
                local row, _ = unpack(vim.api.nvim_win_get_cursor(0))

                if row == 1 then
                  vim.opt_local.textwidth = 50
                  vim.opt_local.colorcolumn = "51"
                else
                  vim.opt_local.textwidth = 72
                  vim.opt_local.colorcolumn = "73"
                end
              end,
            })
          end
        '';
      }
    ];
  };
}
