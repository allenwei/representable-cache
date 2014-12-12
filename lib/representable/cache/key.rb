module Representable
  module Cache
    class Key < String
      def initialize(params)
        if params.respond_to?(:cache_key)
          super "[#{params.cache_key}]"
        elsif params.respond_to?(:keys)
          super params.sort_by { |k,_| k.to_s }.map { |k,v| "#{k}=#{self.class.new(v)}" }.join('&')
        elsif params.respond_to?(:map)
          super params.map { |p| self.class.new(p) }.join('&') 
        else
          super "[#{params}]"
        end
      end
    end
  end
end
