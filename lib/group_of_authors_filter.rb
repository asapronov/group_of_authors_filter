require 'redmine'

to_prepare = proc do
  unless IssueQuery
             .included_modules
             .include?(RedmineGroupOfAuthorsFilter::Patches::IssueQueryPatch)
    IssueQuery.send(:include,
                    RedmineGroupOfAuthorsFilter::Patches::IssueQueryPatch)
  end
end

Rails.configuration.to_prepare(&to_prepare) if Redmine::VERSION::MAJOR >= 3