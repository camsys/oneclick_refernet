module OneclickRefernet
  module SpecHelpers

    def factory_from_class(klass)
      klass.to_s.underscore
      .gsub("oneclick_refernet/","").to_sym
    end

  end
end
