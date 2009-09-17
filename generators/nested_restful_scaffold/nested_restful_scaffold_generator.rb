class NestedRestfulScaffoldGenerator < Rails::Generator::NamedBase
  default_options :skip_timestamps => false, :skip_migration => false
  
  attr_reader   :controller_name,
  :controller_class_path,
  :controller_file_path,
  :controller_class_nesting,
  :controller_class_nesting_depth,
  :controller_class_name,
  :controller_underscore_name,
  :controller_singular_name,
  :controller_plural_name
  alias_method  :controller_file_name,  :controller_underscore_name
  alias_method  :controller_table_name, :controller_plural_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    
    @controller_name = @name.pluralize
    
    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_underscore_name, @controller_plural_name = inflect_names(base_name)
    @controller_singular_name=base_name.singularize
    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
    
    # Remove resources from attributes 
    # and push them in new instance varialbe @resources
    # to separate between resources attributes and other attributes
    @resources = []
    attributes.delete_if{|a| a.type.to_s == 'resources' and @resources = a.name.split(',').collect{|e| e.strip} }
    @resources = nil if @resources.empty?
  end
  
  def manifest
    record do |m|
      unless command_has_resources
        m.dependency "scaffold", [name] + @args 
      else
        # Check for class naming collisions.
        m.class_collisions(controller_class_path, "#{controller_class_name}Controller", "#{controller_class_name}Helper")
        m.class_collisions(class_path, "#{class_name}")
        m.class_collisions class_path, class_name, "#{class_name}Test"
        
        # Controller, helper, views, test and stylesheets directories.
        m.directory(File.join('app/models', class_path))
        m.directory(File.join('app/controllers', controller_class_path))
        m.directory(File.join('app/helpers', controller_class_path))
        m.directory(File.join('app/views', controller_class_path, controller_file_name))
        m.directory(File.join('app/views/layouts', controller_class_path))
        m.directory(File.join('test/functional', controller_class_path))
        m.directory(File.join('test/unit', class_path))
        m.directory(File.join('public/stylesheets', class_path))
        
        # Model, test, and fixture directories.
        m.directory File.join('app/models', class_path)
        m.directory File.join('test/unit', class_path)
        m.directory File.join('test/fixtures', class_path)
        
        
        for action in scaffold_views
          m.template(
          "view_#{action}.html.erb",
          File.join('app/views', controller_class_path, controller_file_name, "#{action}.html.erb")
          )
        end
        
        # Layout and stylesheet.
        m.template('layout.html.erb', File.join('app/views/layouts', controller_class_path, "#{controller_file_name}.html.erb"))
        m.template('style.css', 'public/stylesheets/scaffold.css')
        
        m.template(
        "controller.rb", File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb")
        )
        
        m.template('functional_test.rb', File.join('test/functional', controller_class_path, "#{controller_file_name}_controller_test.rb"))
        m.template('helper.rb',          File.join('app/helpers',     controller_class_path, "#{controller_file_name}_helper.rb"))
        
        # add routes
        generate_routes m
        
        # genearte model, unit_test, fixtures and migration
        generate_model m
      end
    end
  end
  
  def resources
    @resources
  end
  
  def command_has_resources
    !resources.nil?
  end
  
  # Return parent resource name
  def parent_resource_name
    command_has_resources ? resources.last : ''
  end
  
  # Generate find statement to be used in the controller
  def generate_find_statement
    first_resource = resources.first
    statement = "#{first_resource.classify}.find(params[:#{first_resource}_id])"
    
    statement = resources[1..-1].inject(statement){|s, resource| s += ".#{resource.pluralize}.find(params[:#{resource}_id])"}
  end
  
  # Generate singular resource
  # prefix can be 'edit' to generate edit_resource_path
  # add_params will be used to generate params with the medthod
  # instance_object if true, it will add "@" to be instance variable
  # plural if true, pluralize the last resource. It is useful for index actions
  # reject_last if true, doesn't add last resource to the path. It is used in index view for "Return to parent resource" link 
  def nested_resource_path name, params = {}
    params = {:prefix => "", :add_params => true, :instance_object => false,
      :plural => false, :reject_last => false}.merge(params)
    result = ""
    
    result += resources[0..-2] * "_"
    result += "_" unless resources[0..-2].empty?
    
    # used only in index view for link "Return to"
    result += params[:plural] && params[:reject_last] ? resources.last.pluralize : resources.last
    result += '_'
    
    if params[:reject_last]
      result += "path"
    elsif command_has_resources
      result += params[:plural] ? name.pluralize : name
      result += "_path"
    else
      result = name
    end
    
    if !params[:prefix].empty? && !command_has_resources
      result += "_path"
    end
    
    force_params = params[:prefix]=="edit"
    
    # add parameters to the method
    param_name = name
    param_name = "@" + param_name if params[:instance_object]
    result += nested_resource_path_params(param_name, force_params, params[:plural]) if params[:add_params] || force_params
    
    # add prefix "edit" or "new"
    result = params[:prefix] + "_" + result unless params[:prefix].empty?
    result
  end
  
  # Return method parameters
  def nested_resource_path_params name, force_params, plural
    result = ""
    attr_params = resources.collect{|r| r}
    
    if command_has_resources || force_params
      attr_params << name
      i = resources.size
      while i > 0
        attr_params[i-1] = attr_params[i] + "." + attr_params[i-1]
        i -= 1
      end
      
      # skip last attribute if plural
      attr_params = attr_params[0..-2] if plural
      
      result = "(" + attr_params.join(',') + ")"
    end
    
    result
  end
  
  # Generate conditions for find statement to be used in view with input select
  def generate_conditions owner, name
    result = ""
    parent = nil
    has_resource = false
    resources.each do |resource| 
      if resource == name
        has_resource = true
        break
      end
      
      parent = resource if resource != name
    end
    
    result = ", :conditions => [\"#{parent}_id = ?\", @#{owner}.#{name}.#{parent}.id]" if has_resource && parent
    result
  end
  
  # Add routes to file routes.rb
  def generate_routes m
    # routes
    unless command_has_resources
      # add routes like unnested scaffold 
      # eg. map.resources books
      m.route_resources controller_file_name
    else
      resource_list = controller_file_name.map { |r| r.to_sym.inspect }.join(', ')
      parent_resource = parent_resource_name
      
      path = destination_path('config/routes.rb')
      content = File.read(path)
      
      logger.route "resources #{resource_list}"
      
      # map.resources :parents do |parent|
      # parent.resources :parents do |parent|
      sentinel = "\.resources(.*)?:#{parent_resource.pluralize}(.*)do(.*)\\|#{parent_resource}\\|"
      
      if content =~ /#{sentinel}/
        gsub_file 'config/routes.rb', sentinel do |match|
               "#{match}\n    #{parent_resource}.resources :#{table_name}"
        end
      else
        # without do block
        # map.resources :parents 
        # parent.resources :parents
        sentinel = "\.resources(.*):#{parent_resource.pluralize}"
        if content =~ /#{sentinel}/
          gsub_file 'config/routes.rb', sentinel do |match|
           "#{match} do |#{parent_resource}|\n    #{parent_resource}.resources :#{table_name}\n  end"
          end
        end
      end
    end
  end
  
  # Genearte model, unit_test, fixtures, migration and add has_many relationshipt to parents
  def generate_model m
    # Model class, unit test, and fixtures.
    m.template 'model.rb',      File.join('app/models', class_path, "#{file_name}.rb")
    m.template 'unit_test.rb',  File.join('test/unit', class_path, "#{file_name}_test.rb")
    
    unless options[:skip_fixture] 
      m.template 'fixtures.yml',  File.join('test/fixtures', "#{table_name}.yml")
    end
    
    unless options[:skip_migration]
      m.migration_template 'migration.rb', 'db/migrate', :assigns => {
        :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
      }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
    end
    
    # add has_many to referenced
    attributes.find_all{|a| a.type.to_s == "references"}.each do |parent|
      gsub_file "app/models/#{parent.name}.rb", "class #{parent.name.camelize} < ActiveRecord::Base" do |match|
      "#{match}\n   has_many :#{table_name}"
      end
    end
  end
  
  protected
  # Override with your own usage banner.
  def banner
      "Usage: #{$0} nested_restful_scaffold ModelName [field:type, field:type, resource1,resource2,...:resources]"
  end
  
  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-timestamps",
             "Don't add timestamps to the migration file for this model") { |v| options[:skip_timestamps] = v }
    opt.on("--skip-migration",
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
  end
  
  def gsub_file(relative_destination, regexp, *args, &block)
    path = destination_path(relative_destination)
    content = File.read(path).gsub(/#{regexp}/, *args, &block)
    File.open(path, 'wb') { |file| file.write(content) }
  end
  
  def scaffold_views
      %w[ index show new edit ]
  end
  
  def model_name
    class_name.demodulize
  end
end
