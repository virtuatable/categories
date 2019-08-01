# frozen_string_literal: true

module Decorators
  # Represents a rights category
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Category < Draper::Decorator
    delegate_all

    def to_h
      {
        id: object.id.to_s,
        slug: object.slug,
        count: object.rights.count,
        rights: parse_rights
      }
    end

    def parse_rights
      object.rights.map do |right|
        Decorators::Right.new(right).to_h
      end
    end
  end
end
