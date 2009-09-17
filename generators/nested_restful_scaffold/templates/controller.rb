class <%= controller_class_name %>Controller < ApplicationController
  # GET /<%= table_name %>
  # GET /<%= table_name %>.xml
  <% resource_name = parent_resource_name %>
  def index
    @<%= table_name %> = <%= resource_name %>.<%= table_name %>

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @<%= table_name %> }
    end
  end

  # GET /<%= table_name %>/1
  # GET /<%= table_name %>/1.xml
  def show
    @<%= file_name %> = <%= resource_name %>.<%= table_name %>.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @<%= file_name %> }
    end
  end

  # GET /<%= table_name %>/new
  # GET /<%= table_name %>/new.xml
  def new
    @<%= file_name %> = <%= class_name %>.new
    @<%= file_name %>.<%= resource_name %> = <%= resource_name %>
	
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @<%= file_name %> }
    end
  end

  # GET /<%= table_name %>/1/edit
  def edit
    @<%= file_name %> = <%= resource_name %>.<%= table_name %>.find(params[:id])
  end

  # POST /<%= table_name %>
  # POST /<%= table_name %>.xml
  def create
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>]) if params[:<%= file_name %>][:<%= resource_name %>_id].nil? || params[:<%= file_name %>][:<%= resource_name %>_id] == <%= resource_name %>.id.to_s
    @<%= file_name %>.<%= resource_name %>_id = <%= resource_name %>.id

    respond_to do |format|
      if @<%= file_name %>.save
        flash[:notice] = '<%= class_name %> was successfully created.'
        format.html { redirect_to(<%= nested_resource_path singular_name, :instance_object => true %>) }
        format.xml  { render :xml => @<%= file_name %>, :status => :created, :location => @<%= file_name %> }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /<%= table_name %>/1
  # PUT /<%= table_name %>/1.xml
  def update
    @<%= file_name %> = <%= resource_name %>.<%= table_name %>.find(params[:id])

    respond_to do |format|
      if @<%= file_name %>.update_attributes(params[:<%= file_name %>])
        flash[:notice] = '<%= class_name %> was successfully updated.'
        format.html { redirect_to(<%= nested_resource_path singular_name, :instance_object => true %>) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /<%= table_name %>/1
  # DELETE /<%= table_name %>/1.xml
  def destroy
    @<%= file_name %> = <%= resource_name %>.<%= table_name %>.find(params[:id])
    url_path = <%= nested_resource_path singular_name, :instance_object => true, :plural => true %>
    @<%= file_name %>.destroy

    respond_to do |format|
      format.html { redirect_to(url_path) }
      format.xml  { head :ok }
    end
  end
  
  protected 
  def <%= resource_name %>
    @<%= resource_name %> ||= <%= generate_find_statement %>
  end
end
