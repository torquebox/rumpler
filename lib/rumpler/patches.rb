
class Array
  def hash 
    inject(0) do |h, e|
      h += e.hash / size
    end
  end
end

module Gem
  class Requirement
    def hash
      requirements.to_s.hash
    end
  end
end

module Bundler
  class RemoteSpecification
    attr_accessor :source_uri
  end
end
