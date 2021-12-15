#!/usr/bin/env bash

#
# fish shell config
#
configure_fish() {

  cat << 'EOF' > /mnt/etc/fish/conf.d/50-aliases.fish
#!/usr/bin/env fish

if status is-interactive && ! fish_is_root_user
  #
  # Aliases for interactive shell
  #

  # pacman commands
  alias pacman_update_mirrors="sudo reflector --threads "(nproc)" --country France --protocol https --sort rate --age 12 --number 20 --save /etc/pacman.d/mirrorlist"
  alias pacman_update_keyring="sudo pacman-key --init && sudo pacman-key --populate archlinux && sudo pacman -Sy archlinux-keyring"

  # ls to lsd alias
  alias ls="lsd"
  alias ll="lsd -l"
  alias la="lsd -al"

  # cat to bat alias
  alias cat='bat --paging=never'

  # less to bat alias
  alias less='bat'
end
EOF
}

configure_fish_prompt() {
  local user_name=$1

  # Install Fisher globally and required font for tide
  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed fisher-git ttf-meslo-nerd-font-powerlevel10k' - "${user_name}"

  # Install Fisher and Tide plugins globally
  exec_in_container /usr/bin/su -c 'fisher_path=/etc/fish fisher install jorgebucaran/fisher && fisher_path=/etc/fish fisher install IlanCosman/tide@v5' - "root"

    cat << 'EOF' > /mnt/etc/fish/conf.d/50-fish-tide-prompt-variables.fish
#!/usr/bin/env fish

if status is-interactive
  #
  # Tide prompt configuration
  #

  set -U tide_character_bg_color normal
  set -U tide_character_color 5FD700
  set -U tide_character_color_failure FF0000
  set -U tide_character_icon \u276f
  set -U tide_character_vi_icon_default \u276e
  set -U tide_character_vi_icon_replace \u25b6
  set -U tide_character_vi_icon_visual V
  set -U tide_chruby_bg_color 303030
  set -U tide_chruby_color B31209
  set -U tide_chruby_icon \ue23e
  set -U tide_cmd_duration_bg_color 303030
  set -U tide_cmd_duration_color 87875F
  set -U tide_cmd_duration_decimals 0
  set -U tide_cmd_duration_icon \uf252
  set -U tide_cmd_duration_threshold 3000
  set -U tide_context_always_display false
  set -U tide_context_bg_color 303030
  set -U tide_context_color_default D7AF87
  set -U tide_context_color_root D7AF00
  set -U tide_context_color_ssh D7AF87
  set -U tide_git_bg_color 303030
  set -U tide_git_bg_color_unstable 303030
  set -U tide_git_bg_color_urgent 303030
  set -U tide_git_color_branch 5FD700
  set -U tide_git_color_conflicted FF0000
  set -U tide_git_color_dirty D7AF00
  set -U tide_git_color_operation FF0000
  set -U tide_git_color_staged D7AF00
  set -U tide_git_color_stash 5FD700
  set -U tide_git_color_untracked 00AFFF
  set -U tide_git_color_upstream 5FD700
  set -U tide_git_icon \uf1d3
  set -U tide_go_bg_color 303030
  set -U tide_go_color 00ACD7
  set -U tide_go_icon \ue627
  set -U tide_jobs_bg_color 303030
  set -U tide_jobs_color 5FAF00
  set -U tide_jobs_icon \uf013
  set -U tide_kubectl_bg_color 303030
  set -U tide_kubectl_color 326CE5
  set -U tide_kubectl_icon \u2388
  set -U tide_left_prompt_frame_enabled true
  set -U tide_left_prompt_items os pwd git newline
  set -U tide_left_prompt_prefix ''
  set -U tide_left_prompt_separator_diff_color \ue0b0
  set -U tide_left_prompt_separator_same_color \ue0b1
  set -U tide_left_prompt_suffix \ue0b0
  set -U tide_node_bg_color 303030
  set -U tide_node_color 44883E
  set -U tide_node_icon \u2b22
  set -U tide_os_bg_color 303030
  set -U tide_os_color EEEEEE
  set -U tide_os_icon \uf303
  set -U tide_php_bg_color 303030
  set -U tide_php_color 617CBE
  set -U tide_php_icon \ue608
  set -U tide_prompt_add_newline_before false
  set -U tide_prompt_color_frame_and_connection 444444
  set -U tide_prompt_color_separator_same_color 949494
  set -U tide_prompt_icon_connection \u2500
  set -U tide_prompt_min_cols 26
  set -U tide_prompt_pad_items true
  set -U tide_pwd_bg_color 303030
  set -U tide_pwd_color_anchors 00AFFF
  set -U tide_pwd_color_dirs 0087AF
  set -U tide_pwd_color_truncated_dirs 8787AF
  set -U tide_pwd_icon \uf07c
  set -U tide_pwd_icon_home \uf015
  set -U tide_pwd_icon_unwritable \uf023
  set -U tide_pwd_markers .bzr .citc .git .hg .node-version .python-version .ruby-version .shorten_folder_marker .svn .terraform Cargo.toml composer.json CVS go.mod package.json
  set -U tide_right_prompt_frame_enabled true
  set -U tide_right_prompt_items status cmd_duration context shlvl jobs go node php virtual_env vi_mode time
  set -U tide_right_prompt_prefix \ue0b2
  set -U tide_right_prompt_separator_diff_color \ue0b2
  set -U tide_right_prompt_separator_same_color \ue0b3
  set -U tide_right_prompt_suffix ''
  set -U tide_rustc_bg_color 303030
  set -U tide_rustc_color F74C00
  set -U tide_rustc_icon \ue7a8
  set -U tide_shlvl_bg_color 303030
  set -U tide_shlvl_color d78700
  set -U tide_shlvl_icon \uf120
  set -U tide_shlvl_threshold 1
  set -U tide_status_bg_color 303030
  set -U tide_status_bg_color_failure 303030
  set -U tide_status_color 5FAF00
  set -U tide_status_color_failure D70000
  set -U tide_status_icon \u2714
  set -U tide_status_icon_failure \u2718
  set -U tide_time_bg_color 303030
  set -U tide_time_color 5F8787
  set -U tide_time_format '%T'
  set -U tide_vi_mode_bg_color_default 303030
  set -U tide_vi_mode_bg_color_replace 303030
  set -U tide_vi_mode_bg_color_visual 303030
  set -U tide_vi_mode_color_default 87af00
  set -U tide_vi_mode_color_replace d78700
  set -U tide_vi_mode_color_visual 5f87d7
  set -U tide_vi_mode_icon_default DEFAULT
  set -U tide_vi_mode_icon_replace REPLACE
  set -U tide_vi_mode_icon_visual VISUAL
  set -U tide_virtual_env_bg_color 303030
  set -U tide_virtual_env_color 00AFAF
  set -U tide_virtual_env_icon \ue73c
end
EOF
}
