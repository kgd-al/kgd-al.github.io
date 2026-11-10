# _plugins/clear_on_rebuild.rb
# Clear the terminal before each regeneration during `jekyll serve`.
first_build = true

Jekyll::Hooks.register :site, :after_reset do |_site|
  if first_build
    first_build = false          # keep the initial startup output
  elsif $stdout.tty?             # never touches CI logs or piped output
    print "\e[H\e[2J\e[3J"       # cursor home, clear screen, clear scrollback
  end
end
