# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{nested_restful_scaffold}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mahmoud Khaled"]
  s.date = %q{2009-09-17}
  s.description = %q{NestedRestfulScaffold allows you to generate controller, views, model and routes of nested resources.}
  s.email = %q{mahmoud.khaled@badrit.com}
  s.extra_rdoc_files = ["README"]
  s.files = ["README", "Rakefile", "generators/nested_restful_scaffold/USAGE", "generators/nested_restful_scaffold/nested_restful_scaffold_generator.rb", "generators/nested_restful_scaffold/templates/controller.rb", "generators/nested_restful_scaffold/templates/fixtures.yml", "generators/nested_restful_scaffold/templates/functional_test.rb", "generators/nested_restful_scaffold/templates/helper.rb", "generators/nested_restful_scaffold/templates/layout.html.erb", "generators/nested_restful_scaffold/templates/migration.rb", "generators/nested_restful_scaffold/templates/model.rb", "generators/nested_restful_scaffold/templates/style.css", "generators/nested_restful_scaffold/templates/unit_test.rb", "generators/nested_restful_scaffold/templates/view_edit.html.erb", "generators/nested_restful_scaffold/templates/view_index.html.erb", "generators/nested_restful_scaffold/templates/view_new.html.erb", "generators/nested_restful_scaffold/templates/view_show.html.erb", "nested_restful_scaffold.gemspec", "Manifest"]
  s.homepage = %q{http://nestedrestfulscaffold.rubyforge.org/}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Nested_restful_scaffold", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{nestedrestscaff}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{NestedRestfulScaffold allows you to generate controller, views, model and routes of nested resources.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
