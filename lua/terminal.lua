local util = require ("util")

if util.is_windows () then
    if vim.fn.executable ("pwsh") == 1 then
        vim.o.shell = "pwsh" -- PowerShell Core
    else
        vim.o.shell = "powershell" -- Windows PowerShell
    end

    vim.o.shellcmdflag =
        "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();"

    vim.o.shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
    vim.o.shellpipe = "2>&1 | Tee-Object %s; exit $LastExitCode"
    vim.o.shellquote = ""
    vim.o.shellxquote = ""
else
    if vim.fn.executable ("fish") then
        vim.o.shell = "fish"
    end
end

tmap ("<Esc>", "<C-\\><C-n>")
tmap ("<C-[>", "<C-\\><C-n>")

vim.api.nvim_create_autocmd ({ "TermRequest" }, {
    desc = "Handles OSC 7 dir change requests",
    callback = function (ev)
        print ("TermRequest")
        if string.sub (ev.data.sequence, 1, 4) == "\x1b]7;" then
            local dir = string.gsub (ev.data.sequence, "\x1b]7;file://[^/]*", "")
            print ("osc7_dir: " .. dir)
            if vim.fn.isdirectory (dir) == 0 then
                vim.notify ("invalid dir: " .. dir)
                return
            end
            vim.api.nvim_buf_set_var (ev.buf, "osc7_dir", dir)
            if vim.o.autochdir and vim.api.nvim_get_current_buf () == ev.buf then
                vim.cmd.cd (dir)
            end
        end
    end,
})
vim.api.nvim_create_autocmd ({ "BufEnter", "WinEnter", "DirChanged" }, {
    callback = function (ev)
        if vim.b.osc7_dir and vim.fn.isdirectory (vim.b.osc7_dir) == 1 then
            vim.cmd.cd (vim.b.osc7_dir)
        end
    end,
})
