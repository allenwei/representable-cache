module Representable
  class TestCache
    def initialize(initial={})
      @cache = initial
    end

    def get(key)
      @cache[key]
    end

    def set(key, value)
      @cache[key] = value
    end

    def clear
      @cache = {}
    end
  end
end
