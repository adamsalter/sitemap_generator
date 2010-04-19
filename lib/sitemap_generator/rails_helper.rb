module SitemapGenerator
  module RailsHelper
    # Returns whether this environment is using ActionPack
    # version 3.0.0 or greater.
    #
    # @return [Boolean]
    def self.rails3?
      # The ActionPack module is always loaded automatically in Rails >= 3
      return false unless defined?(ActionPack) && defined?(ActionPack::VERSION)

      version =
        if defined?(ActionPack::VERSION::MAJOR)
          ActionPack::VERSION::MAJOR
        else
          # Rails 1.2
          ActionPack::VERSION::Major
        end

      # 3.0.0.beta1 acts more like ActionPack 2
      # for purposes of this method
      # (checking whether block helpers require = or -).
      # This extra check can be removed when beta2 is out.
      version >= 3 &&
        !(defined?(ActionPack::VERSION::TINY) &&
          ActionPack::VERSION::TINY == "0.beta")
    end
  end
end