Dir.glob(File.dirname(__FILE__) + '/adapters/*').each { |adapter| require adapter }
