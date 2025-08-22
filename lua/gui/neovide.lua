if vim.g.neovide then
    vim.g.neovide_opacity = 1.0
    vim.g.neovide_background_color = "#eeeeee"
    vim.g.neovide_theme = "light"
    vim.g.neovide_position_animation_length = 0
    vim.g.neovide_cursor_animation_length = 0
    vim.g.neovide_cursor_trail_size = 0
    vim.g.neovide_cursor_animate_in_insert_mode = false
    vim.g.neovide_cursor_animate_command_line = false
    vim.g.neovide_scroll_animation_far_lines = 0
    vim.g.neovide_scroll_animation_length = 0

    vim.keymap.set ({ "n", "v" }, "<C-+>", function ()
        vim.g.neovide_scale_factor = (vim.g.neovide_scale_factor or 1.0) + 0.1
    end)
    vim.keymap.set ({ "n", "v" }, "<C-->", function ()
        vim.g.neovide_scale_factor = (vim.g.neovide_scale_factor or 1.0) - 0.1
    end)

    vim.g.neovide_hide_mouse_when_typing = true
    vim.g.neovide_padding_left = 8
    vim.g.neovide_padding_top = 8
end
