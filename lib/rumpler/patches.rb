
class Array
  def hash 
    to_s.hash
  end
end

module Gem
  class Requirement
    def hash
      requirements.to_s.hash
    end
  end
end
