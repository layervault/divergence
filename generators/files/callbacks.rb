Divergence::Application.configure do |config|
  config.callbacks :after_swap do
    # Run anything after the swap finishes
    #
    # after_swap changes to the app directory for you, so
    # you can simply run any commands you want. There are
    # some built-in helpers too.
  end
end