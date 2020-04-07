module RedmineGroupOfAuthorsFilter
  module Patches
    module IssueQueryPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          alias_method_chain :initialize_available_filters,
                             :group_of_authors_filter
        end
      end

      module InstanceMethods
        def initialize_available_filters_with_group_of_authors_filter
          initialize_available_filters_without_group_of_authors_filter
          add_group_of_authors_filter
        end

        def add_group_of_authors_filter
          add_available_filter 'group_of_authors',
                               type: :list_optional,
                               values: Group.givable.visible.collect {|g| [g.name, g.id.to_s]}
        end

        def sql_for_group_of_authors_field(field, operator, value)
          if operator == '*' # Any group
            groups = Group.givable
            operator = '=' # Override the operator since we want to find by author_id
          elsif operator == "!*"
            groups = Group.givable
            operator = '!' # Override the operator since we want to find by author_id
          else
            groups = Group.where(:id => value).to_a
          end

          groups ||= []

          group_of_authors = groups.inject([]) {|user_ids, group|
            user_ids + group.user_ids + [group.id]
          }.uniq.compact.sort.collect(&:to_s)

          '(' + sql_for_field("author_id", operator, group_of_authors, Issue.table_name, "author_id", false) + ')'
        end
      end
    end
  end
end
