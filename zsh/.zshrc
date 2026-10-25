CONFIG_HOME="$HOME/.config/zsh/zshconfig.d"

for config_script in "$CONFIG_HOME"/*.sh(N.on); do
    source "$config_script"
done

