local M = {}

function M.get_root ()
    local clients = vim.lsp.get_clients ({ bufnr = 0 })
    for _, client in pairs (clients) do
        if client.root_dir then
            return client.root_dir
        end
    end
    return vim.fs.root (M.bufdir (0), {
        ".git",
        ".hg",
        ".projectile",
        "nvim",
    })
end

function M.bufdir (bufnr)
    local t = {
        oil = require ("oil").get_current_dir,
    }

    local ft = vim.bo[bufnr].filetype

    if t[ft] then
        return t[ft] (bufnr)
    end

    return vim.fn.fnamemodify (vim.api.nvim_buf_get_name (bufnr), ":h")
end

function M.find_files (opts)
    if M.is_windows () then
        if opts.cwd then
            opts.cwd = opts.cwd:gsub ("/", "\\")
        end
    end
    require ("telescope.builtin").find_files (opts)
end

function M.format (bufnr)
    bufnr = bufnr or 0
    require ("conform").format ({ bufnr = bufnr })
end

local function oil (dir)
    require ("oil").open (dir, nil, nil)
end

function M.openfm ()
    M.openfm_at (nil)
end

function M.openfm_at (dir)
    oil (dir)
end

function M.is_windows ()
    return (vim.loop.os_uname ().sysname == "Windows_NT")
end

function M.buf_is_term (b)
    return string.sub (vim.api.nvim_buf_get_name (b), 1, 7) == "term://"
end

function M.which (prog)
    local sep

    if M.is_windows () then
        sep = ";"
        prog = prog .. ".exe"
    else
        sep = ":"
    end

    for _, dir in ipairs(vim.split (vim.env.path, sep)) do
        local fpath = vim.fs.joinpath (dir, prog)
        if vim.uv.fs_stat (fpath) ~= nil then
            return fpath
        end
    end
    return nil
end

return M
